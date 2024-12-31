'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-512.png": "391892c6f6720429a9d4f93ec1ce5f4e",
"icons/Icon-192.png": "97f7226b0a52c22cfe1557cecce6763e",
"main.dart.js_228.part.js": "46d25caab18e59b6ec9d1fdbe9083ec6",
"main.dart.js_15.part.js": "97b2a40f20767adc1279759de24c4db5",
"main.dart.js_280.part.js": "a0e6843fcc7469fd4a5df6bb3a5f7509",
"main.dart.js_275.part.js": "dba5bbb8d111b962aad7fad94d7ae699",
"main.dart.js_219.part.js": "977092e9bffe8a0eec6d554c11c38820",
"main.dart.js_257.part.js": "a97f37fd80f7fe734df2aa882f50f937",
"assets/assets/logo.png": "d329be9cd7af685717f68e03561f96c0",
"assets/assets/login_wallpaper.png": "26cbc6c27b3939434fbed6564bd2b169",
"assets/assets/banner.png": "4a005db27a8787aea061537223dabb7d",
"assets/assets/encryption.png": "85367d8a3630d5791124f10a63e7f9d1",
"assets/assets/logo.svg": "d042b70cf11a41f2764028e85b07a00a",
"assets/assets/info-logo.png": "9d1d72596564e6639fd984fea2dfd048",
"assets/assets/sounds/click.ogg": "55b01190a0276b809e45f59d37923d1b",
"assets/assets/sounds/call.ogg": "7e8c646f83fba83bfb9084dc1bfec31e",
"assets/assets/sounds/phone.ogg": "5c8fb947eb92ca55229cb6bbf533c40f",
"assets/assets/sounds/notification.ogg": "d928d619828e6dbccf6e9e40f1c99d83",
"assets/assets/sounds/WoodenBeaver_stereo_message-new-instant.ogg": "88fb9823caeb64edffd343530fae9e8b",
"assets/assets/pangea/google.svg": "6d16705367d9de665135bff410f6ff7b",
"assets/assets/pangea/pangea_logo.svg": "0104ecf95f749a4e0d4ac1154c5bb097",
"assets/assets/pangea/logo.png": "b43f03f8ba56de7226362a15fb3f762d",
"assets/assets/pangea/bot_faces/left.png": "16235bc7d7f423ac351c1d98ee9a69c5",
"assets/assets/pangea/bot_faces/right.png": "80012f010e49e293e4ddb4aa9edc5b16",
"assets/assets/pangea/bot_faces/down.png": "f54059b94b20848cb653663368f9567d",
"assets/assets/pangea/bot_faces/surprised.png": "2a7351fe2b7b6d64b63bc7d6f7160677",
"assets/assets/pangea/bot_faces/shocked.png": "1110398010407ece6e8d221dc9ad1831",
"assets/assets/pangea/bot_faces/addled.png": "7a8daa6873d3b53890863275b55e4011",
"assets/assets/pangea/bot_faces/pangea_bot.riv": "c68676f3009c2f0e66388f2377a6c491",
"assets/assets/pangea/Avatar_4.png": "2f9397700c5f6d7d1d4ccc7c3de1eed5",
"assets/assets/pangea/Avatar_2.png": "a60b04b8f2e3b6187a39e7ead45b876a",
"assets/assets/pangea/Avatar_1.png": "69a9cc8b0ea1f99c2fefc5930141c0ba",
"assets/assets/pangea/Avatar_5.png": "85d39fdfb0e0c22ad31a3eba16eddaaf",
"assets/assets/pangea/PangeaChat_Glow_Logo.png": "d05cd7ec95208479d61bac9de8a25383",
"assets/assets/pangea/apple.svg": "c0ab9806f89b13b542a1438b1226ef9d",
"assets/assets/pangea/Avatar_3.png": "913618723d7fc57512335fa0ed347704",
"assets/assets/start_chat.png": "5f236310a0ac655505862b9d6a11056a",
"assets/assets/sas-emoji.json": "b9d99fc6dda6a3250af57af969b4a02d",
"assets/assets/banner_transparent.png": "364e2030f739bf0c7ed1c061c4cb5901",
"assets/assets/favicon.png": "3ea6cdc2aeab08defd0659bad734a69b",
"assets/assets/logo_transparent.png": "f00cda39300c9885a7c9ae52a65babbf",
"assets/assets/colors.png": "fde0db0023d9fc4b7c96a8114e9329bb",
"assets/assets/js/package/olm.wasm": "1bee19214b0a80e2f498922ec044f470",
"assets/assets/js/package/olm_legacy.js": "89449cce143a94c311e5d2a8717012fc",
"assets/assets/js/package/olm.js": "1c13112cb119a2592b9444be60fdad1f",
"assets/AssetManifest.bin": "d63f93b4a9fe1c27f02f407fe6ae9110",
"assets/NOTICES": "0a1110b2c2b2ec51a5d2bf9c1e7658a9",
"assets/AssetManifest.json": "efba14f98cad6695423a8815f75d19ce",
"assets/fonts/Roboto/RobotoMono-Regular.ttf": "7e173cf37bb8221ac504ceab2acfb195",
"assets/fonts/Roboto/Roboto-Bold.ttf": "b8e42971dec8d49207a8c8e2b919a6ac",
"assets/fonts/Roboto/Roboto-Regular.ttf": "8a36205bd9b83e03af0591a004bc97f4",
"assets/fonts/Roboto/Roboto-Italic.ttf": "cebd892d1acfcc455f5e52d4104f2719",
"assets/fonts/MaterialIcons-Regular.otf": "c866eacf28681836fe0b46bb03bf5b72",
"assets/fonts/Inconsolata/Inconsolata-Light.ttf": "aff8f4d4930b9e50eae584d911c309a4",
"assets/fonts/Inconsolata/Inconsolata-Regular.ttf": "e264f34eef25b5af18c240ecfca2d67b",
"assets/fonts/Inconsolata/Inconsolata-Bold.ttf": "aa0f2ec17a4ba3e47bbc7ce533a93f50",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsOutlined.ttf": "27a2136ebf37ab90f4897eea8987e1cd",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsSharp.ttf": "3fcc569133fef05385aac13b534a1e9c",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf": "af39579772d86f79d056e4cacdca9ebd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "7ba744177a326ef1e00f5dec6858a2ff",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/handy_window/assets/handy-window-dark.css": "45fb3160206a5f74c0a9f1763c00c372",
"assets/packages/handy_window/assets/handy-window.css": "0434ee701235cf1c72458fd4ce022a64",
"assets/FontManifest.json": "f7d8ef1fadf1a919c27f3608ce039ba6",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "326b7c4bada57fb192850d6388dad6f1",
"main.dart.js_185.part.js": "5c3ed90e5e601c85491ac2fe42680cf3",
"version.json": "41037669de50eae7d4679fd222e4b896",
"manifest.json": "cc4b6aa791018840b65fd0b0e325b201",
"main.dart.js_248.part.js": "52e4f075408f650f586a92c43da13fee",
"main.dart.js_278.part.js": "b902b47c17f1450e79d46170f06a441b",
"main.dart.js_255.part.js": "8757063cd62ba3a0944d992c20acea56",
"main.dart.js_216.part.js": "168fe39d1504ffed957fcdf832ee1543",
"main.dart.js_227.part.js": "5f680eb1633b7ca5f8ef3d21bce071c2",
"main.dart.js_279.part.js": "080edb5bd7827534a612726887b1b1d5",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"main.dart.js_273.part.js": "aba5ea1bbdf825e5cffe0e144082ef99",
"main.dart.js_262.part.js": "720e156da75c87bb182f10c2bfcde331",
"main.dart.js_247.part.js": "ec587f1094c6552ff16da1388df16b99",
"main.dart.js_269.part.js": "1eb87a1a16ed0b846c9c012d806518a6",
"splash/img/dark-4x.png": "ead87864be6b8f2f3efbb04acd30549d",
"splash/img/dark-2x.png": "ef4801be19d1bf6976fd9d25e0450d4f",
"splash/img/light-2x.png": "ef4801be19d1bf6976fd9d25e0450d4f",
"splash/img/dark-3x.png": "16878fb08884c14b4d8971feec70a8b3",
"splash/img/dark-1x.png": "92fff8efa59621bf2b218b65a7f64014",
"splash/img/light-3x.png": "16878fb08884c14b4d8971feec70a8b3",
"splash/img/light-1x.png": "92fff8efa59621bf2b218b65a7f64014",
"splash/img/light-4x.png": "ead87864be6b8f2f3efbb04acd30549d",
"splash/style.css": "adebf1d2354fbed5890fff78eac514ee",
"splash/splash.js": "c6a271349a0cd249bdb6d3c4d12f5dcf",
"main.dart.js_235.part.js": "a233ac4ef81f72b3c6879713734c7ea1",
"main.dart.js_250.part.js": "162e7315d81d9b69db67b98c17470f7b",
"main.dart.js_230.part.js": "6dff0727f492502866fd2d054b77081f",
"main.dart.js_223.part.js": "d479f76aeafdf16233b960c780cc9be3",
"main.dart.js_196.part.js": "ed18210e91c52b8adcbdadac525f2ae3",
"main.dart.js_2.part.js": "f756038caf79f9717d88a10b4c720b5a",
"auth.html": "88530dca48290678d3ce28a34fc66cbd",
"main.dart.js_277.part.js": "444cbd5118c2d3634406be6dbad4423d",
"main.dart.js_260.part.js": "e3d2f769741a87164a19168582e48730",
"main.dart.js_240.part.js": "1f6e6dbb956854c82d21a733dcb32005",
"main.dart.js_261.part.js": "b91d66b028fdef7920fc9bb1017c205c",
"main.dart.js_267.part.js": "c234b24ca9d8012638dff98ef2270643",
"main.dart.js_266.part.js": "046182b5195d06468c1dc6762ab989a0",
"index.html": "14229537ed0a233cf3a9a38854fe32fb",
"/": "14229537ed0a233cf3a9a38854fe32fb",
"main.dart.js_215.part.js": "e2a1c6c1e28ca8b0e725b9771fe91aff",
"main.dart.js_217.part.js": "f060ab9bad405ea247ad69dffe9a2aca",
"main.dart.js_1.part.js": "ce997cf51dee3373a550950e6fe2e665",
"main.dart.js_259.part.js": "28b4c40218c73a7c5a4a568a34b7b56d",
"main.dart.js_239.part.js": "01be02c49cae5e8e239c0e700414760a",
"main.dart.js_268.part.js": "d8a3f72d12ec8c6d31dcefd197400f12",
"main.dart.js_229.part.js": "86b2b2e702c9525ad8be1b1dbf4053e9",
"main.dart.js_263.part.js": "98dbbb1204f41d576c51c99844220f0b",
"main.dart.js_282.part.js": "f974167300c23f1ce5a5e9b9da90f117",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"main.dart.js_183.part.js": "d45805d2feab6b5d454477ca00ecc090",
"main.dart.js_264.part.js": "8eccbd40fe12e86f36fd4c3007a8ae59",
"favicon.png": "37d87985849bc680fe47a9330c3ea67e",
"main.dart.js_241.part.js": "d2b73bdfdcbe257bea452bed43fdd2ae",
"main.dart.js_225.part.js": "01e8ab4e0585a0e9339205287ffbeda2",
"main.dart.js_233.part.js": "3725b39e88edf3a7f78906aadfd8c7ee",
"main.dart.js_204.part.js": "a301dd453377c1d7603861a5d7fc27f5",
"flutter_bootstrap.js": "5367ae2cb8c0942015ade7787e935ff2",
"main.dart.js_209.part.js": "193034851fdf889d7b6b97dee82ebeca",
"main.dart.js": "9dcee9b6df055fa2f1989a52c9418d76",
"main.dart.js_197.part.js": "db915db38adf4a5f9573719616efa58b",
"main.dart.js_195.part.js": "ef48983cb2ffb47a5c963b28ca969644",
"main.dart.js_274.part.js": "b261d353bddcdf0e512af19f4d8c3fe7",
"main.dart.js_281.part.js": "29d8dd60fb3fdeb38c081d9a6d0efe8a"};
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
