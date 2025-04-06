import 'dart:convert';

import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/data/model/notification_data.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationSetProgress extends NotificationState {}

class NotificationSetSuccess extends NotificationState {
  NotificationSetSuccess(this.notificationlist);
  List<NotificationData> notificationlist = [];
}

class NotificationSetFailure extends NotificationState {
  NotificationSetFailure(this.errmsg);
  final String errmsg;
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void getNotification(
    BuildContext context,
  ) {
    emit(NotificationSetProgress());
    getNotificationFromDb(
      context,
    )
        .then((value) => emit(NotificationSetSuccess(value)))
        .catchError((e) => emit(NotificationSetFailure(e.toString())));
  }

  Future<List<NotificationData>> getNotificationFromDb(
    BuildContext context,
  ) async {
    final body = <String, String>{};
    var notificationList = <NotificationData>[];
    final response = await HelperUtils.sendApiRequest(
      Api.apiGetNotificationList,
      body,
      false,
      context,
    );
    final getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        final List<Map<String, dynamic>> list = getdata['data'];
        notificationList =
            list.map<NotificationData>(NotificationData.fromJson).toList();
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
    return notificationList;
  }
}
