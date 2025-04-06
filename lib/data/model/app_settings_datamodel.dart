import 'dart:ui';

class AppSettingsDataModel {
  AppSettingsDataModel({
    required this.lightTertiary,
    required this.lightSecondary,
    required this.lightPrimary,
    required this.darkTertiary,
    required this.darkSecondary,
    required this.darkPrimary,
    this.placeholderLogo,
    this.appHomeScreen,
    this.isUserActive,
  });

  AppSettingsDataModel.fromJson(Map<String, dynamic> json)
      : lightTertiary = _colorFromHex(json['light_tertiary']),
        placeholderLogo = json['placeholder_logo'],
        lightSecondary = _colorFromHex(json['light_secondary']),
        lightPrimary = _colorFromHex(json['light_primary']),
        darkTertiary = _colorFromHex(json['dark_tertiary']),
        darkSecondary = _colorFromHex(json['dark_secondary']),
        darkPrimary = _colorFromHex(json['dark_primary']),
        isUserActive = json['is_active'] ?? true,
        appHomeScreen = json['app_home_screen'];
  Color lightTertiary;
  String? placeholderLogo;
  Color lightSecondary;
  Color lightPrimary;
  Color darkTertiary;
  Color darkSecondary;
  Color darkPrimary;
  String? appHomeScreen;
  bool? isUserActive;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['light_tertiary'] = _colorToHex(lightTertiary);
    data['placeholder_logo'] = placeholderLogo;
    data['light_secondary'] = _colorToHex(lightSecondary);
    data['light_primary'] = _colorToHex(lightPrimary);
    data['dark_tertiary'] = _colorToHex(darkTertiary);
    data['dark_secondary'] = _colorToHex(darkSecondary);
    data['dark_primary'] = _colorToHex(darkPrimary);
    data['app_home_screen'] = appHomeScreen;
    data['isUserActive'] = isUserActive;
    return data;
  }

  // Helper function to convert color from hex string to Color
  static Color _colorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Helper function to convert Color to hex string
  static String _colorToHex(Color color) {
    final red = (color.r * 255).toInt().toRadixString(16).substring(2);
    final green = (color.g * 255).toInt().toRadixString(16).substring(2);
    final blue = (color.b * 255).toInt().toRadixString(16).substring(2);

    return '#$red$green$blue';
  }
}
