/* EDGEx PWA service worker — app-shell caching */
const CACHE = 'edgex-shell-v8';
const SHELL = [
  '/index.html','/goals.html','/health.html','/wellness.html',
  '/relationships.html','/learning.html','/weekly-review.html','/work.html'
];

self.addEventListener('message', function(e){ if(e.data==='skip'){ self.skipWaiting(); } });

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // Never cache Supabase / API calls — always go to network.
  if (url.hostname.endsWith('.supabase.co') || url.pathname.startsWith('/rest/')) return;

  // HTML navigations: network-first, fall back to cached shell.
  if (req.mode === 'navigate') {
    e.respondWith(
      fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(req, copy));
        return res;
      }).catch(() => caches.match(req).then((r) => r || caches.match('/index.html')))
    );
    return;
  }

  // Fonts / static assets: cache-first.
  if (url.hostname.includes('fonts.g') || /\.(css|js|png|svg|woff2?)$/.test(url.pathname)) {
    e.respondWith(
      caches.match(req).then((r) => r || fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(req, copy));
        return res;
      }))
    );
  }
});
