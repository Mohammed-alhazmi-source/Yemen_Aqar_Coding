import 'package:ebroker/data/model/agent/agents_properties_models/category_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/gallary_images.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';

class ProjectData implements NativeAdWidgetContainer {
  const ProjectData({
    required this.id,
    required this.slugId,
    required this.city,
    required this.state,
    required this.country,
    required this.title,
    required this.type,
    required this.image,
    required this.location,
    required this.galleryImages,
    required this.categoryId,
    required this.category,
  });

  ProjectData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        slugId = json['slug_id']?.toString() ?? '',
        city = json['city']?.toString() ?? '',
        state = json['state']?.toString() ?? '',
        country = json['country']?.toString() ?? '',
        title = json['title']?.toString() ?? '',
        type = json['type']?.toString() ?? '',
        image = json['image']?.toString() ?? '',
        location = json['location']?.toString() ?? '',
        category = CategoryData.fromJson(
          json['category'] as Map<String, dynamic>,
        ),
        categoryId = json['category_id'] as int,
        galleryImages = (json['gallary_images'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map<GalleryImages>(GalleryImages.fromJson)
            .toList();

  final int id;
  final String slugId;
  final String city;
  final String state;
  final String country;
  final String title;
  final String type;
  final String image;
  final String location;
  final List<GalleryImages> galleryImages;
  final int categoryId;
  final CategoryData category;
}
