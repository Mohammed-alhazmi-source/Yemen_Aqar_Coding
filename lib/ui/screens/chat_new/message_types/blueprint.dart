import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

enum MessageSendStatus { progress, success, fail }

abstract class Message {
  Message();
  abstract String type;
  String id = '';
  bool? isSent;
  bool isSentByMe = false;
  bool isSentNow = false;
  ChatMessageModel? message;
  BuildContext? context;

  @override
  String toString() {
    return 'Message{type: $type, id: $id}';
  }

  void init() {}
  void dispose() {}
  void onRemove() {}

  void setContext(BuildContext context) {
    this.context = context;
  }

  Widget render(BuildContext context);
}

class MessageAction {
  MessageAction({required this.action, required this.message});
  final String action;
  final Message message;
}

class MessageId {
  MessageId(this.id);
  factory MessageId.empty(String id) {
    return MessageId(id);
  }
  factory MessageId.senderId(String id) {
    return MessageId(id);
  }
  final String id;
}
