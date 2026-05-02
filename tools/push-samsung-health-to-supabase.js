#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const IMPORT_FILE = path.join(ROOT, 'samsung-health-last-6-months.import.json');
const DAILY_SIGNALS_KEY = 'edgex_daily_signals_v1';
const SB_URL = 'https://kthpsnaxkzmxjgbmychn.supabase.co';
const SB_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0aHBzbmF4a3pteGpnYm15Y2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTQ2MDMsImV4cCI6MjA4NzY5MDYwM30.Gz0bppkjT3GXgSVRGhXRtkUPXRiQ-U2skWcN2aTEyRI';
const SB_USER_ID = 'jack_traction_hub_v1';

async function fetchExistingSignals() {
  const url = `${SB_URL}/rest/v1/traction_data?user_id=eq.${encodeURIComponent(SB_USER_ID)}&key=eq.${encodeURIComponent(DAILY_SIGNALS_KEY)}&select=value`;
  const res = await fetch(url, {
    headers: {
      apikey: SB_ANON,
      Authorization: `Bearer ${SB_ANON}`,
      Accept: 'application/json'
    }
  });
  if (!res.ok) throw new Error(`Could not fetch existing signals: ${res.status} ${await res.text()}`);
  const rows = await res.json();
  return rows[0]?.value && typeof rows[0].value === 'object' ? rows[0].value : {};
}

async function pushSignals(value) {
  const res = await fetch(`${SB_URL}/rest/v1/rpc/upsert_traction_data`, {
    method: 'POST',
    headers: {
      apikey: SB_ANON,
      Authorization: `Bearer ${SB_ANON}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      rows: [{
        user_id: SB_USER_ID,
        key: DAILY_SIGNALS_KEY,
        value,
        updated_at: new Date().toISOString()
      }]
    })
  });
  if (!res.ok) throw new Error(`Could not push merged signals: ${res.status} ${await res.text()}`);
}

async function main() {
  const payload = JSON.parse(fs.readFileSync(IMPORT_FILE, 'utf8'));
  const imported = payload.dailySignals || {};
  const existing = await fetchExistingSignals();
  const merged = { ...existing };
  for (const [date, signal] of Object.entries(imported)) {
    merged[date] = { ...(merged[date] || {}), ...signal, updatedAt: signal.updatedAt || payload.generatedAt };
  }
  await pushSignals(merged);
  console.log(`Merged ${Object.keys(imported).length} Samsung Health days into ${DAILY_SIGNALS_KEY}.`);
  console.log(`Supabase daily signal days after merge: ${Object.keys(merged).length}.`);
}

main().catch(error => {
  console.error(error.message);
  process.exit(1);
});
