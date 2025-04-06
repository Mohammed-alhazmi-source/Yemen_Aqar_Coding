import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtention<T extends String> on T {
  ///Number with suffix 10k,10M ,1b
  String priceFormat({
    required BuildContext context,
    bool? enabled,
  }) {
    final numericValue = double.parse(this);
    var formattedNumber = '';
    if (AppSettings.priceFormat != null && enabled == true) {
      // buildFormatter.format(AppSettings.priceFormat!, value: numericValue);
      formattedNumber = formattedNumber = NumberFormat.compact(
        locale: AppSettings.priceFormat,
      ).format(numericValue);
    } else {
      if (numericValue % 1 == 0) {
        /// If the numeric value is an integer, show it without decimal places
        formattedNumber = NumberFormat('##,###,###').format(numericValue);
      } else {
        // If the numeric value has decimal places, format it with 2 decimal digits
        formattedNumber = NumberFormat('##,###').format(numericValue);
      }
    }
    return formattedNumber;
  }

  double toDouble() {
    return double.parse(this);
  }
}
