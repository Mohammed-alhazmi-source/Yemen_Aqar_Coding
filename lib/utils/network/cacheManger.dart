import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:ebroker/settings.dart';

class CacheData {
  final Connectivity _connectivity = Connectivity();

  Future<void> getData<T>({
    required bool forceRefresh,
    required VoidCallback onProgress,
    required Future<T> Function() onNetworkRequest,
    required T Function() onOfflineData,
    required Function(T data) onSuccess,
    required bool hasData,
    int? delay,
  }) async {
    if (forceRefresh != true) {
      if (hasData) {
        await Future.delayed(
          Duration(seconds: delay ?? AppSettings.hiddenAPIProcessDelay),
        );
      } else {
        onProgress.call();
      }
    } else {
      onProgress.call();
    }
    if (forceRefresh) {
      final result = await onNetworkRequest.call();
      onSuccess.call(result);
    } else {
      if (!hasData) {
        final result = await onNetworkRequest.call();
        onSuccess.call(result);
      } else {
        if (await _hasInternet()) {
          final result = await onNetworkRequest.call();
          onSuccess.call(result);
        } else {
          final result = onOfflineData.call();
          onSuccess.call(result);
        }
      }
    }
  }

  Future<bool> _hasInternet() async {
    final connectionResult = await _connectivity.checkConnectivity();
    return !connectionResult.contains(ConnectivityResult.none);
  }
}
