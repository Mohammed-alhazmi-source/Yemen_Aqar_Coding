import 'dart:ui';

extension ColorExt on Color {
  Color brighten(int value) {
    final color0 = this;

    final red = color0.r + value;
    final green = color0.g + value;
    final blue = color0.b + value;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }

  Color darken(int value) {
    final color0 = this;

    final red = color0.r - value;
    final green = color0.g - value;
    final blue = color0.b - value;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }
}
