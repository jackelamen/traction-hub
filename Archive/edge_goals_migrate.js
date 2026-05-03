#!/usr/bin/env node
// ============================================================
//  THE EDGE Goals — localStorage → Supabase Migration Script
//  Node.js 18+  (uses native fetch)
//
//  BEFORE YOU RUN:
//  1. Open goals.html in your browser
//  2. Open DevTools console (F12)
//  3. Run:  copy(localStorage.getItem('gs2_db'))
//  4. Paste into a file called gs2_db.json in this same folder
//  5. Run:  node edge_goals_migrate.js
//
//  The script is IDEMPOTENT — safe to re-run. It uses upsert
//  on local_id so re-running will update rather than duplicate.
// ============================================================

import { readFileSync } from 'fs';
import { createClient } from '@supabase/supabase-js';

// ── Config ───────────────────────────────────────────────────
const SB_URL  = 'https://kthpsnaxkzmxjgbmychn.supabase.co';
const SB_KEY  = process.env.SUPABASE_SERVICE_KEY || 'PASTE_YOUR_SERVICE_ROLE_KEY_HERE';

const supabase = createClient(SB_URL, SB_KEY);

// ── Load export ──────────────────────────────────────────────
let raw;
try {
  raw = readFileSync('./gs2_db_clean.json', 'utf8');
} catch {
  console.error('❌  gs2_db_clean.json not found.');
  process.exit(1);
}

let db;
try {
  db = JSON.parse(raw);
} catch {
  console.error('❌  gs2_db_clean.json is not valid JSON.');
  process.exit(1);
}

const visions  = db.visions  || {};
const goals    = db.goals    || [];
const sprints  = db.sprints  || [];

console.log(`\n📦  Loaded export:`);
console.log(`    visions : ${Object.keys(visions).length} areas`);
console.log(`    goals   : ${goals.length}`);
console.log(`    sprints : ${sprints.length}\n`);

// ── Helpers ──────────────────────────────────────────────────
async function upsert(table, rows, conflictCol = 'local_id') {
  if (!rows.length) return [];
  const { data, error } = await supabase
    .from(table)
    .upsert(rows, { onConflict: conflictCol, returning: 'representation' });
  if (error) {
    console.error(`❌  Error upserting into ${table}:`, error.message);
    process.exit(1);
  }
  return data || [];
}

// ── 1. Visions ───────────────────────────────────────────────
async function migrateVisions() {
  console.log('📝  Migrating visions...');
  // 'career' in localStorage maps to 'work' in the DB enum
  const areaMap = { health: 'health', work: 'work', career: 'work', family: 'family', personal: 'personal' };
  const seen = new Set();
  const rows = [];
  for (const [rawArea, content] of Object.entries(visions)) {
    const area = areaMap[rawArea];
    if (!area || seen.has(area)) continue;
    seen.add(area);
    rows.push({ area, content: content || '', updated_at: new Date().toISOString() });
  }

  if (!rows.length) {
    console.log('    No vision data found — skipping.\n');
    return;
  }

  // Visions use area as the conflict key (unique), not local_id
  const { error } = await supabase
    .from('visions')
    .upsert(rows, { onConflict: 'area' });
  if (error) {
    console.error('❌  Error upserting visions:', error.message);
    process.exit(1);
  }
  console.log(`    ✓ ${rows.length} vision area(s) upserted.\n`);
}

