#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const EXPORT_ROOT = path.join(ROOT, 'Samsung Health jsons', 'jsons');
const CSV_ROOT = path.join(ROOT, 'Samsung Health jsons', 'csvs');
const OUT_FILE = process.env.SAMSUNG_HEALTH_IMPORT_OUT
  ? path.resolve(process.env.SAMSUNG_HEALTH_IMPORT_OUT)
  : path.join(ROOT, 'samsung-health-last-30-days.import.json');
const KST_OFFSET_MS = 9 * 60 * 60 * 1000;
const DAYS_TO_KEEP = Number(process.env.SAMSUNG_HEALTH_DAYS || 30);
const WINDOW_END = process.env.SAMSUNG_HEALTH_WINDOW_END || dateKey(Date.now());
const WINDOW_START = process.env.SAMSUNG_HEALTH_WINDOW_START || dateKey(
  new Date(`${WINDOW_END}T00:00:00+09:00`).getTime() - (DAYS_TO_KEEP - 1) * 24 * 60 * 60 * 1000
);

function dateKey(ms) {
  return new Date(ms + KST_OFFSET_MS).toISOString().slice(0, 10);
}

function inWindow(date) {
  return date >= WINDOW_START && date <= WINDOW_END;
}

function walkJsonFiles(dir) {
  const files = [];
  if (!fs.existsSync(dir)) return files;
  const stack = [dir];
  while (stack.length) {
    const current = stack.pop();
    for (const name of fs.readdirSync(current)) {
      const full = path.join(current, name);
      const stat = fs.statSync(full);
      if (stat.isDirectory()) stack.push(full);
      else if (name.endsWith('.json')) files.push(full);
    }
  }
  return files;
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return null;
  }
}

function ensureDay(days, date) {
  if (!days[date]) {
    days[date] = {
      source: 'Samsung Health',
      updatedAt: new Date().toISOString()
    };
  }
  return days[date];
}

function addMetric(bucket, key, value) {
  if (!Number.isFinite(value)) return;
  if (!bucket[key]) bucket[key] = { sum: 0, count: 0, min: Infinity, max: -Infinity };
  bucket[key].sum += value;
  bucket[key].count += 1;
  bucket[key].min = Math.min(bucket[key].min, value);
  bucket[key].max = Math.max(bucket[key].max, value);
}

function rounded(value, digits = 1) {
  if (!Number.isFinite(value)) return null;
  return Number(value.toFixed(digits));
}

function parseCsvLine(line) {
  const cells = [];
  let current = '';
  let quoted = false;
  for (let i = 0; i < line.length; i += 1) {
    const char = line[i];
    if (char === '"') {
      if (quoted && line[i + 1] === '"') {
        current += '"';
        i += 1;
      } else {
        quoted = !quoted;
      }
    } else if (char === ',' && !quoted) {
      cells.push(current);
      current = '';
    } else {
      current += char;
    }
  }
  cells.push(current);
  return cells;
}

function findCsv(prefix) {
  if (!fs.existsSync(CSV_ROOT)) return null;
  const file = fs.readdirSync(CSV_ROOT).find(name => name.startsWith(`${prefix}.`) && name.endsWith('.csv'));
  return file ? path.join(CSV_ROOT, file) : null;
}

function readSamsungCsv(prefix) {
  const file = findCsv(prefix);
  if (!file) return { file: null, rows: [] };
  const lines = fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '').split(/\r?\n/).filter(Boolean);
  const headers = parseCsvLine(lines[1] || '');
  const rows = lines.slice(2).map(line => {
    const cells = parseCsvLine(line);
    return Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? '']));
  });
  return { file, rows };
}

function csvDate(value) {
  if (!value) return null;
  const text = String(value).trim();
  if (/^\d{4}-\d{2}-\d{2}/.test(text)) return text.slice(0, 10);
  const ms = Number(text);
  if (Number.isFinite(ms) && ms > 1000000000000) return dateKey(ms);
  if (Number.isFinite(ms) && ms > 1000000000) return dateKey(ms * 1000);
  return null;
}

