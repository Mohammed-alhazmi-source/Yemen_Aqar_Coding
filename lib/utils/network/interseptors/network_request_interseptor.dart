import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';

class NetworkRequestInterseptor extends Interceptor {
  int totalAPICallTimes = 0;
  var map = <String, dynamic>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data != null) {
      map = (Map.fromEntries((options.data ?? {} as FormData).fields)
        ..addEntries(Iterable.castFrom((options.data as FormData).files)));
    }
    log('${options.path} : ${options.queryParameters}', name: 'Request-API');

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ({
      'URL': err.response?.requestOptions.path ?? '',
      'Type': err.type,
      'Error': err.error,
      'Message': err.message,
    }).mlog('API-Error');

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ({
      'URL': response.requestOptions.path,
      'Method': response.requestOptions.method,
      'status': response.statusCode,
      'statusMessage': response.statusMessage,
      'response': response.data,
    }).mlog('Response-API');

    handler.next(response);
  }
}
