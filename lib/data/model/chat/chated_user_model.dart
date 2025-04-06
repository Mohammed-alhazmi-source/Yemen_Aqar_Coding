import 'package:flutter/material.dart';

class ChatedUser {
  ChatedUser({
    this.propertyId,
    this.title,
    this.titleImage,
    this.userId,
    this.name,
    this.profile,
    this.firebaseId,
    this.fcmId,
    this.isBlockedByMe,
    this.isBlockedByUser,
  });

  ChatedUser.fromJson(Map<String, dynamic> json, {BuildContext? context}) {
    if (context != null && json['profile'] != null && json['profile'] != '') {
      precacheImage(NetworkImage(json['profile']), context);
    }
    if (context != null &&
        json['title_image'] != null &&
        json['title_image'] != '') {
      precacheImage(NetworkImage(json['title_image']), context);
    }
    propertyId = json['property_id'];
    title = json['title'];
    titleImage = json['title_image'];
    userId = json['user_id'];

    name = json['name'];
    profile = json['profile'];
    firebaseId = json['firebase_id'];
    fcmId = json['fcm_id'];
    isBlockedByMe = json['is_blocked_by_me'];
    isBlockedByUser = json['is_blocked_by_user'];
  }
  int? propertyId;
  String? title;
  String? titleImage;
  int? userId;
  String? name;
  String? profile;
  String? firebaseId;
  String? fcmId;
  bool? isBlockedByMe;
  bool? isBlockedByUser;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['property_id'] = propertyId;
    data['title'] = title;
    data['title_image'] = titleImage;
    data['user_id'] = userId;
    data['name'] = name;
    data['profile'] = profile;
    data['firebase_id'] = firebaseId;
    data['fcm_id'] = fcmId;
    data['is_blocked_by_me'] = isBlockedByMe;
    data['is_blocked_by_user'] = isBlockedByUser;
    return data;
  }
}
