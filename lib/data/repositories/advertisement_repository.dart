import 'dart:io';

import 'package:dio/dio.dart';

import 'package:ebroker/utils/api.dart';

class AdvertisementRepository {
  Future<Map<String, dynamic>> create({
    required String type,
    required String propertyId,
    File? image,
  }) async {
    final parameters = <String, dynamic>{
      Api.propertyId: propertyId,
      Api.type: type,
    };
    if (image != null) {
      parameters[Api.image] = await MultipartFile.fromFile(image.path);
    }

    return Api.post(
      url: Api.storeAdvertisement,
      parameter: parameters,
    );
  }

  Future deleteAdvertisment(
    dynamic id,
  ) async {
    await Api.post(
      url: Api.deleteAdvertisement,
      parameter: {Api.id: id},
    );
  }
}
