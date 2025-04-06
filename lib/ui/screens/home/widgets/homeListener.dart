import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebroker/data/cubits/home_page_data_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_nearby_property_cubit.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageStateListener {
  Connectivity connectivity = Connectivity();
  bool isNetworkAvailable = true;
  bool isNearbyPropertiesEmpty = false;
  bool isHomePageDataEmpty = false;

  void init(
    void Function(VoidCallback vc) setState, {
    required VoidCallback onNetAvailable,
  }) {
    connectivity.onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        isNetworkAvailable = false;
        setState(() {});
      } else {
        onNetAvailable.call();
        isNetworkAvailable = true;
        setState(() {});
      }
    });
  }

  void setNetworkState(setState, isAvailable) {
    isNetworkAvailable = isAvailable;
    setState(() {});
  }

  HomeScreenDataBinding listen(BuildContext context) {
    var hasNearbyPropertyError = false;
    var homePageDataError = false;

    final nearbyPropertiesWatch =
        context.watch<FetchNearbyPropertiesCubit>().state;
    final homePageDataWatch = context.watch<FetchHomePageDataCubit>().state;

    if (homePageDataWatch is FetchHomePageDataSuccess) {
      homePageDataError = false;
      isHomePageDataEmpty =
          homePageDataWatch.homePageDataModel.agentsList.isEmpty;
    }
    if (nearbyPropertiesWatch is FetchNearbyPropertiesSuccess) {
      isNearbyPropertiesEmpty = nearbyPropertiesWatch.properties.isEmpty;
    }

    if (homePageDataWatch is FetchHomePageDataFailure) {
      homePageDataError = true;
    }

    if (nearbyPropertiesWatch is FetchNearbyPropertiesFailure) {
      hasNearbyPropertyError = true;
    }

    final dataAvailability = DataAvailibility(
      isHomePageDataEmpty: homePageDataError,
      isNearbyPropertiesEmpty: isNearbyPropertiesEmpty,
    );
    ({
      'hasHomePageDataError': homePageDataError,
      'hasNearbyPropertyError': hasNearbyPropertyError,
    }).mlog('HomeScreenState');
    if ((homePageDataError || hasNearbyPropertyError) && isNetworkAvailable) {
      return HomeScreenDataBinding(
        state: HomeScreenDataState.fail,
        dataAvailability: dataAvailability,
      );
    } else if (homePageDataError) {
      return HomeScreenDataBinding(
        state: HomeScreenDataState.success,
        dataAvailability: dataAvailability,
      );
    } else if (isHomePageDataEmpty) {
      return HomeScreenDataBinding(
        state: HomeScreenDataState.nodata,
        dataAvailability: dataAvailability,
      );
    } else if (!isNetworkAvailable) {
      return HomeScreenDataBinding(
        state: HomeScreenDataState.nointernet,
        dataAvailability: dataAvailability,
      );
    } else {
      return HomeScreenDataBinding(
        state: HomeScreenDataState.normal,
        dataAvailability: dataAvailability,
      );
    }
  }
}

enum HomeScreenDataState { normal, success, nodata, nointernet, fail }

class DataAvailibility {
  DataAvailibility({
    required this.isHomePageDataEmpty,
    required this.isNearbyPropertiesEmpty,
  });

  final bool isHomePageDataEmpty;
  final bool isNearbyPropertiesEmpty;

  @override
  String toString() {
    return 'DataAvailibility(isHomePageDataEmpty: $isHomePageDataEmpty, isNearbyPropertiesEmpty: $isNearbyPropertiesEmpty)';
  }
}

class HomeScreenDataBinding {
  HomeScreenDataBinding({
    required this.state,
    required this.dataAvailability,
  });

  final HomeScreenDataState state;
  final DataAvailibility dataAvailability;

  @override
  String toString() =>
      'HomeScreenDataBinding(state: $state, dataAvailability: $dataAvailability)';
}
