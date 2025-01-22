'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-512.png": "391892c6f6720429a9d4f93ec1ce5f4e",
"icons/Icon-192.png": "97f7226b0a52c22cfe1557cecce6763e",
"main.dart.js_258.part.js": "0c54ab8cc551174b1c02aa4c461f5eeb",
"main.dart.js_228.part.js": "8a4d9aa0de759d00a5f70b4a3bf9b483",
"main.dart.js_15.part.js": "01dc03823947a94a98cd0108555d7564",
"main.dart.js_280.part.js": "ec683ba8cd171c64951bd3dfb3ac57d4",
"main.dart.js_186.part.js": "66d21a99d7f2c75651cec8ddbca04371",
"main.dart.js_219.part.js": "19ee71a779cff6b4c78654d05406aefe",
"assets/assets/logo.png": "d329be9cd7af685717f68e03561f96c0",
"assets/assets/login_wallpaper.png": "26cbc6c27b3939434fbed6564bd2b169",
"assets/assets/banner.png": "4a005db27a8787aea061537223dabb7d",
"assets/assets/encryption.png": "85367d8a3630d5791124f10a63e7f9d1",
"assets/assets/logo.svg": "d042b70cf11a41f2764028e85b07a00a",
"assets/assets/info-logo.png": "9d1d72596564e6639fd984fea2dfd048",
"assets/assets/sounds/click.mp3": "4d465388e5b6012bfca2ef65733a9e51",
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
"assets/AssetManifest.bin": "a9ed80d3f18d780e7d1ef2a9b10d8e02",
"assets/NOTICES": "9f22c3533f1722a9157a97005bb098eb",
"assets/AssetManifest.json": "e8b3e5e6f907524b85153319e6339173",
"assets/fonts/Roboto/RobotoMono-Regular.ttf": "7e173cf37bb8221ac504ceab2acfb195",
"assets/fonts/Roboto/Roboto-Bold.ttf": "b8e42971dec8d49207a8c8e2b919a6ac",
"assets/fonts/Roboto/Roboto-Regular.ttf": "8a36205bd9b83e03af0591a004bc97f4",
"assets/fonts/Roboto/Roboto-Italic.ttf": "cebd892d1acfcc455f5e52d4104f2719",
"assets/fonts/MaterialIcons-Regular.otf": "d096d520565224f172cc231a212a0093",
"assets/fonts/Inconsolata/Inconsolata-Light.ttf": "aff8f4d4930b9e50eae584d911c309a4",
"assets/fonts/Inconsolata/Inconsolata-Regular.ttf": "e264f34eef25b5af18c240ecfca2d67b",
"assets/fonts/Inconsolata/Inconsolata-Bold.ttf": "aa0f2ec17a4ba3e47bbc7ce533a93f50",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/packages/record_web/assets/js/record.fixwebmduration.js": "1f0108ea80c8951ba702ced40cf8cdce",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsOutlined.ttf": "4361d277bc227526ee0b759e058f9a44",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsSharp.ttf": "3fcc569133fef05385aac13b534a1e9c",
"assets/packages/material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf": "af39579772d86f79d056e4cacdca9ebd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "7ba744177a326ef1e00f5dec6858a2ff",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/handy_window/assets/handy-window-dark.css": "45fb3160206a5f74c0a9f1763c00c372",
"assets/packages/handy_window/assets/handy-window.css": "0434ee701235cf1c72458fd4ce022a64",
"assets/FontManifest.json": "f7d8ef1fadf1a919c27f3608ce039ba6",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "f6e45c6ebfa394d446ab0f5767c45409",
"version.json": "1d3faba0fe117c8d165b576b17251ce0",
"manifest.json": "cc4b6aa791018840b65fd0b0e325b201",
"main.dart.js_278.part.js": "c8d0c968372ae85bb818512d360cbccb",
"main.dart.js_210.part.js": "681a06d42545793fa8a9c8100abc39fc",
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
"main.dart.js_262.part.js": "ccaf1e56b240b764ed91cbbc3df8e67f",
"main.dart.js_265.part.js": "9f993d849728213cfe6f7ba57ee04fb5",
"main.dart.js_285.part.js": "90e421ebbebe6e152e51c4d27f7fdc7a",
"main.dart.js_205.part.js": "8949a8b1f7221257feb4105d3da11a61",
"main.dart.js_269.part.js": "2a5956c43b0633d4f2baacbf29a84c21",
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
"main.dart.js_250.part.js": "be8e4b5dd8e6ffeaa48067315f181ff9",
"main.dart.js_230.part.js": "79ff7ff222f00c1a6a7212af266b6580",
"main.dart.js_196.part.js": "56a297cbbac89b357c74e3666e8d79c5",
"main.dart.js_238.part.js": "8dc076a0333dc61071d15c4025045fad",
"main.dart.js_2.part.js": "f756038caf79f9717d88a10b4c720b5a",
"main.dart.js_243.part.js": "64e885e0185d69e0b6ef12868bcd07fa",
"main.dart.js_283.part.js": "5c2e8fe9650bcc4c0060e36caac5fc25",
"main.dart.js_242.part.js": "7fa5223c1a47675b2b216b35aff4cb94",
"auth.html": "88530dca48290678d3ce28a34fc66cbd",
"main.dart.js_198.part.js": "f1362e61f3d86021c32740290b8b4dd0",
"main.dart.js_277.part.js": "a83907beeab32638a72f8dc30309bad3",
"main.dart.js_260.part.js": "b97370b9347decbdbb3a35700a4fe5f2",
"main.dart.js_276.part.js": "72a05319b114869f069c09037d11e2f4",
"main.dart.js_267.part.js": "2f541888665ebc4c17c14d514c9eafa3",
"main.dart.js_266.part.js": "57a66edd01faefebdf7e585a586a85cf",
"index.html": "a12da67e99acff10fba4c7e52c79e709",
"/": "a12da67e99acff10fba4c7e52c79e709",
"main.dart.js_251.part.js": "dfa89fcac69fe69d62ed16ef5c0a24da",
"main.dart.js_272.part.js": "b5488422374155ead128743706ae0cfb",
"main.dart.js_284.part.js": "ed17146e5ce690077dd4d63c06784b32",
"main.dart.js_217.part.js": "0bf0053fd918072ea9b6e9aea8593f7b",
"main.dart.js_1.part.js": "4b1a289960d537e58628f047a2e164f3",
"main.dart.js_244.part.js": "deb9ecd5947aed701f8dc8c0b5a762ec",
"main.dart.js_253.part.js": "e9d8853e6b6ea1b857511945d7d90803",
"main.dart.js_263.part.js": "1fc3c393179b943b6250a76f09aaf358",
"main.dart.js_282.part.js": "57c2ad71d930e1b6a7d7698a35484a73",
"main.dart.js_231.part.js": "d3ebf47a29b3bde25da990a009a45f75",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"main.dart.js_218.part.js": "00fff4076196fe666ecd4ebb7f1ae978",
"main.dart.js_270.part.js": "e90f3d0f7b3b72b4dc2a09076a5322c0",
"main.dart.js_264.part.js": "09e13d1ef2155c4457849e052bf785ec",
"favicon.png": "37d87985849bc680fe47a9330c3ea67e",
"main.dart.js_236.part.js": "e6ab5051b5a194ba60515447f210a52c",
"main.dart.js_233.part.js": "ef77a6b7b7e2549b690d046697131266",
"main.dart.js_271.part.js": "9121065b7c1b53dcce84edadce8a7029",
"main.dart.js_184.part.js": "be59fabb1612797ccb5e315fa493c277",
"flutter_bootstrap.js": "c536349e51c150df8bb7906628c2abce",
"main.dart.js": "c5ba6db61daba5aee20cdbad9ec3dd67",
"main.dart.js_232.part.js": "773c7ef264246a6b78c7ca7310266d97",
"main.dart.js_226.part.js": "26526180a2124d374eae0dc0b5187ecc",
"main.dart.js_221.part.js": "9be0459ed82802964635e8d39f873bd4",
"main.dart.js_197.part.js": "d4188776b03cbe3249710475f9fede6c",
"main.dart.js_281.part.js": "eb0c6420718c6219803636f369d644b1"};
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