function importTimedArrays(days, summary, dirName, mapper) {
  const dir = path.join(EXPORT_ROOT, dirName);
  const files = walkJsonFiles(dir);
  let rows = 0;
  let used = 0;
  const perDay = {};

  for (const file of files) {
    const json = readJson(file);
    const records = Array.isArray(json) ? json : [json];
    for (const record of records) {
      if (!record || typeof record !== 'object') continue;
      rows += 1;
      const ts = record.start_time ?? record.time ?? record.end_time;
      if (!Number.isFinite(ts)) continue;
      const date = dateKey(ts);
      if (!inWindow(date)) continue;
      const mapped = mapper(record);
      if (!mapped) continue;
      if (!perDay[date]) perDay[date] = {};
      for (const [key, value] of Object.entries(mapped)) addMetric(perDay[date], key, value);
      used += 1;
    }
  }

  for (const [date, metrics] of Object.entries(perDay)) {
    const day = ensureDay(days, date);
    for (const [key, stat] of Object.entries(metrics)) {
      day[key] = rounded(stat.sum / stat.count, key.includes('Spo2') ? 0 : 1);
      if (key === 'spo2') day.spo2Min = rounded(stat.min, 0);
    }
  }

  summary[dirName] = { files: files.length, rows, usedRows: used, days: Object.keys(perDay).length };
}

function importExercise(days, summary) {
  const dirName = 'com.samsung.shealth.exercise';
  const files = walkJsonFiles(path.join(EXPORT_ROOT, dirName))
    .filter(file => file.endsWith('.live_data_internal.json'));
  let rows = 0;
  let usedFiles = 0;

  for (const file of files) {
    const json = readJson(file);
    const records = Array.isArray(json) ? json : [json];
    let first = Infinity;
    let last = -Infinity;
    let maxElapsed = 0;

    for (const record of records) {
      if (!record || typeof record !== 'object') continue;
      rows += 1;
      const ts = record.start_time;
      if (Number.isFinite(ts)) {
        first = Math.min(first, ts);
        last = Math.max(last, ts);
      }
      const elapsed = Number(record.elapsed_time);
      if (Number.isFinite(elapsed)) maxElapsed = Math.max(maxElapsed, elapsed);
    }

    if (!Number.isFinite(first)) continue;
    const date = dateKey(first);
    if (!inWindow(date)) continue;
    const durationMs = Math.max(maxElapsed, Number.isFinite(last) ? last - first : 0);
    const minutes = Math.round(durationMs / 60000);
    if (minutes < 1 || minutes > 8 * 60) continue;

    const day = ensureDay(days, date);
    day.exerciseMins = (Number(day.exerciseMins) || 0) + minutes;
    usedFiles += 1;
  }

  summary[dirName] = { files: files.length, rows, usedFiles };
}

function importDailyStepsCsv(days, summary) {
  const name = 'csv:com.samsung.shealth.tracker.pedometer_day_summary';
  const { file, rows } = readSamsungCsv('com.samsung.shealth.tracker.pedometer_day_summary');
  let used = 0;
  for (const row of rows) {
    const date = csvDate(row.day_time);
    if (!date || !inWindow(date)) continue;
    const steps = Number(row.step_count);
    if (!Number.isFinite(steps)) continue;
    const day = ensureDay(days, date);
    day.steps = Math.round(steps);
    used += 1;
  }
  summary[name] = { file: file ? path.basename(file) : null, rows: rows.length, usedRows: used };
}

function importActivityDaySummaryCsv(days, summary) {
  const name = 'csv:com.samsung.shealth.activity.day_summary';
  const { file, rows } = readSamsungCsv('com.samsung.shealth.activity.day_summary');
  let used = 0;
  for (const row of rows) {
    const date = csvDate(row.day_time);
    if (!date || !inWindow(date)) continue;
    const steps = Number(row.step_count);
    if (!Number.isFinite(steps)) continue;
    const day = ensureDay(days, date);
    day.steps = Math.round(steps);
    used += 1;
  }
  summary[name] = { file: file ? path.basename(file) : null, rows: rows.length, usedRows: used };
}

function importSleepCsv(days, summary) {
  const name = 'csv:com.samsung.shealth.sleep_combined';
  const { file, rows } = readSamsungCsv('com.samsung.shealth.sleep_combined');
  let used = 0;
  for (const row of rows) {
    const date = csvDate(row.end_time || row.start_time);
    if (!date || !inWindow(date)) continue;
    const durationMinutes = Number(row.sleep_duration);
    if (!Number.isFinite(durationMinutes) || durationMinutes <= 0) continue;
    const day = ensureDay(days, date);
    day.sleepHours = rounded(durationMinutes / 60, 2);
    used += 1;
  }
  summary[name] = { file: file ? path.basename(file) : null, rows: rows.length, usedRows: used };
}

