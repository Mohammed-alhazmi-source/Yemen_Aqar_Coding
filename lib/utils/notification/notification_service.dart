// ignore_for_file: file_names

import 'dart:developer';

import 'package:ebroker/data/model/chat/chated_user_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

String currentlyChatingWith = '';
String currentlyChatPropertyId = '';

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static LocalAwsomeNotification localNotification = LocalAwsomeNotification();

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;
  static requestPermission() async {}

  Future<void> updateFCM() async {
    await FirebaseMessaging.instance.getToken();
    // await Api.post(
    //     // url: Api.updateFCMId,
    //     parameter: {Api.fcmId: token},
    //     useAuthToken: true);
  }

  @pragma('vm:entry-point')
  static handleNotification(RemoteMessage? message, [BuildContext? context]) {
    final notificationType = message?.data['type'] ?? '';

    log('@notification data is ${message?.data}');

    if (notificationType == 'chat') {
      final senderId = message?.data['sender_id'] ?? '';
      final username = message!.data['username'];
      final propertyTitleImage = message.data['property_title_image'];
      final propertyTitle = message.data['title'];
      final userProfile = message.data['user_profile'];
      final propertyId = message.data['property_id'];

      (context!).read<GetChatListCubit>().addNewChat(
            ChatedUser(
              fcmId: '',
              firebaseId: '',
              name: username,
              profile: userProfile,
              propertyId:
                  (propertyId is int) ? propertyId : int.parse(propertyId),
              title: propertyTitle,
              userId: (senderId is int) ? senderId : int.parse(senderId),
              titleImage: propertyTitleImage,
            ),
          );

      ///Checking if this is user we are chatiing with
      if (senderId == currentlyChatingWith &&
          propertyId == currentlyChatPropertyId) {
        final chatMessageModel = ChatMessageModel.fromJson(message.data)
          ..setIsSentByMe(false)
          ..setIsSentNow(false);
        ChatMessageHandler.add(chatMessageModel);
        totalMessageCount++;
      } else {
        localNotification.createNotification(
          isLocked: false,
          notificationData: message,
        );
      }
    } else if (notificationType == 'delete_message') {
      ChatMessageHandlerOLD.removeMessage(
        id: int.parse(
          message!.data['message_id'],
        ),
      );
    } else {
      localNotification.createNotification(
        isLocked: false,
        notificationData: message!,
      );
    }
  }

  @pragma('vm:entry-point')
  static void init(context) {
    requestPermission();
    registerListeners(context);
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    if (message.notification == null) {
      handleNotification(
        message,
      );
    }
  }

  @pragma('vm:entry-point')
  static forgroundNotificationHandler(BuildContext context) async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleNotification(message, context);
    });
  }

  @pragma('vm:entry-point')
  static terminatedStateNotificationHandler(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }
        if (message.notification == null) {
          handleNotification(message, context);
        }
      },
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onTapNotificationHandler(context) async {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) async {
      if (message.data['type'] == 'chat') {
        final username = message.data['title'];
        final propertyTitleImage = message.data['property_title_image'];
        final propertyTitle = message.data['property_title'];
        final userProfile = message.data['user_profile'];
        final senderId = message.data['sender_id'];
        final propertyId = message.data['property_id'];
        final isBlockedByMe = message.data['is_blocked_by_me'];
        final isBlockedByUser = message.data['is_blocked_by_user'];
        Future.delayed(
          Duration.zero,
          () {
            Navigator.push(
              Constant.navigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (context) {
                      return LoadChatMessagesCubit();
                    },
                    child: Builder(
                      builder: (context) {
                        return ChatScreen(
                          profilePicture: userProfile ?? '',
                          userName: username ?? '',
                          propertyImage: propertyTitleImage ?? '',
                          proeprtyTitle: propertyTitle ?? '',
                          userId: senderId ?? '',
                          propertyId: propertyId ?? '',
                          isBlockedByMe: isBlockedByMe ?? false,
                          isBlockedByUser: isBlockedByUser ?? false,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      } else {
        final String id = message.data['id'] ?? '';
        final isMyProperty = message.data['added_by'] == HiveUtils.getUserId();
        final property = await PropertyRepository().fetchPropertyFromPropertyId(
            id: int.parse(id), isMyProperty: isMyProperty);
        Future.delayed(Duration.zero, () {
          HelperUtils.goToNextPage(
            Routes.propertyDetails,
            Constant.navigatorKey.currentContext!,
            false,
            args: {
              'propertyData': property,
              'fromMyProperty': false,
            },
          );
        });
      }
    }
            // if (message.data["screen"] == "profile") {
            //   Navigator.pushNamed(context, profileRoute);
            // }

            );
  }

  @pragma('vm:entry-point')
  static Future<void> registerListeners(context) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await forgroundNotificationHandler(context);
    await terminatedStateNotificationHandler(context);
    await onTapNotificationHandler(context);
  }

  static void disposeListeners() {
    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
