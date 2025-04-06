import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/Network/cacheManger.dart';
import 'package:ebroker/utils/encryption/rsa.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  FetchSystemSettingsSuccess({
    required this.settings,
  });
  final Map settings;
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  FetchSystemSettingsFailure(this.errorMessage);
  final String errorMessage;
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SystemRepository _systemRepository = SystemRepository();
  Future<void> fetchSettings({
    required bool isAnonymous,
    bool? forceRefresh,
  }) async {
    try {
      await CacheData().getData(
        forceRefresh: forceRefresh == true,
        delay: 0,
        onProgress: () {
          emit(FetchSystemSettingsInProgress());
        },
        onNetworkRequest: () async {
          try {
            final settings = await _systemRepository.fetchSystemSettings(
              isAnonymouse: isAnonymous,
            );
            return settings;
          } catch (e) {
            rethrow;
          }
        },
        onOfflineData: () {
          return (state as FetchSystemSettingsSuccess).settings;
        },
        onSuccess: (Map<dynamic, dynamic>? data) {
          if (data == null) return;
          Constant.currencySymbol =
              _getSetting(data, SystemSetting.currencySymbol);
          Constant.googlePlaceAPIkey = RSAEncryption().decrypt(
            privateKey: Constant.keysDecryptionPasswordRSA,
            encryptedData: data['data']['place_api_key'],
          );
          Constant.isAdmobAdsEnabled = (data['data']['show_admob_ads'] == '1');
          Constant.adaptThemeColorSvg = (data['data']['svg_clr'] == '1');
          Constant.admobBannerAndroid =
              data['data']?['android_banner_ad_id'] ?? '';
          Constant.admobBannerIos = data['data']?['ios_banner_ad_id'] ?? '';
          Constant.admobNativeAndroid =
              data['data']?['android_native_ad_id'] ?? '';
          Constant.admobNativeIos = data['data']?['ios_native_ad_id'] ?? '';

          Constant.admobInterstitialAndroid =
              data['data']?['android_interstitial_ad_id'] ?? '';
          Constant.admobInterstitialIos =
              data['data']?['ios_interstitial_ad_id'] ?? '';

          AppSettings.playstoreURLAndroid = data['data']?['playstore_id'] ?? '';
          AppSettings.appstoreURLios = data['data']?['appstore_id'] ?? '';
          AppSettings.iOSAppId =
              (data['data']?['appstore_id'] ?? '').toString().split('/').last;
          AppSettings.otpServiceProvider =
              data['data']?['otp_service_provider'] ?? '';
          AppSettings.isVerificationRequired =
              data['data']?['verification_required_for_user'] ?? false;
          emit(FetchSystemSettingsSuccess(settings: data));
        },
        hasData: state is FetchSystemSettingsSuccess,
      );
    } catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  dynamic getSetting(SystemSetting selected) {
    if (state is FetchSystemSettingsSuccess) {
      final Map settings =
          (state as FetchSystemSettingsSuccess).settings['data'];

      if (selected == SystemSetting.languageType) {
        return settings['languages'];
      }

      if (selected == SystemSetting.demoMode) {
        if (settings.containsKey('demo_mode')) {
          return settings['demo_mode'];
        } else {
          return false;
        }
      }

      /// where selected is equals to type
      final selectedSettingData =
          settings[Constant.systemSettingKeys[selected]];

      return selectedSettingData;
    }
  }

  Map getRawSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).settings['data'];
    }
    return {};
  }

  dynamic _getSetting(Map settings, SystemSetting selected) {
    final selectedSettingData =
        settings['data'][Constant.systemSettingKeys[selected]];

    return selectedSettingData;
  }
}
