import 'package:ebroker/data/model/home_page_data_model.dart';
import 'package:ebroker/exports/main_export.dart';

class HomeScreenDataRepository {
  Future<({HomePageDataModel homepageDataModel})> fetchAllHomePageData() async {
    final result = await Api.get(
      url: Api.homePageData,
    );
    final data = result['data'] as Map<String, dynamic>;

    return (homepageDataModel: HomePageDataModel.fromJson(data));
  }
}
