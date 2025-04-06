import 'dart:convert';

import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/data/model/house_type.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HouseTypeState {}

class HouseTypeInitial extends HouseTypeState {}

class HouseTypeFetchProgress extends HouseTypeState {}

class HouseTypeFetchSuccess extends HouseTypeState {
  HouseTypeFetchSuccess(this.houseTypelist);
  List<HouseType> houseTypelist = [];
}

class ChangeSelectedHouseType extends HouseTypeState {
  ChangeSelectedHouseType(this.selectedHouseType);
  HouseType selectedHouseType;
}

class HouseTypeFetchFailure extends HouseTypeState {
  HouseTypeFetchFailure(this.errmsg);
  final String errmsg;
}

class HouseTypeCubit extends Cubit<HouseTypeState> {
  HouseTypeCubit() : super(HouseTypeInitial());

  void fetchHouseType(BuildContext context) {
    emit(HouseTypeFetchProgress());
    fetchHouseTypeFromDb(context)
        .then((value) => emit(HouseTypeFetchSuccess(value)))
        .catchError((e) => emit(HouseTypeFetchFailure(e.toString())));
  }

  void changeSelectedHouseType(HouseType houseType) {
    emit(ChangeSelectedHouseType(houseType));
  }

  Future<List<HouseType>> fetchHouseTypeFromDb(BuildContext context) async {
    var housetypelist = <HouseType>[];
    final body = <String, String>{};

    final response = await HelperUtils.sendApiRequest(
      Api.apiGetHouseType,
      body,
      true,
      context,
    );
    final getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        final List<Map<String, dynamic>> list = getdata['data'];

        housetypelist = list.map<HouseType>(HouseType.fromJson).toList();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException('nodatafound'.translate(context));
        },
      );
    }

    return housetypelist;
  }
}
