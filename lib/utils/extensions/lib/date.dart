extension D on String {
  DateTime parseAsDate() {
    return DateTime.parse(this);
  }
}

extension DT on DateTime {
  bool isSameDate(DateTime date2) {
    return year == date2.year && month == date2.month && day == date2.day;
  }
}
