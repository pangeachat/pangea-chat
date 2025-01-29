'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"main.dart.js_225.part.js": "4e9775fddfa341431713c59915d23864",
"main.dart.js_266.part.js": "1404581e565b1d84fbc3fd054a92d860",
"main.dart.js_270.part.js": "33e41094be3e3b3444281110e7c8d4f8",
"main.dart.js_237.part.js": "6f8ad8d7e9a813166c459d393a3efc91",
"main.dart.js_268.part.js": "99715067022396d0a63f3d7114affabc",
"main.dart.js_257.part.js": "c29bfbf6eea0745d9940736b88cae7b9",
"main.dart.js_263.part.js": "b94c9e5f6eaab2f3c29d4ea2757651c7",
"main.dart.js_230.part.js": "aa6581fff6982eb7259b714dd9a6445e",
"main.dart.js_261.part.js": "1b6fd41a5d6c16eb0742b6b0e66e0bb6",
"main.dart.js_241.part.js": "313b08222f6a413a21353420f42a2718",
"main.dart.js_249.part.js": "2ace6e1d2ebcccd5326efcaf8e56b24d",
"main.dart.js_243.part.js": "849398a45d6f5af0ef520082a5b17fd5",
"main.dart.js_209.part.js": "3a327cfe25d3217243339c954de0e998",
"main.dart.js_216.part.js": "5fab3012f00ce3fd9a1c14dd49413e37",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"main.dart.js_284.part.js": "54760d0cd48e5dd59954ad2697848aa4",
"main.dart.js_265.part.js": "fb014a7ec6f63eb6cc66042e3464c5fc",
"main.dart.js_217.part.js": "f212df097afc55c1fb7675457586d07c",
"splash/splash.js": "c6a271349a0cd249bdb6d3c4d12f5dcf",
"splash/img/dark-2x.png": "ef4801be19d1bf6976fd9d25e0450d4f",
"splash/img/light-4x.png": "ead87864be6b8f2f3efbb04acd30549d",
"splash/img/light-3x.png": "16878fb08884c14b4d8971feec70a8b3",
"splash/img/dark-3x.png": "16878fb08884c14b4d8971feec70a8b3",
"splash/img/light-1x.png": "92fff8efa59621bf2b218b65a7f64014",
"splash/img/dark-4x.png": "ead87864be6b8f2f3efbb04acd30549d",
"splash/img/dark-1x.png": "92fff8efa59621bf2b218b65a7f64014",
"splash/img/light-2x.png": "ef4801be19d1bf6976fd9d25e0450d4f",
"splash/style.css": "adebf1d2354fbed5890fff78eac514ee",
"main.dart.js_250.part.js": "a440800e4e6896137b8802c32adb1859",
"main.dart.js_262.part.js": "afdd44525299b7db68293f7c7e30a0a8",
"main.dart.js_15.part.js": "581db796e393d0b1de19c688def525c6",
"main.dart.js_275.part.js": "902c606b3ed104330d401e58bc780b87",
"main.dart.js_282.part.js": "c1f1ab5a7e79e6c8d58ba77490f49fbe",
"main.dart.js_276.part.js": "765af90d9506457bf80d80ca98498457",
"main.dart.js_227.part.js": "ae71462ba0ab719025b1dfd66b068325",
"main.dart.js_218.part.js": "8d6d6eac92b8832ff2682bef9284460a",
"icons/Icon-512.png": "391892c6f6720429a9d4f93ec1ce5f4e",
"icons/Icon-192.png": "97f7226b0a52c22cfe1557cecce6763e",
"main.dart.js_269.part.js": "309a01d209ccf914e8b2f55a78b5ea48",
"version.json": "924d8161f67d9b8acfc65923051cc53c",
"flutter_bootstrap.js": "865b2ed022e347f6ca4decb7b0dc89ad",
"main.dart.js_183.part.js": "ad81bd8658ea2ec9440033ec304ff0d0",
"main.dart.js_235.part.js": "8c10bc99224da027185688a4cdaa7ce2",
"main.dart.js_264.part.js": "de71f7d4cb42e08d31cc931fe155845e",
"main.dart.js_195.part.js": "ef18ecc59e0433d6bd1e65624b5ab98b",
"manifest.json": "cc4b6aa791018840b65fd0b0e325b201",
"main.dart.js_259.part.js": "d98bbcd42b243fd71308f2d39565daad",
"main.dart.js_229.part.js": "d81d6933b6478acf30d2c8546ec9c5ff",
"main.dart.js_279.part.js": "49cfd10ac1e44daa1eb3eed8d1c7bf8e",
"main.dart.js_280.part.js": "2716920c0d7899ffcadfcf6bfdbd87c3",
"main.dart.js_231.part.js": "b4935799a3bdae340259e713748e1fe4",
"main.dart.js": "ac0da079e9b5dab114307d56e1a151cb",
"main.dart.js_277.part.js": "7b5e2fc26956eb042e1b0f5357d8e903",
"main.dart.js_2.part.js": "603b68b336f53340312f5012d6817c78",
"main.dart.js_252.part.js": "5d6e9db79f63f2687788bc13edb57b9d",
"main.dart.js_232.part.js": "a55eeee6f58f8ece3cd549af3cabbfd7",
"main.dart.js_281.part.js": "76f853c2aab94f7c6b1190728bf4146c",
"main.dart.js_204.part.js": "7c05a5e044d276629813db644fab871b",
"index.html": "c0e585fee6d8bd59c6971e082993a2cb",
"/": "c0e585fee6d8bd59c6971e082993a2cb",
"main.dart.js_271.part.js": "56850114b720293bf7a77218f5095bb0",
"main.dart.js_1.part.js": "164ad74021d62dfc826543df1288061f",
"main.dart.js_197.part.js": "3d3a5f5cef0f8d6a21e6441b9511c697",
"main.dart.js_283.part.js": "36f2786bb453d7ec048aca16df9e3d96",
"assets/AssetManifest.json": "e8b3e5e6f907524b85153319e6339173",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/Inconsolata/Inconsolata-Regular.ttf": "e264f34eef25b5af18c240ecfca2d67b",
"assets/fonts/Inconsolata/Inconsolata-Light.ttf": "aff8f4d4930b9e50eae584d911c309a4",
"assets/fonts/Inconsolata/Inconsolata-Bold.ttf": "aa0f2ec17a4ba3e47bbc7ce533a93f50",
"assets/fonts/Roboto/RobotoMono-Regular.ttf": "7e173cf37bb8221ac504ceab2acfb195",
"assets/fonts/Roboto/Roboto-Italic.ttf": "cebd892d1acfcc455f5e52d4104f2719",
"assets/fonts/Roboto/Roboto-Regular.ttf": "8a36205bd9b83e03af0591a004bc97f4",
"assets/fonts/Roboto/Roboto-Bold.ttf": "b8e42971dec8d49207a8c8e2b919a6ac",
"assets/fonts/MaterialIcons-Regular.otf": "bd1f849f8cc8d502e3bd7b69b792b351",
"assets/AssetManifest.bin": "a9ed80d3f18d780e7d1ef2a9b10d8e02",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/handy_window/assets/handy-window.css": "0434ee701235cf1c72458fd4ce022a64",
"assets/packages/handy_window/assets/handy-window-dark.css": "45fb3160206a5f74c0a9f1763c00c372",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "7ba744177a326ef1e00f5dec6858a2ff",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf": "9f548f4965ec7e71b409ca4bf9ebb0b9",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsOutlined.ttf": "5e0aee7f6c191c6ed4c9b37853c3ac97",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsSharp.ttf": "3fcc569133fef05385aac13b534a1e9c",
"assets/FontManifest.json": "f7d8ef1fadf1a919c27f3608ce039ba6",
"assets/AssetManifest.bin.json": "f6e45c6ebfa394d446ab0f5767c45409",
"assets/NOTICES": "26314d8c2b1651a25f5b525bfd696069",
"assets/assets/js/package/olm.wasm": "1bee19214b0a80e2f498922ec044f470",
"assets/assets/js/package/olm.js": "1c13112cb119a2592b9444be60fdad1f",
"assets/assets/js/package/olm_legacy.js": "89449cce143a94c311e5d2a8717012fc",
"assets/assets/logo_transparent.png": "f00cda39300c9885a7c9ae52a65babbf",
"assets/assets/logo.png": "d329be9cd7af685717f68e03561f96c0",
"assets/assets/pangea/logo.png": "b43f03f8ba56de7226362a15fb3f762d",
"assets/assets/pangea/bot_faces/shocked.png": "1110398010407ece6e8d221dc9ad1831",
"assets/assets/pangea/bot_faces/pangea_bot.riv": "c68676f3009c2f0e66388f2377a6c491",
"assets/assets/pangea/bot_faces/addled.png": "7a8daa6873d3b53890863275b55e4011",
"assets/assets/pangea/bot_faces/left.png": "16235bc7d7f423ac351c1d98ee9a69c5",
"assets/assets/pangea/bot_faces/right.png": "80012f010e49e293e4ddb4aa9edc5b16",
"assets/assets/pangea/bot_faces/surprised.png": "2a7351fe2b7b6d64b63bc7d6f7160677",
"assets/assets/pangea/bot_faces/down.png": "f54059b94b20848cb653663368f9567d",
"assets/assets/pangea/google.svg": "6d16705367d9de665135bff410f6ff7b",
"assets/assets/pangea/Avatar_1.png": "69a9cc8b0ea1f99c2fefc5930141c0ba",
"assets/assets/pangea/Avatar_5.png": "85d39fdfb0e0c22ad31a3eba16eddaaf",
"assets/assets/pangea/Avatar_2.png": "a60b04b8f2e3b6187a39e7ead45b876a",
"assets/assets/pangea/PangeaChat_Glow_Logo.png": "d05cd7ec95208479d61bac9de8a25383",
"assets/assets/pangea/Avatar_3.png": "913618723d7fc57512335fa0ed347704",
"assets/assets/pangea/Avatar_4.png": "2f9397700c5f6d7d1d4ccc7c3de1eed5",
"assets/assets/pangea/pangea_logo.svg": "0104ecf95f749a4e0d4ac1154c5bb097",
"assets/assets/pangea/apple.svg": "c0ab9806f89b13b542a1438b1226ef9d",
"assets/assets/sas-emoji.json": "b9d99fc6dda6a3250af57af969b4a02d",
"assets/assets/sounds/click.mp3": "4d465388e5b6012bfca2ef65733a9e51",
"assets/assets/sounds/notification.ogg": "d928d619828e6dbccf6e9e40f1c99d83",
"assets/assets/sounds/call.ogg": "7e8c646f83fba83bfb9084dc1bfec31e",
"assets/assets/sounds/WoodenBeaver_stereo_message-new-instant.ogg": "88fb9823caeb64edffd343530fae9e8b",
"assets/assets/sounds/phone.ogg": "5c8fb947eb92ca55229cb6bbf533c40f",
"assets/assets/info-logo.png": "9d1d72596564e6639fd984fea2dfd048",
"assets/assets/logo.svg": "d042b70cf11a41f2764028e85b07a00a",
"assets/assets/start_chat.png": "5f236310a0ac655505862b9d6a11056a",
"assets/assets/login_wallpaper.png": "26cbc6c27b3939434fbed6564bd2b169",
"assets/assets/banner.png": "4a005db27a8787aea061537223dabb7d",
"assets/assets/banner_transparent.png": "364e2030f739bf0c7ed1c061c4cb5901",
"assets/assets/colors.png": "fde0db0023d9fc4b7c96a8114e9329bb",
"assets/assets/encryption.png": "85367d8a3630d5791124f10a63e7f9d1",
"assets/assets/favicon.png": "3ea6cdc2aeab08defd0659bad734a69b",
"main.dart.js_185.part.js": "a40b5d03a6a74f3348bfea0feff7e52a",
"main.dart.js_196.part.js": "2b54c3dd5ac527fd8f8a05a31a994522",
"main.dart.js_220.part.js": "8c1894da2cc2757ebc240e1ba3b2f5d0",
"auth.html": "88530dca48290678d3ce28a34fc66cbd",
"main.dart.js_242.part.js": "4735904693dd76685b3499f1ddd13b1b",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"favicon.png": "37d87985849bc680fe47a9330c3ea67e"};
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
