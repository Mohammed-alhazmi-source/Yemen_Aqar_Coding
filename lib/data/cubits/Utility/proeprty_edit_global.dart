import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PropertyEditGlobal {
  PropertyEditGlobal(this.list, this.ads);
  final List<PropertyModel> list;
  final List<Advertisement> ads;
}

class PropertyEditCubit extends Cubit<PropertyEditGlobal> {
  PropertyEditCubit() : super(PropertyEditGlobal([], []));

  void add(PropertyModel model) {
    final list = state.list;
    final indexOfElemeent =
        list.indexWhere((element) => element.id == model.id);
    if (indexOfElemeent != -1) list.removeAt(indexOfElemeent);

    list.add(model);
    emit(PropertyEditGlobal(list, state.ads));
  }

  PropertyModel get(PropertyModel model) {
    return state.list.firstWhere(
      (element) => element.id == model.id,
      orElse: () {
        return model;
      },
    );
  }

  Advertisement getAd(Advertisement model) {
    return state.ads.firstWhere(
      (element) => element.id == model.id,
      orElse: () {
        return model;
      },
    );
  }

  void remove() {}
}
