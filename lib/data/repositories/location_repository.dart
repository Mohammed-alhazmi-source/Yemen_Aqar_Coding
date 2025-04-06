// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:ebroker/data/model/google_place_model.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class GooglePlaceRepository {
  //This will search places from google place api
  //We use this to search location while adding new property
  Future<List<GooglePlaceModel>> serchCities(String text) async {
    try {
      ///
      ///************************ */
      final queryParameters = <String, dynamic>{
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        Api.type: '(cities)',
        'language': 'en',
      };

      ///************************ */

      final apiResponse = await Api.get(
        url: Api.placeAPI,
        useAuthToken: false,
        useBaseUrl: false,
        queryParameters: queryParameters,
      );
      return _buildPlaceModelList(apiResponse);
    } catch (e) {
      if (e is DioException) {}
      throw ApiException(e.toString());
    }
  }

  ///this will convert normal response to List of models so we can use it easily in code
  List<GooglePlaceModel> _buildPlaceModelList(
    Map<String, dynamic> apiResponse,
  ) {
    ///loop throuh predictions list,
    ///this will create List of GooglePlaceModel
    try {
      final List<dynamic> predictions = apiResponse['predictions'];
      final filteredResult = predictions.map((prediction) {
        final String description = prediction['description'];
        final String placeId = prediction['place_id'];

        final List<dynamic> terms = prediction['terms'];
        final String city = terms.firstWhere(
              (term) => term['value'] != null,
              orElse: () => {},
            )['value'] ??
            '';
        final String state = terms.length > 1 ? terms[1]['value'] : '';
        final String country = terms.length > 2 ? terms[2]['value'] : '';

        return GooglePlaceModel(
          city: city,
          description: description,
          placeId: placeId,
          state: state,
          country: country,
          latitude: '',
          longitude: '',
        );
      }).toList();

      return filteredResult;
    } catch (e) {
      rethrow;
    }
  }

  String getLocationComponent(Map details, String component) {
    final index = (details['types'] as List)
        .indexWhere((element) => element == component);
    if ((details['terms'] as List).length > index) {
      return (details['terms'] as List).elementAt(index)['value'];
    } else {
      return '';
    }
  }

  ///Google Place Autocomplete api will give us Place Id.
  ///We will use this place id to get Place Details
  Future<dynamic> getPlaceDetailsFromPlaceId(String placeId) async {
    final queryParameters = <String, dynamic>{
      Api.placeApiKey: Constant.googlePlaceAPIkey,
      Api.placeid: placeId,
      'language': 'en',
    };
    final response = await Api.get(
      url: Api.placeApiDetails,
      queryParameters: queryParameters,
      useBaseUrl: false,
      useAuthToken: false,
    );

    return response['result']['geometry']['location'];
  }
}
