import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysInitial extends FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysInProgress
    extends FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysSuccess extends FetchMyPromotedPropertysState {
  FetchMyPromotedPropertysSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.advertisement,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<Advertisement> advertisement;
  final int offset;
  final int total;

  FetchMyPromotedPropertysSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<Advertisement>? advertisement,
    int? offset,
    int? total,
  }) {
    return FetchMyPromotedPropertysSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      advertisement: advertisement ?? this.advertisement,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchMyPromotedPropertysFailure extends FetchMyPromotedPropertysState {
  FetchMyPromotedPropertysFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchMyPromotedPropertysCubit
    extends Cubit<FetchMyPromotedPropertysState> {
  FetchMyPromotedPropertysCubit() : super(FetchMyPromotedPropertysInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> fetchMyPromotedPropertys() async {
    try {
      emit(FetchMyPromotedPropertysInProgress());

      final result = await _propertyRepository.fetchMyPromotedProeprties(
        offset: 0,
      );

      emit(
        FetchMyPromotedPropertysSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          advertisement: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchMyPromotedPropertysFailure(e));
    }
  }

  void delete(dynamic id) {
    if (state is FetchMyPromotedPropertysSuccess) {
      final propertymodel = (state as FetchMyPromotedPropertysSuccess)
          .advertisement
        ..removeWhere((element) => element.advertisementId == id);

      emit(
        (state as FetchMyPromotedPropertysSuccess)
            .copyWith(advertisement: propertymodel),
      );
    }
  }

  Future<void> fetchMyPromotedPropertysMore() async {
    try {
      if (state is FetchMyPromotedPropertysSuccess) {
        if ((state as FetchMyPromotedPropertysSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchMyPromotedPropertysSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchMyPromotedProeprties(
          offset:
              (state as FetchMyPromotedPropertysSuccess).advertisement.length,
        );

        final propertymodelState = state as FetchMyPromotedPropertysSuccess;
        propertymodelState.advertisement.addAll(result.modelList);
        emit(
          FetchMyPromotedPropertysSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            advertisement: propertymodelState.advertisement,
            offset:
                (state as FetchMyPromotedPropertysSuccess).advertisement.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchMyPromotedPropertysSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchMyPromotedPropertysSuccess) {
      return (state as FetchMyPromotedPropertysSuccess).advertisement.length <
          (state as FetchMyPromotedPropertysSuccess).total;
    }
    return false;
  }

  void update(Advertisement model) {
    if (state is FetchMyPromotedPropertysSuccess) {
      final properties =
          (state as FetchMyPromotedPropertysSuccess).advertisement;

      final index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMyPromotedPropertysSuccess)
            .copyWith(advertisement: properties),
      );
    }
  }
}

class Advertisement {
  Advertisement({
    this.id,
    this.category,
    this.slugId,
    this.title,
    this.propertyType,
    this.titleImage,
    this.price,
    this.city,
    this.state,
    this.country,
    this.advertisementId,
    this.advertisementStatus,
    this.advertisementType,
  });

  factory Advertisement.fromMap(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      category: Category.fromMap(json['category']),
      slugId: json['slug_id'],
      title: json['title'],
      propertyType: json['property_type'],
      titleImage: json['title_image'],
      price: json['price'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      advertisementId: json['advertisement_id'],
      advertisementStatus: json['advertisement_status'],
      advertisementType: json['advertisement_type'],
    );
  }
  final int? id;
  final Category? category;
  final String? slugId;
  final String? title;
  final String? propertyType;
  final String? titleImage;
  final String? price;
  final String? city;
  final String? state;
  final String? country;
  final int? advertisementId;
  final int? advertisementStatus;
  final String? advertisementType;

  Advertisement copyWith({
    int? id,
    Category? category,
    String? slugId,
    String? title,
    String? propertyType,
    String? titleImage,
    String? price,
    String? city,
    String? state,
    String? country,
    int? advertisementId,
    int? advertisementStatus,
    String? advertisementType,
  }) {
    return Advertisement(
      id: id ?? id,
      category: category ?? category,
      slugId: slugId ?? slugId,
      title: title ?? title,
      propertyType: propertyType ?? propertyType,
      titleImage: titleImage ?? titleImage,
      price: price ?? price,
      city: city ?? city,
      state: state ?? state,
      country: country ?? country,
      advertisementId: advertisementId ?? advertisementId,
      advertisementStatus: advertisementStatus ?? advertisementStatus,
      advertisementType: advertisementType ?? advertisementType,
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['category'] = category?.toMap();
    data['slug_id'] = slugId;
    data['title'] = title;
    data['property_type'] = propertyType;
    data['title_image'] = titleImage;
    data['price'] = price;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['advertisement_id'] = advertisementId;
    data['advertisement_status'] = advertisementStatus;
    data['advertisement_type'] = advertisementType;
    return data;
  }

  @override
  String toString() {
    return 'Advertisement(id: $id,category: $category, slugId: $slugId, title: $title, propertyType: $propertyType, titleImage: $titleImage, price: $price, city: $city, state: $state, country: $country, advertisementId: $advertisementId, advertisementStatus: $advertisementStatus, advertisementType: $advertisementType)';
  }
}
