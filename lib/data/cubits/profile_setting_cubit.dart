import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProfileSettingState {}

class ProfileSettingInitial extends ProfileSettingState {}

class ProfileSettingFetchProgress extends ProfileSettingState {}

class ProfileSettingFetchSuccess extends ProfileSettingState {
  ProfileSettingFetchSuccess({required this.data});

  String data;
}

class ProfileSettingFetchFailure extends ProfileSettingState {
  ProfileSettingFetchFailure(this.errmsg);
  final dynamic errmsg;
}

class ProfileSettingCubit extends Cubit<ProfileSettingState> {
  ProfileSettingCubit() : super(ProfileSettingInitial());

  Future<void> fetchProfileSetting(
    BuildContext context,
    String title, {
    bool? forceRefresh,
  }) async {
    if (forceRefresh != true) {
      if (state is ProfileSettingFetchSuccess) {
        await Future.delayed(
          const Duration(seconds: AppSettings.hiddenAPIProcessDelay),
        );
      } else {
        emit(ProfileSettingFetchProgress());
      }
    } else {
      emit(ProfileSettingFetchProgress());
    }

    if (forceRefresh == true) {
      await fetchProfileSettingFromDb(context, title).then((value) {
        emit(ProfileSettingFetchSuccess(data: value ?? ''));
      }).catchError((e, stack) {
        emit(ProfileSettingFetchFailure(e));
      });
    } else {
      if (state is! ProfileSettingFetchSuccess) {
        await fetchProfileSettingFromDb(context, title).then((value) {
          emit(ProfileSettingFetchSuccess(data: value ?? ''));
        }).catchError((e, stack) {
          emit(ProfileSettingFetchFailure(e));
        });
      } else {
        emit(
          ProfileSettingFetchSuccess(
            data: (state as ProfileSettingFetchSuccess).data,
          ),
        );
      }
    }
  }

  Future<String?> fetchProfileSettingFromDb(
    BuildContext context,
    String title,
  ) async {
    try {
      String? profileSettingData;
      final body = <String, String>{
        Api.type: title,
      };

      final response = await Api.get(
        url: Api.apiGetAppSettings,
        queryParameters: body,
        useAuthToken: false,
      );

      if (!response[Api.error]) {
        if (title == Api.currencySymbol) {
          // Constant.currencySymbol = getdata['data'].toString();
        } else if (title == Api.maintenanceMode) {
          Constant.maintenanceMode = response['data'].toString();
        } else {
          final Map data = response['data'];

          if (title == Api.termsAndConditions) {
            profileSettingData = data['terms_conditions'];
            // .where((element) => element['type'] == "terms_conditions")
            // .first['data'];
          }

          if (title == Api.privacyPolicy) {
            profileSettingData = data['privacy_policy'];
            // .where((element) => element['type'] == "privacy_policy")
            // .first['data'];
          }

          if (title == Api.aboutApp) {
            profileSettingData = data['about_us'];
            // .where((element) => element['type'] == "about_us")
            // .first['data'];
          }
        }
      } else {
        throw CustomException(response[Api.message]);
      }

      return profileSettingData;
    } catch (e) {
      rethrow;
    }
  }
}
