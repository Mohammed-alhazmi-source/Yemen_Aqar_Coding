import 'package:ebroker/data/model/mortgage_calculator_model.dart';
import 'package:ebroker/exports/main_export.dart';

class MortgageCalculatorRepository {
  Future<MortgageCalculatorModel> fetchMortgageCalculatorData({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await Api.get(
        url: Api.apiGetMortgageCalculator,
        queryParameters: parameters,
      );

      if (response['error'] == false && response['data'] != null) {
        return MortgageCalculatorModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch mortgage data');
      }
    } catch (e) {
      throw Exception('Failed to calculate mortgage: $e');
    }
  }
}
