class GlobalFormat {
  final List _list = [];

  GlobalFormat build(
    String locale, {
    required List<CurrencyPoint> points,
  }) {
    _list.add({'locale': locale, 'point': points});
    return this;
  }

  num _removeDecimalIfZero(double number) {
    if (number % 1 == 0) {
      return number.toInt();
    } else {
      return number;
    }
  }

  List<String> getSupported() {
    return _list.map((e) => e['locale']).toList() as List<String>;
  }

  String format(String locale, {required num value}) {
    try {
      final current =
          _list.where((element) => locale == element['locale']).toList();
      final points = current.first['point'] as List<CurrencyPoint>;
      for (final element in points) {
        if (element.toCodePoint == null) {
          if (value.toInt().toString().length == element.atPoint) {
            return '${value / element.devision} ${element.name}';
          }
        } else {
          if (value.toInt().toString().length >= element.atPoint &&
              value.toInt().toString().length <= element.toCodePoint!) {
            return '${_removeDecimalIfZero(value / element.devision)} ${element.name}';
          }
        }
      }
      return '${_removeDecimalIfZero(value.toDouble())}';
    } catch (e) {
      return '${_removeDecimalIfZero(value.toDouble())}';
    }
  }
}

class CurrencyPoint {
  CurrencyPoint(this.atPoint, this.name, {this.toCodePoint}) {
    devision = _calculateDivision();
  }
  final int atPoint;
  final String name;
  final int? toCodePoint;
  int devision = 1;
  int _calculateDivision() {
    final buffer = StringBuffer();

    for (var i = 0; i < atPoint; i++) {
      if (i == 0) {
        buffer.write('1');
      } else {
        buffer.write('0');
      }
    }
    return int.parse(buffer.toString());
  }
}

GlobalFormat formatter = GlobalFormat();
GlobalFormat buildFormatter = formatter.build(
  'en',
  points: [
    CurrencyPoint(4, 'K', toCodePoint: 6),
    CurrencyPoint(7, 'M', toCodePoint: 9),
    CurrencyPoint(10, 'B', toCodePoint: 11),
    CurrencyPoint(13, 'T', toCodePoint: 14),
  ],
).build(
  'hi',
  points: [
    CurrencyPoint(4, 'K', toCodePoint: 5),
    CurrencyPoint(6, 'Lac', toCodePoint: 7),
    CurrencyPoint(8, 'Cr', toCodePoint: 9),
    CurrencyPoint(9, 'Arb', toCodePoint: 10),
  ],
).build(
  'ar_EN',
  points: [
    CurrencyPoint(3, 'Alaf', toCodePoint: 4),
    CurrencyPoint(6, 'Milyon', toCodePoint: 7),
    CurrencyPoint(9, 'Milyar', toCodePoint: 10),
  ],
).build(
  'ar',
  points: [
    CurrencyPoint(3, 'ألف', toCodePoint: 4),
    CurrencyPoint(6, 'مليون', toCodePoint: 7),
    CurrencyPoint(9, 'مليار', toCodePoint: 10),
  ],
);

String currency(String locale, num value) {
  return buildFormatter.format(locale, value: value);
}
