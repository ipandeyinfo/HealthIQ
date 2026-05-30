/* HealthIQ Service Worker — shell cache + stale-while-revalidate */
const VERSION = 'hiq-v1.0.0';
const SHELL = ['./', './index.html', './manifest.webmanifest'];

self.addEventListener('install', e => {
    e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(()=>self.skipWaiting()));
});

self.addEventListener('activate', e => {
    e.waitUntil(
        caches.keys().then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
        .then(()=>self.clients.claim())
    );
});

self.addEventListener('fetch', e => {
    const req = e.request;
    if(req.method !== 'GET') return;
    const url = new URL(req.url);
    // Never cache Supabase API or Drive/QR services
    if(url.hostname.includes('supabase.co') || url.hostname.includes('drive.google.com') || url.hostname.includes('qrserver.com')) return;

    // HTML: network-first (so updates are fast)
    if(req.mode === 'navigate' || req.headers.get('accept')?.includes('text/html')){
        e.respondWith(
            fetch(req).then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); return res; })
            .catch(()=> caches.match(req).then(m => m || caches.match('./index.html')))
        );
        return;
    }

    // Other GET (fonts, CSS, JS, CDN): stale-while-revalidate
    e.respondWith(
        caches.match(req).then(cached => {
            const network = fetch(req).then(res => {
                if(res && res.status === 200) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
                return res;
            }).catch(()=>cached);
            return cached || network;
        })
    );
});
