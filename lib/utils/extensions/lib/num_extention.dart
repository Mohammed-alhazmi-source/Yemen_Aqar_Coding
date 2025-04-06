import 'package:intl/intl.dart';

extension NUMEXT on num {
  String numPriceFormate({bool? disabled}) {
    final formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 2,
      symbol:
          '', // if you want to add currency symbol then pass that in this else leave it empty.
    ).format(this);

    if (disabled == true) {
      return toString();
    }

    return formattedNumber;
  }

  // clamp(lowerLimit, upperLimit)
}
