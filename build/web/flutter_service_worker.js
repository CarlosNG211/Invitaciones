'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "3f2606ae2c6a22c2e99b4974335a17d7",
"assets/AssetManifest.bin.json": "a4429a815d3226009c0ec06fdf496d6d",
"assets/assets/1.jpeg": "0937fbf2a9281ad5c63dd625da77b1f7",
"assets/assets/2.jpeg": "0dd3139e34340ba5f576dd37ad0cbb0a",
"assets/assets/3.jpeg": "55688950429494101e6b9b8ea409b364",
"assets/assets/AYUDA.png": "8abc7a251dc5d9d1125966c16a8fd08d",
"assets/assets/bolsa.png": "84d95b614876f36e6a15804e1ec9f90f",
"assets/assets/boo.png": "39f113b2623e3b171e814a2907c8407e",
"assets/assets/bubbletea.png": "ca9a246a27bb6459c501eb36aa0e35bc",
"assets/assets/Buldak.png": "a37e3920debaa5ab3cc0fe71e92ba82b",
"assets/assets/calabasa.png": "f01d145eb68a9730bb1137151916e056",
"assets/assets/canasta.png": "ca69dd9e82a51c4790b93dfd1f9e3afc",
"assets/assets/cancion.ogg": "eb292bbfdd8e655fef4326cdd477a61c",
"assets/assets/descuento.png": "5b00e98d4192169ab2c02906ba6a8fcb",
"assets/assets/dona.png": "83f0f6c747db5b428d8139d2768a08fd",
"assets/assets/dumpling.png": "760b69ffe7601460232b2f0f46c8daa5",
"assets/assets/equipo.png": "dfa948a0b2d271a622d680892b5fda1b",
"assets/assets/fantasma.png": "ff3401782c4d8662c6d79c6c8dcdd920",
"assets/assets/fondo.jpg": "f30ccdb387b280b8a2e53ac85f35ca96",
"assets/assets/fondo.png": "91671f059dacaf99491d7061fe1217db",
"assets/assets/hamburgesas.png": "a764b957b51dcfdcead2372e635661eb",
"assets/assets/idely.jpg": "6e52339a97c48119a7ab4c7e5936b35c",
"assets/assets/Independiente.png": "fb2564411d3f52f680c9cf1b7fe5e538",
"assets/assets/inicio.jpg": "81abc553e266c0151996d9778abef63c",
"assets/assets/login.png": "d9bc3870e8867edfa59a5bf9e168c3b3",
"assets/assets/logo.png": "c73a078ba406e9af0cc5d1f56eb3e71f",
"assets/assets/logo2.png": "36f78cd7492e1a29bbec2103e6628192",
"assets/assets/mapa.png": "96bd9fed8043c052a639b147f3574cc7",
"assets/assets/muerte.png": "6c4c85996bb4b0d27133776cc9836320",
"assets/assets/murcielago.png": "13097006ef7c6f1886535ece3fde0bac",
"assets/assets/Muricielago.png": "db36328e7383b384a5dca545ba27981e",
"assets/assets/papas.png": "56f1e9d49df4fea123189a5045de8f45",
"assets/assets/paypal.png": "670b15e6a4aa68089c2d2339ca07f560",
"assets/assets/pizza.png": "e2bb150829a5d420a71e90423a6d00ca",
"assets/assets/plix.jpg": "afb8bce0314980754547f95c04f0136e",
"assets/assets/pollo.png": "13ba750f110a730e6fe7c02e2b533efa",
"assets/assets/ramen.png": "9b31992ae37c607339f79b31e3beff5a",
"assets/assets/ramune.png": "9baafd15ea5ddf1e699f4ece2dec26cb",
"assets/assets/Solo.png": "818f7ea2f0c56bf60a3fefbfd4f8a9f6",
"assets/assets/telarana.png": "401e6ad02f21fdc42b9fd432f536f092",
"assets/assets/tesoro.png": "c17574eb2b0cd2a429b647e8d65feade",
"assets/FontManifest.json": "c75f7af11fb9919e042ad2ee704db319",
"assets/fonts/MaterialIcons-Regular.otf": "49e83bec6ae15b13e7661763f29cc6b4",
"assets/NOTICES": "8bb0a8449770272ad9ad06db6ce30c1a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "1fcba7a59e49001aa1b4409a25d425b0",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "b2703f18eee8303425a5342dba6958db",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "5b8d20acec3e57711717f61417c1be44",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "28e9c6457fa81a39b3ae68fa073fd333",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "2e92cd0efe0a75a667e8da24c45996de",
"icons/Icon-192.png": "e9004f2757208aba13e21d95aa3b52cc",
"icons/Icon-512.png": "858d41a2a4c1a16226e7ba8fe19da8eb",
"icons/Icon-maskable-192.png": "e9004f2757208aba13e21d95aa3b52cc",
"icons/Icon-maskable-512.png": "858d41a2a4c1a16226e7ba8fe19da8eb",
"index.html": "41ac64a8083f37872978d6b86e374f49",
"/": "41ac64a8083f37872978d6b86e374f49",
"main.dart.js": "8d81efce9f0bbbf7ac3fa6bcfec5f0a8",
"manifest.json": "4b73cea05880c899ccb32858efd54926",
"version.json": "d91fb430b2fbf3ce95df2122ea14d465"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
