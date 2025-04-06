enum SystemSetting {
  maintenanceMode,
  currencySymbol,
  subscription,
  privacyPolicy,
  termsConditions,
  contactUs,
  languageType,
  defaultLanguage,
  forceUpdate,
  androidVersion,
  numberWithSuffix,
  iosVersion,
  demoMode,
  language,
  numberWithOtpLogin,
  socialLogin,
  distanceOption,
  verificationStatus,
}

// {
// "company_name": "eBroker",
// "currency_symbol": "",
// "ios_version": "1.0.0",
// "default_language": "en-new",
// "force_update": "0",
// "android_version": "1.0.0",
// "number_with_suffix": "0",
// "maintenance_mode": "0",
// "company_tel1": "1234567890",
// "company_tel2": "1234567890",
// "system_version": "1.1.4",
// "company_email": "admin@gmail.com",
// "latitude": "23.232630668067518",
// "longitude": "69.6436561255738",
// "company_address": "Time Square Empire, 262-263, highway, Mirjapar, Bhuj, Mirjapar Part, Gujarat 370001",
// "place_api_key": "p6gei2ntBCYkOzK2SD7adVdqJIRSSw7zWc2vjwSBmG1gp8xMPjewOUsykSDXXOQMgUkDPYTJ8lYNC/ZrilXyDZ6PinCW9MRxqboCWuHzxS7RH5cWQt31LEMLXlOYS3eCZGnGW9iPef01DZpJsPKWXNvdTjVxMQe4Cwo+mfqGDFRkza3zztYBWUxz+5mUrRE4oIVxVc9J5+26hEIcp/BdTgM3xmqNXu0pUBkDzPjXs16duTXkfSqFRHasM6R/7ayFvLCGK+jfgmOECcjFc/T9CX2LNcbMa23r2s4Vmunapw43qrJBPwJWtSK5Oi4WYqcBhdLUgYcP/YZ43DK2crqV+g==",
// "svg_clr": "1",
// "playstore_id": "https://play.google.com/store/apps/details?id=com.ebroker.wrteam",
// "appstore_id": "https://testflight.apple.com/join/nrmIds1a",
// "seo_settings": "0",
// "show_admob_ads": "0",
// "android_banner_ad_id": "ca-app-pub-3940256099942544/6300978111",
// "ios_banner_ad_id": "ca-app-pub-3940256099942544/2934735716",
// "android_interstitial_ad_id": "ca-app-pub-3940256099942544/1033173712",
// "ios_interstitial_ad_id": "ca-app-pub-3940256099942544/4411468910",
// "android_native_ad_id": "ca-app-pub-3940256099942544/2247696110",
// "ios_native_ad_id": "ca-app-pub-3940256099942544/2521693316",
// "languages": [
// {
// "id": 1,
// "code": "en-new",
// "name": "English"
// },
// {
// "id": 7,
// "code": "URDU",
// "name": "Urdu"
// }
// ],
// }
/// we made this method because from our api all data comes in {'type':"<setting>",'data':"demo data"} this formate so we have list of these data and instead of create different methods and parse in it we have made enum and checking where condition in list
// T getSetting<T>(SystemSetting setting) {
//   if (setting == SystemSetting.subscription) {
//     if (subscription == true) {
//       return package as T;
//     } else {
//       return null as T;
//     }
//   }
//   return data!
//       .where((Data element) =>
//           element.type == Constant.systemSettingKey[setting])
//       .toList()[0] as T;
// }
