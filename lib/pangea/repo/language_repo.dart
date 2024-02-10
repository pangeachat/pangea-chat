import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:fluffychat/pangea/models/language_model.dart';
import 'package:fluffychat/pangea/network/urls.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../config/environment.dart';
import '../network/requests.dart';

class LanguageRepo {
  static Future<List<LanguageModel>> fetchLanguages() async {
    final Requests req = Requests(baseUrl: Environment.choreoApi);
    try {
      final Response res = await req.get(url: PApiUrls.getLanguages).timeout(
          const Duration(seconds: 10)); // Set the timeout duration as needed

      final decodedBody = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      final List<LanguageModel> langFlag = decodedBody.map((e) {
        try {
          return LanguageModel.fromJson(e);
        } catch (err, stack) {
          debugger(when: kDebugMode);
          ErrorHandler.logError(e: err, s: stack, data: e);
          return LanguageModel.unknown;
        }
      }).toList();
      return langFlag;
    } on TimeoutException catch (e) {
      // Handle timeout error
      ErrorHandler.logError(e: e, s: StackTrace.current);
      // You can either return an empty list or a default set of languages
      // depending on how you want your app to handle the situation.
      return []; // or handle the error as appropriate for your application
    } catch (e, s) {
      // Handle any other errors that might occur
      ErrorHandler.logError(e: e, s: s);
      return [];
    }
  }
}
