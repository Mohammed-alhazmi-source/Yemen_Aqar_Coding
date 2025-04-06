import 'package:dio/dio.dart';
import 'package:ebroker/data/model/chat/chated_user_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';

class ChatRepository {
  BuildContext? setContext0;

  Future<void> setContext(BuildContext context) async => setContext0 = context;

  Future<DataOutput<ChatedUser>> fetchChatList(int pageNumber) async {
    final response = await Api.get(
      url: Api.getChatList,
      queryParameters: {
        'page': pageNumber,
        'per_page': Constant.loadLimit,
      },
    );

    final modelList = (response['data'] as List).map((e) {
      return ChatedUser.fromJson(e);
    }).toList();

    return DataOutput(total: response['total_page'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<Message>> getMessages({
    required int page,
    required int userId,
    required int propertyId,
  }) async {
    final response = await Api.get(
      url: Api.getMessages,
      queryParameters: {
        'user_id': userId,
        'property_id': propertyId,
        'page': page,
        'per_page': Constant.minChatMessages,
      },
    );
    final modelList = (response['data']['data'] as List).map(
      (result) {
        //Creating model
        final chatMessageModel = ChatMessageModel.fromJson(result);
        chatMessageModel
          ..setIsSentByMe(
            HiveUtils.getUserId() == chatMessageModel.senderId.toString(),
          )
          ..setIsSentNow(false)
          ..date = result['created_at'];
        //Creating message widget
        final message = filterMessageType(chatMessageModel)
          ..isSentByMe = chatMessageModel.isSentByMe ?? false
          ..isSentNow = chatMessageModel.isSentNow ?? false
          ..message = chatMessageModel;

        return message;
      },
    ).toList();

    return DataOutput(total: response['total_page'] ?? 0, modelList: modelList);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String recieverId,
    required String? message,
    required String proeprtyId,
    MultipartFile? audio,
    MultipartFile? attachment,
  }) async {
    final parameters = <String, dynamic>{
      'sender_id': senderId,
      'receiver_id': recieverId,
      'message': message,
      'property_id': proeprtyId,
      'file': attachment,
      'audio': audio,
    };
    if (message == null) {
      parameters.remove('message');
    }
    if (attachment == null) {
      parameters.remove('file');
    }
    if (audio == null) {
      parameters.remove('audio');
    }
    final map = await Api.post(
      url: Api.sendMessage,
      parameter: parameters,
    );

    print('Output of send message is : $map');
    return map;
  }

  Future<Map<String, dynamic>> blockUser({
    required String userId,
    required String reason,
  }) async {
    final parameters = <String, dynamic>{
      'to_user_id': userId,
      'to_admin': userId == '0' ? '1' : '0',
      'reason': reason,
    };
    if (userId != '0') {
      parameters.remove('to_admin');
    }
    final map = await Api.post(
      url: Api.blockUser,
      parameter: parameters,
    );

    print('Output of block user is : $map');
    return map;
  }

  Future<Map<String, dynamic>> unblockUser({
    required String userId,
  }) async {
    final parameters = <String, dynamic>{
      'to_user_id': userId,
      'to_admin': userId == '0' ? '1' : '0',
    };
    if (userId != '0') {
      parameters.remove('to_admin');
    }
    final map = await Api.post(
      url: Api.unblockUser,
      parameter: parameters,
    );

    print('Output of unblock user is : $map');
    return map;
  }
}
