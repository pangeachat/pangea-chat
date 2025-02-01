import 'dart:convert';
import 'dart:developer';

import 'package:fluffychat/pangea/common/config/environment.dart';
import 'package:fluffychat/pangea/common/network/urls.dart';
import 'package:fluffychat/pangea/common/utils/error_handler.dart';
import 'package:fluffychat/pangea/morphs/default_morph_mapping.dart';
import 'package:fluffychat/pangea/morphs/morph_models.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

import '../common/network/requests.dart';

class MorphsRepo {
  static final GetStorage _morphsStorage = GetStorage('morphs_storage');

  static void set(String languageCode, MorphsByLanguage response) {
    _morphsStorage.write(
      languageCode,
      response.toJson(),
    );
  }

  static MorphsByLanguage fromJson(Map<String, dynamic> json) {
    return MorphsByLanguage.fromJson(json);
  }

  static Future<MorphsByLanguage> _fetch(String languageCode) async {
    final Requests req = Requests(
      choreoApiKey: Environment.choreoApiKey,
      accessToken: MatrixState.pangeaController.userController.accessToken,
    );

    final Response res = await req.get(
      url: '${PApiUrls.morphFeaturesAndTags}/$languageCode',
    );

    final decodedBody = jsonDecode(utf8.decode(res.bodyBytes));
    final response = MorphsRepo.fromJson(decodedBody);

    set(languageCode, response);

    return response;
  }

  /// this function fetches the morphs for a given language code
  /// while remaining synchronous by using a default value
  /// if the morphs are not yet fetched. we'll see if this works well
  /// if not, we can make it async and update uses of this function
  /// to be async as well
  static MorphsByLanguage get([String? languageCode]) {
    languageCode ??=
        MatrixState.pangeaController.languageController.userL2?.langCode;

    if (languageCode == null) {
      debugger(when: kDebugMode);
      return defaultMorphMapping;
    }

    final cachedJson = _morphsStorage.read(languageCode);
    if (cachedJson != null) {
      return MorphsRepo.fromJson(cachedJson);
    }

    _fetch(languageCode).catchError((e, s) {
      debugger(when: kDebugMode);
      ErrorHandler.logError(
        e: e,
        s: s,
        data: {
          "languageCode": languageCode,
        },
      );
    });

    return defaultMorphMapping;
  }
}