// ── 2. Goals ─────────────────────────────────────────────────
// Returns a map of { localId → uuid } for sprint migration
async function migrateGoals() {
  console.log('🎯  Migrating goals...');
  if (!goals.length) {
    console.log('    No goals found — skipping.\n');
    return {};
  }

  const areaMap = { health: 'health', work: 'work', career: 'work', family: 'family', personal: 'personal' };
  const goalRows = goals.map(g => ({
    local_id:   g.id,
    title:      g.title,
    area:       areaMap[g.areaId] || 'work',
    why:        g.why || null,
    status:     g.status || 'active',
  }));

  const inserted = await upsert('goals', goalRows);

  // Build local_id → uuid lookup
  // After upsert we re-fetch to get the real UUIDs
  const { data: goalRecords, error } = await supabase
    .from('goals')
    .select('id, local_id')
    .in('local_id', goals.map(g => g.id));
  if (error) { console.error('❌  Could not fetch goal UUIDs:', error.message); process.exit(1); }

  const goalIdMap = {};
  for (const r of goalRecords) goalIdMap[r.local_id] = r.id;

  console.log(`    ✓ ${goals.length} goal(s) upserted.\n`);

  // ── 2a. Goal metrics ────────────────────────────────────────
  console.log('📏  Migrating goal metrics...');
  const metricRows = [];
  const metricIdMap = {}; // localGoalId_localMetricId → uuid (built after insert)

  for (const g of goals) {
    const goalUuid = goalIdMap[g.id];
    if (!goalUuid) continue;
    const metrics = g.metrics || [];
    metrics.forEach((m, idx) => {
      if (!m.name?.trim()) return;
      metricRows.push({
        local_id:   m.id,
        goal_id:    goalUuid,
        name:       m.name,
        type:       m.type || 'Number',
        target:     m.target || null,
        sort_order: idx,
      });
    });
  }

  if (metricRows.length) {
    await upsert('goal_metrics', metricRows);

    // Fetch back to get UUIDs
    const { data: metricRecords, error: mErr } = await supabase
      .from('goal_metrics')
      .select('id, local_id')
      .in('local_id', metricRows.map(r => r.local_id));
    if (mErr) { console.error('❌  Could not fetch metric UUIDs:', mErr.message); process.exit(1); }

    for (const r of metricRecords) metricIdMap[r.local_id] = r.id;
    console.log(`    ✓ ${metricRows.length} metric(s) upserted.\n`);
  } else {
    console.log('    No metrics found — skipping.\n');
  }

  // ── 2b. Metric progress logs ────────────────────────────────
  console.log('📈  Migrating metric logs...');
  const logRows = [];

  for (const g of goals) {
    const goalUuid = goalIdMap[g.id];
    if (!goalUuid) continue;
    const metricLogs = g.metricLogs || {};

    for (const [localMetricId, entries] of Object.entries(metricLogs)) {
      const metricUuid = metricIdMap[localMetricId];
      if (!metricUuid) {
        console.warn(`    ⚠️  Skipping logs for unknown metric id: ${localMetricId}`);
        continue;
      }
      for (const entry of entries) {
        if (!entry.date || entry.value === undefined) continue;
        logRows.push({
          metric_id: metricUuid,
          goal_id:   goalUuid,
          log_date:  entry.date,
          value:     parseFloat(entry.value),
          note:      entry.note || null,
        });
      }
    }
  }

  if (logRows.length) {
    // metric_logs unique key is (metric_id, log_date) — upsert on that
    const { error: lErr } = await supabase
      .from('metric_logs')
      .upsert(logRows, { onConflict: 'metric_id,log_date' });
    if (lErr) { console.error('❌  Error upserting metric_logs:', lErr.message); process.exit(1); }
    console.log(`    ✓ ${logRows.length} metric log(s) upserted.\n`);
  } else {
    console.log('    No metric logs found — skipping.\n');
  }

  return goalIdMap;
}

