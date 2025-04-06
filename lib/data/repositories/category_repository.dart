import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class CategoryRepository {
  Future<DataOutput<Category>> fetchCategories({
    required int offset,
    int? id,
  }) async {
    final parameters = <String, dynamic>{
      if (id != null) 'id': id,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
    };
    try {
      final response = await Api.get(
        url: Api.apiGetCategories,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List).map(
        (e) {
          return Category.fromJson(e);
        },
      ).toList();
      return DataOutput(total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      rethrow;
    }
  }
}
