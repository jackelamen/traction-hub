const fs = require('fs');
const path = require('path');
const key = process.argv[2];
if (!key || key.length < 40) {
  console.error('Usage: node tools/set-new-supabase-anon-key.js <new-anon-key>');
  process.exit(1);
}
const files = [
  'login.html',
  'index.html',
  'health.html',
  'reset-password.html',
  'finance-dashboard.html',
  'wellness.html',
  'work.html',
  'finance-login.html',
  'goals.html',
  'tools/prune-daily-signals-supabase.js',
  'tools/push-samsung-health-to-supabase.js'
];
for (const file of files) {
  const full = path.resolve(file);
  if (!fs.existsSync(full)) continue;
  const before = fs.readFileSync(full, 'utf8');
  const after = before.replace(/const SB_ANON\s*=\s*'[^']+';/g, `const SB_ANON = '${key}';`);
  fs.writeFileSync(full, after);
}
console.log(`Updated SB_ANON in ${files.length} files.`);
