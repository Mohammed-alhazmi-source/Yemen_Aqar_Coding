import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/Extensions/lib/map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PersonalizedFeedAction { add, edit, get }

class PersonalizedFeedRepository {
  Future<void> addOrUpdate({
    required PersonalizedFeedAction action,
    required List<int> categoryIds,
    List<int>? outdoorFacilityList,
    RangeValues? priceRange,
    List<int>? selectedPropertyType,
    String? city,
  }) async {
    ////List to String
    final categoryStringArray = categoryIds.join(',');
    final outdoorFacilityStringArray = outdoorFacilityList?.join(',') ?? '';
    final priceRangeString = '${priceRange?.start},${priceRange?.end}';
    var propertyTypeString = '';
    if (selectedPropertyType!.length > 1) {
      propertyTypeString = '';
    } else {
      propertyTypeString = selectedPropertyType.join(',');
    }

    final parameters = <String, dynamic>{
      'category_ids': categoryStringArray,
      'outdoor_facilitiy_ids': outdoorFacilityStringArray,
      'price_range': priceRangeString,
      'property_type': propertyTypeString,
      'city': city?.toLowerCase(),
    }..removeEmptyKeys();

    final result = await Api.post(
      url: Api.personalisedFields,
      parameter: parameters,
    );

    try {
      personalizedInterestSettings =
          PersonalizedInterestSettings.fromMap(result['data']);
    } catch (e) {
      // TODO(R): handle error
    }
  }

  Future<void> clearPersonalizedSettings(BuildContext context) async {
    try {
      unawaited(Widgets.showLoader(context));
      postFrame((t) async {
        await Api.delete(url: Api.personalisedFields);
      });

      Widgets.hideLoder(context);
      Navigator.pop(context);
      await HelperUtils.showSnackBarMessage(
        context,
        'Successfully cleared',
        type: MessageType.success,
      );
      personalizedInterestSettings = PersonalizedInterestSettings.empty();
    } catch (e) {
      Widgets.hideLoder(context);
      await HelperUtils.showSnackBarMessage(
        context,
        'Error while clearing settings',
      );
    }
  }

  Future<PersonalizedInterestSettings> getUserPersonalizedSettings() async {
    try {
      final userPersonalization = await Api.get(
        url: Api.personalisedFields,
      );

      return PersonalizedInterestSettings.fromMap(
        userPersonalization['data'],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching personalized settings $e');
      }
      return PersonalizedInterestSettings.empty();
    }
  }

  Future<DataOutput<PropertyModel>> getPersonalizedProeprties({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getUserRecommendation,
      queryParameters: {
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }
}
