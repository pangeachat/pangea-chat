import 'dart:convert';

import 'package:fluffychat/pangea/network/urls.dart';
import 'package:fluffychat/pangea/repo/lemma_definition/lemma_definition_request.dart';
import 'package:fluffychat/pangea/repo/lemma_definition/lemma_definition_response.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../config/environment.dart';
import '../../network/requests.dart';

class LemmaDictionaryRepo {
  // In-memory cache with timestamps
  static final Map<LemmaDefinitionRequest, LemmaDefinitionResponse> _cache = {};
  static final Map<LemmaDefinitionRequest, DateTime> _cacheTimestamps = {};

  static const Duration _cacheDuration = Duration(days: 2);

  static Future<LemmaDefinitionResponse> get(
    LemmaDefinitionRequest request,
  ) async {
    _clearExpiredEntries();

    // Check the cache first
    if (_cache.containsKey(request)) {
      // If the request has feedback, remove it from the cache
      if (request.feedback != null) {
        debugPrint('Removing request from cache');
        _cache.remove(request);

        assert(!_cache.containsKey(request));

        // otherwise, return the cached response
      } else {
        return _cache[request]!;
      }
    }

    final Requests req = Requests(
      choreoApiKey: Environment.choreoApiKey,
      accessToken: MatrixState.pangeaController.userController.accessToken,
    );

    final requestBody = request.toJson();
    final Response res = await req.post(
      url: PApiUrls.lemmaDictionary,
      body: requestBody,
    );

    final decodedBody = jsonDecode(utf8.decode(res.bodyBytes));
    final response = LemmaDefinitionResponse.fromJson(decodedBody);

    // Store the response and timestamp in the cache
    _cache[request] = response;
    _cacheTimestamps[request] = DateTime.now();

    return response;
  }

  /// From the cache, get a random set of cached definitions that are not for a specific lemma
  static List<String> getDistractorDefinitions(
    String lemma,
    int count,
  ) {
    _clearExpiredEntries();

    final List<String> definitions = [];
    for (final entry in _cache.entries) {
      if (entry.key.lemma != lemma) {
        definitions.add(entry.value.definition);
      }
    }

    definitions.shuffle();

    return definitions.take(count).toList();
  }

  static void _clearExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheDuration)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
}
