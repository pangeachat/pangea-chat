import 'dart:convert';

import 'package:fluffychat/pangea/config/environment.dart';
import 'package:fluffychat/pangea/network/requests.dart';
import 'package:fluffychat/pangea/network/urls.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionController {
  static Future<AppVersionResponse> getAppVersion(
    String accessToken,
  ) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final currentBuildNumber = packageInfo.buildNumber;

    final Requests request = Requests(
      choreoApiKey: Environment.choreoApiKey,
      accessToken: accessToken,
    );

    final Response res = await request.post(
      url: PApiUrls.appVersion,
      body: {
        "current_version": currentVersion,
        "current_build_number": currentBuildNumber,
      },
    );

    final Map<String, dynamic> json = jsonDecode(res.body);

    return AppVersionResponse.fromJson(json);
  }
}

class AppVersionResponse {
  AppVersionResponse();

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) {
    return AppVersionResponse();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
