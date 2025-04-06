import 'package:ebroker/data/model/facilities_model.dart';
import 'package:ebroker/exports/main_export.dart';

class FacilitiesRepository {
  Future<List<FacilitiesModel>> fetchFacilities() async {
    final response = await Api.get(
      url: Api.getFacilities,
      useAuthToken: true,
    );
    return (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<FacilitiesModel>(FacilitiesModel.fromJson)
        .toList();
  }
}
