// import 'dart:convert';
//
// import 'package:ebroker/data/model/property_model.dart';
// import 'package:ebroker/utils/admob/native_ad_manager.dart';
//
// class PropertyListModel implements NativeAdWidgetContainer {
//   PropertyListModel({
//     this.id,
//     this.slugId,
//     this.addedBy,
//     this.titleImage,
//     this.categoryId,
//     this.title,
//     this.price,
//     this.city,
//     this.state,
//     this.country,
//     this.rentduration,
//     this.propertyType,
//     this.assignFacilities,
//     this.gallery,
//     this.documents,
//     this.promoted,
//     this.isFavourite,
//     this.category,
//   });
//
//   PropertyListModel.fromJson(Map<String, dynamic> rawjson) {
//     id = rawjson['id'];
//     slugId = rawjson['slug_id'];
//     addedBy = rawjson['added_by'].toString();
//     titleImage = rawjson['title_image'];
//     categoryId = rawjson['category_id'];
//     title = rawjson['title'];
//     price = rawjson['price'].toString();
//     city = rawjson['city'];
//     state = rawjson['state'];
//     country = rawjson['country'];
//     rentduration = rawjson['rentduration'].toString();
//     propertyType = rawjson['property_type'];
//     assignFacilities = rawjson['assign_facilities'] == null
//         ? []
//         : List<AssignedOutdoorFacility>.from(
//             (rawjson['assign_facilities'] as List).map((x) {
//               return AssignedOutdoorFacility.fromJson(x);
//             }),
//           );
//     gallery = List<Gallery>.from(
//       (rawjson['gallery'] as List? ?? [])
//           .map((x) => Gallery.fromMap(x is String ? json.decode(x) : x)),
//     );
//     promoted = rawjson['promoted'];
//     isFavourite = rawjson['is_favourite'];
//     category = rawjson['category'] == null
//         ? null
//         : Categorys.fromMap(rawjson['category']);
//   }
//   int? id;
//   String? slugId;
//   String? addedBy;
//   String? titleImage;
//   int? categoryId;
//   String? title;
//   String? price;
//   String? city;
//   String? state;
//   String? country;
//   String? rentduration;
//   String? propertyType;
//   List<AssignedOutdoorFacility>? assignFacilities;
//   List<Gallery>? gallery;
//   List<PropertyDocuments>? documents;
//   bool? promoted;
//   int? isFavourite;
//   Categorys? category;
//
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['id'] = id;
//     data['slug_id'] = slugId;
//     data['added_by'] = addedBy;
//     data['title_image'] = titleImage;
//     data['category_id'] = categoryId;
//     data['title'] = title;
//     data['price'] = price;
//     data['city'] = city;
//     data['state'] = state;
//     data['country'] = country;
//     data['rentduration'] = rentduration;
//     data['property_type'] = propertyType;
//     if (assignFacilities != null) {
//       data['assign_facilities'] =
//           assignFacilities!.map((v) => v.toJson()).toList();
//     }
//     if (gallery != null) {
//       data['gallery'] = gallery!.map((v) => v.toJson()).toList();
//     }
//     if (documents != null) {
//       data['documents'] = documents!.map((v) => v.toJson()).toList();
//     }
//     data['promoted'] = promoted;
//     data['is_favourite'] = isFavourite;
//     if (category != null) {
//       data['category'] = category!.toJson();
//     }
//     return data;
//   }
// }
