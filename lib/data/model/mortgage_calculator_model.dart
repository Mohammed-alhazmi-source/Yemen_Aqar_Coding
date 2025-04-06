class MortgageCalculatorModel {
  const MortgageCalculatorModel({
    this.mainTotal,
    this.yearlyTotals = const [],
  });

  factory MortgageCalculatorModel.fromJson(Map<String, dynamic> json) {
    return MortgageCalculatorModel(
      mainTotal: json['main_total'] != null
          ? MainTotal.fromJson(json['main_total'])
          : null,
      yearlyTotals: (json['yearly_totals'] as List?)
              ?.map((v) => YearlyTotals.fromJson(v))
              .toList() ??
          [],
    );
  }
  final MainTotal? mainTotal;
  final List<YearlyTotals> yearlyTotals;

  Map<String, dynamic> toJson() => {
        if (mainTotal != null) 'main_total': mainTotal!.toJson(),
        if (yearlyTotals.isNotEmpty)
          'yearly_totals': yearlyTotals.map((v) => v.toJson()).toList(),
      };
}

class MainTotal {
  const MainTotal({
    required this.principalAmount,
    required this.downPayment,
    required this.payableInterest,
    required this.monthlyEmi,
  });

  factory MainTotal.fromJson(Map<String, dynamic> json) => MainTotal(
        principalAmount: json['principal_amount'].toString(),
        downPayment: json['down_payment'].toString(),
        payableInterest: json['payable_interest'].toString(),
        monthlyEmi: json['monthly_emi'].toString(),
      );
  final String principalAmount;
  final String downPayment;
  final String payableInterest;
  final String monthlyEmi;

  Map<String, dynamic> toJson() => {
        'principal_amount': principalAmount,
        'down_payment': downPayment,
        'payable_interest': payableInterest,
        'monthly_emi': monthlyEmi,
      };
}

class YearlyTotals {
  YearlyTotals({
    this.year,
    this.principalAmount,
    this.interestPaid,
    this.remainingBalance,
    this.monthlyTotals,
  });

  YearlyTotals.fromJson(Map<String, dynamic> json) {
    year = json['year'].toString();
    principalAmount = json['principal_amount'].toString();
    interestPaid = json['interest_paid'].toString();
    remainingBalance = json['remaining_balance'].toString();
    if (json['monthly_totals'] != null) {
      monthlyTotals = <MonthlyTotals>[];
      json['monthly_totals'].forEach((v) {
        monthlyTotals!.add(new MonthlyTotals.fromJson(v));
      });
    }
  }
  String? year;
  String? principalAmount;
  String? interestPaid;
  String? remainingBalance;
  List<MonthlyTotals>? monthlyTotals;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['year'] = year;
    data['principal_amount'] = principalAmount;
    data['interest_paid'] = interestPaid;
    data['remaining_balance'] = remainingBalance;
    if (monthlyTotals != null) {
      data['monthly_totals'] = monthlyTotals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MonthlyTotals {
  MonthlyTotals({
    this.month,
    this.principalAmount,
    this.payableInterest,
    this.remainingBalance,
  });

  MonthlyTotals.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    principalAmount = json['principal_amount'].toString();
    payableInterest = json['payable_interest'].toString();
    remainingBalance = json['remaining_balance'].toString();
  }
  String? month;
  String? principalAmount;
  String? payableInterest;
  String? remainingBalance;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['month'] = month;
    data['principal_amount'] = principalAmount;
    data['payable_interest'] = payableInterest;
    data['remaining_balance'] = remainingBalance;
    return data;
  }
}