// ── 3. Sprints + Phases + Tactics ───────────────────────────
async function migrateSprints(goalIdMap) {
  console.log('🔄  Migrating sprints (focus cycles)...');
  if (!sprints.length) {
    console.log('    No sprints found — skipping.\n');
    return;
  }

  const sprintRows = sprints.map(sp => ({
    local_id:    sp.id,
    goal_id:     goalIdMap[sp.goalId],
    name:        sp.name,
    outcome:     sp.outcome || null,
    start_date:  sp.startDate || null,
    end_date:    sp.endDate   || null,
    week_checks: sp.weekChecks   || {},
    reflections: sp.reflections  || {},
  })).filter(r => r.goal_id); // skip any sprint whose goal didn't migrate

  const skipped = sprints.length - sprintRows.length;
  if (skipped) console.warn(`    ⚠️  Skipped ${skipped} sprint(s) with missing goal reference.`);

  await upsert('sprints', sprintRows);

  // Fetch back sprint UUIDs
  const { data: sprintRecords, error: spErr } = await supabase
    .from('sprints')
    .select('id, local_id')
    .in('local_id', sprintRows.map(r => r.local_id));
  if (spErr) { console.error('❌  Could not fetch sprint UUIDs:', spErr.message); process.exit(1); }

  const sprintIdMap = {};
  for (const r of sprintRecords) sprintIdMap[r.local_id] = r.id;

  console.log(`    ✓ ${sprintRows.length} sprint(s) upserted.\n`);

  // ── 3a. Phases ──────────────────────────────────────────────
  console.log('📐  Migrating sprint phases...');
  const phaseRows = [];
  const phaseIdMap = {}; // "sprintLocalId_phaseIndex" → uuid

  const PHASE_NAMES = ['Foundation', 'Build', 'Peak'];

  for (const sp of sprints) {
    const sprintUuid = sprintIdMap[sp.id];
    if (!sprintUuid) continue;
    const phases = sp.phases || [];

    for (let i = 0; i < 3; i++) {
      const ph = phases[i] || {};
      phaseRows.push({
        sprint_id:   sprintUuid,
        phase_index: i,
        name:        ph.name || PHASE_NAMES[i],
        description: ph.desc || null,
      });
    }
  }

  if (phaseRows.length) {
    // unique key is (sprint_id, phase_index)
    const { error: phErr } = await supabase
      .from('sprint_phases')
      .upsert(phaseRows, { onConflict: 'sprint_id,phase_index' });
    if (phErr) { console.error('❌  Error upserting sprint_phases:', phErr.message); process.exit(1); }

    // Fetch phase UUIDs
    const sprintUuids = Object.values(sprintIdMap);
    const { data: phaseRecords, error: phfErr } = await supabase
      .from('sprint_phases')
      .select('id, sprint_id, phase_index')
      .in('sprint_id', sprintUuids);
    if (phfErr) { console.error('❌  Could not fetch phase UUIDs:', phfErr.message); process.exit(1); }

    // Build lookup: sprintUuid_phaseIndex → phaseUuid
    for (const r of phaseRecords) {
      phaseIdMap[`${r.sprint_id}_${r.phase_index}`] = r.id;
    }

    console.log(`    ✓ ${phaseRows.length} phase(s) upserted.\n`);
  }

  // ── 3b. Tactics ─────────────────────────────────────────────
  console.log('✅  Migrating sprint tactics...');
  const tacticRows = [];

  for (const sp of sprints) {
    const sprintUuid = sprintIdMap[sp.id];
    if (!sprintUuid) continue;
    const phases = sp.phases || [];

    for (let i = 0; i < 3; i++) {
      const ph = phases[i] || {};
      const phaseUuid = phaseIdMap[`${sprintUuid}_${i}`];
      if (!phaseUuid) continue;
      const tactics = ph.tactics || [];

      tactics.forEach((t, idx) => {
        if (!t.text?.trim()) return;
        tacticRows.push({
          local_id:       t.id,
          phase_id:       phaseUuid,
          sprint_id:      sprintUuid,
          text:           t.text,
          freq:           t.freq || 'weekly',
          days:           t.days || [],
          times_per_week: t.timesPerWeek || null,
          sort_order:     idx,
        });
      });
    }
  }

  if (tacticRows.length) {
    await upsert('sprint_tactics', tacticRows);
    console.log(`    ✓ ${tacticRows.length} tactic(s) upserted.\n`);
  } else {
    console.log('    No tactics found — skipping.\n');
  }
}

// ── 4. Vision board images (instructions only) ───────────────
function visionBoardNote() {
  console.log('🖼️   Vision board images (gs2_vb):');
  console.log('    These are stored as base64 in localStorage and can be large.');
  console.log('    They should go to Supabase Storage, not the database.');
  console.log('    Steps:');
  console.log('    1. In browser console: copy(localStorage.getItem(\'gs2_vb\'))');
  console.log('    2. Paste into gs2_vb.json');
  console.log('    3. Run the separate vision board upload script (edge_vb_upload.js)');
  console.log('       — to be built once the main migration is verified.\n');
}

// ── Main ─────────────────────────────────────────────────────
async function run() {
  if (SB_KEY === 'PASTE_YOUR_SERVICE_ROLE_KEY_HERE') {
    console.error('❌  Supabase service role key not set.');
    console.error('   Run with: SUPABASE_SERVICE_KEY="your-key" node edge_goals_migrate.js');
    console.error('   Find it: Supabase Dashboard → Project Settings → API → service_role');
    process.exit(1);
  }

  await migrateVisions();
  const goalIdMap = await migrateGoals();
  await migrateSprints(goalIdMap);
  visionBoardNote();

  console.log('🎉  Migration complete!');
  console.log('\nNext steps:');
  console.log('  1. Open Supabase Table Editor and verify the data looks right.');
  console.log('  2. Cross-check a sprint\'s week_checks JSONB against what you');
  console.log('     see in goals.html — tactic IDs should match local_id values.');
  console.log('  3. Once happy, drop the local_id columns (SQL in schema comments).');
  console.log('  4. Upload vision board images (see note above).\n');
}

run().catch(err => {
  console.error('❌  Unexpected error:', err);
  process.exit(1);
});
