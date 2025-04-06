import 'package:ebroker/data/model/agent/agents_properties_models/category_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/gallery_property.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/parameters_property.dart';

class PropertiesData {
  const PropertiesData({
    required this.id,
    required this.slugId,
    required this.city,
    required this.state,
    required this.country,
    required this.price,
    required this.categoryId,
    required this.propertyType,
    required this.title,
    required this.titleImage,
    required this.isPremium,
    required this.address,
    required this.addedBy,
    required this.promoted,
    required this.isFavourite,
    required this.category,
    required this.parameters,
    required this.gallery,
  });

  PropertiesData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        slugId = json['slug_id']?.toString() ?? '',
        city = json['city']?.toString() ?? '',
        state = json['state']?.toString() ?? '',
        country = json['country']?.toString() ?? '',
        price = json['price']?.toString() ?? '',
        categoryId = json['category_id'] as int,
        propertyType = json['property_type']?.toString() ?? '',
        title = json['title']?.toString() ?? '',
        titleImage = json['title_image']?.toString() ?? '',
        isPremium = json['is_premium'] as int,
        address = json['address']?.toString() ?? '',
        addedBy = json['added_by'] as int,
        promoted = json['promoted'] as bool,
        isFavourite = json['is_favourite'] as int,
        category = CategoryData.fromJson(
          json['category'] as Map<String, dynamic>,
        ),
        parameters = (json['parameters'] as List)
            .cast<Map<String, dynamic>>()
            .map<ParametersData>(ParametersData.fromJson)
            .toList(),
        gallery = (json['gallery'] as List?)
                ?.map<GalleryProperty>(
                  (e) => GalleryProperty.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [];

  final int id;
  final String slugId;
  final String city;
  final String state;
  final String country;
  final String price;
  final int categoryId;
  final String propertyType;
  final String title;
  final String titleImage;
  final int isPremium;
  final String address;
  final int addedBy;
  final bool promoted;
  final int isFavourite;
  final CategoryData category;
  final List<ParametersData> parameters;
  final List<GalleryProperty> gallery;
}
