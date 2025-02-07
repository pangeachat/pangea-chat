import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

import 'package:fluffychat/pangea/common/config/environment.dart';
import 'package:fluffychat/pangea/common/network/requests.dart';
import 'package:fluffychat/pangea/common/network/urls.dart';
import 'package:fluffychat/pangea/morphs/morph_meaning/morph_info_request.dart';
import 'package:fluffychat/pangea/morphs/morph_meaning/morph_info_response.dart';
import 'package:fluffychat/widgets/matrix.dart';

class MorphInfoRepo {
  static final GetStorage _morphMeaningStorage =
      GetStorage('morph_meaning_storage');

  static void set(MorphInfoRequest request, MorphInfoResponse response) {
    _morphMeaningStorage.write(request.storageKey, response.toJson());
  }

  static Future<MorphInfoResponse> get(
    MorphInfoRequest request,
  ) async {
    final cachedJson = _morphMeaningStorage.read(request.storageKey);

    if (cachedJson != null) {
      return MorphInfoResponse.fromJson(cachedJson);
    } else {
      debugPrint(
        'No cached response for morph ${request.morphTag}, calling API',
      );
    }

    final Requests req = Requests(
      choreoApiKey: Environment.choreoApiKey,
      accessToken: MatrixState.pangeaController.userController.accessToken,
    );

    final Response res = await req.post(
      url: PApiUrls.morphDictionary,
      body: request.toJson(),
    );

    final decodedBody = jsonDecode(utf8.decode(res.bodyBytes));
    final response = MorphInfoResponse.fromJson(decodedBody);

    set(request, response);

    return response;
  }
}
