import 'package:ebroker/exports/main_export.dart';

class SystemRepository {
  Future<Map> fetchSystemSettings({
    required bool isAnonymouse,
  }) async {
    final parameters = <String, dynamic>{};

    ///Passing user id here because we will hide sensitive details if there is no user id,
    ///With user id we will get user subscription package details

    final response = await Api.get(
      url: Api.apiGetAppSettings,
      queryParameters: parameters,
      useAuthToken: !isAnonymouse,
    );

    return response;
  }
}
