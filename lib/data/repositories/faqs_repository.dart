import 'package:ebroker/data/model/faqs_model.dart';
import 'package:ebroker/exports/main_export.dart';

class FaqsRepository {
  Future<DataOutput<FaqsModel>> fetchAllFaqs({
    required int offset,
  }) async {
    final result = await Api.get(
      url: Api.apiGetFaqs,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );
    final modelList = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<FaqsModel>(FaqsModel.fromJson)
        .toList();

    return DataOutput(total: result['total'] ?? 0, modelList: modelList);
  }
}
