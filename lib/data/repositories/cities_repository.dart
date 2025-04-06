import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class CitiesRepository {
  Future<DataOutput<City>> fetchAllCities({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getCitiesData,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );
    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<City>(City.fromMap)
        .toList();
    return DataOutput(total: response['total'], modelList: modelList);
  }
}