function importExerciseCsv(days, summary) {
  const name = 'csv:com.samsung.shealth.exercise';
  const { file, rows } = readSamsungCsv('com.samsung.shealth.exercise');
  let used = 0;
  const totals = {};
  for (const row of rows) {
    const date = csvDate(row['com.samsung.health.exercise.start_time']);
    if (!date || !inWindow(date)) continue;
    const durationMs = Number(row['com.samsung.health.exercise.duration']);
    const minutes = Math.round(durationMs / 60000);
    if (!Number.isFinite(minutes) || minutes < 1 || minutes > 8 * 60) continue;
    if (!totals[date]) totals[date] = { mins: 0 };
    totals[date].mins += minutes;
    used += 1;
  }
  for (const [date, total] of Object.entries(totals)) {
    const day = ensureDay(days, date);
    day.exerciseMins = total.mins;
  }
  summary[name] = { file: file ? path.basename(file) : null, rows: rows.length, usedRows: used, days: Object.keys(totals).length };
}

function importWeightCsv(days, summary) {
  const name = 'csv:com.samsung.health.weight';
  const { file, rows } = readSamsungCsv('com.samsung.health.weight');
  let used = 0;
  for (const row of rows) {
    const date = csvDate(row.start_time);
    if (!date || !inWindow(date)) continue;
    const weight = Number(row.weight);
    if (!Number.isFinite(weight) || weight <= 0) continue;
    const day = ensureDay(days, date);
    day.weight = rounded(weight, 1);
    if (Number(row.body_fat) > 0) day.bodyFatPct = rounded(Number(row.body_fat), 1);
    used += 1;
  }
  summary[name] = { file: file ? path.basename(file) : null, rows: rows.length, usedRows: used };
}

function importWaterCsv(days, summary) {
  const name = 'csv:com.samsung.health.water_intake';
  const { file, rows } = readSamsungCsv('com.samsung.health.water_intake');
  let used = 0;
  const totals = {};
  for (const row of rows) {
    const date = csvDate(row.start_time);
    if (!date || !inWindow(date)) continue;
    const amountMl = Number(row.amount);
    if (!Number.isFinite(amountMl) || amountMl <= 0) continue;
    totals[date] = (totals[date] || 0) + amountMl;
    used += 1;
  }
  for (const [date, ml] of Object.entries(totals)) {
    const day = ensureDay(days, date);
    day.waterL = rounded(ml / 1000, 2);
    day.waterOz = rounded(ml / 29.5735, 1);
  }
  summary[name] = { file: file ? path.basename(file) : null, rows: rows.length, usedRows: used, days: Object.keys(totals).length };
}

const dailySignals = {};
const summary = {};

importTimedArrays(dailySignals, summary, 'com.samsung.health.hrv', record => ({
  hrvRmssd: Number(record.rmssd)
}));

importTimedArrays(dailySignals, summary, 'com.samsung.health.respiratory_rate', record => {
  const value = Number(record.respiratory_rate);
  return value > 0 ? { respiratoryRate: value } : null;
});

importTimedArrays(dailySignals, summary, 'com.samsung.health.skin_temperature', record => ({
  skinTemperatureC: Number(record.mean)
}));

importTimedArrays(dailySignals, summary, 'com.samsung.shealth.tracker.oxygen_saturation', record => {
  const value = Number(record.spo2);
  return value > 0 ? { spo2: value } : null;
});

importTimedArrays(dailySignals, summary, 'com.samsung.shealth.stress', record => {
  const score = Number(record.score);
  const level = Number(record.level);
  return score > 0 || level > 0 ? { stressScore: score, stressLevel: level } : null;
});

importDailyStepsCsv(dailySignals, summary);
importActivityDaySummaryCsv(dailySignals, summary);
importSleepCsv(dailySignals, summary);
importExerciseCsv(dailySignals, summary);
importWeightCsv(dailySignals, summary);
importWaterCsv(dailySignals, summary);

const importPayload = {
  source: 'samsung-health-export',
  generatedAt: new Date().toISOString(),
  merge: true,
  window: {
    start: WINDOW_START,
    end: WINDOW_END,
    timezone: 'Asia/Seoul'
  },
  dailySignals,
  importSummary: summary,
  skipped: {
    water: 'The Samsung water CSV contains no entries in the 2025-11-02 through 2026-05-02 window.'
  }
};

fs.writeFileSync(OUT_FILE, JSON.stringify(importPayload, null, 2));
console.log(`Wrote ${OUT_FILE}`);
console.log(`Daily signal days: ${Object.keys(dailySignals).length}`);
for (const [name, info] of Object.entries(summary)) {
  console.log(`${name}: ${JSON.stringify(info)}`);
}
