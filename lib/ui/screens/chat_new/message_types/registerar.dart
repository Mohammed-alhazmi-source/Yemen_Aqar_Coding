import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/audio_message.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/file_message.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/text_and_file.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/text_message.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:ebroker/utils/context_menu.dart';
import 'package:flutter/material.dart';

class MessageType {
  final List<Message> _messageTypes = [
    TextMessage(),
    AudioMessage(),
    FileMessage(),
    FileAndText(),
  ];

  Message? get(String type) {
    return _messageTypes.where((element) => element.type == type).first;
  }
}

Message filterMessageType(ChatMessageModel data) {
  return MessageType().get(data.chatMessageType!)!;
}

class ChatMessageHandler {
  static final List<String> sentMessageIds = [];
  static final List<Message> _messages = [];
  static BuildContext? messageContext;
  static final StreamController<MessageAction> _messageStream =
      StreamController<MessageAction>.broadcast();
  static final StreamController<List<Message>> _allMessageStream =
      StreamController<List<Message>>.broadcast();

  static Stream<List<Message>> listenMessages() {
    return _allMessageStream.stream;
  }

  static Future<void> add(ChatMessageModel data) async {
    try {
      final message = filterMessageType(data);

      message
        ..isSentByMe = data.isSentByMe ?? false
        ..isSentNow = data.isSentNow ?? false
        ..message = data
        ..isSent = true == data.isSentByMe
            ? sentMessageIds.contains(message.id)
            : null;

      ///This is to determine which messages are sent..because in flutter reverse list view there is issue of calling initstate of another instance
      if (!sentMessageIds.contains(message.id) &&
          message.isSentByMe &&
          message.isSentNow) {
        sentMessageIds.add(message.id);
      }

      ///this is to resolve flutter's strange issue of not calling init state
      if (message.type == 'audio') {
        if (messageContext!.mounted) {
          message.setContext(messageContext!);
        }

        message.init();
      }

      _messageStream.sink.add(MessageAction(action: 'add', message: message));
    } catch (e) {
      log('Error is >>>>>>>>>>>>>>>$e');
    }
  }

  static Future<void> remove(dynamic id) async {
    try {
      final messageIndex = _messages.indexWhere((element) {
        return element.id == id;
      });
      final deleatableMessage = _messages[messageIndex];
      _messageStream.sink.add(
        MessageAction(
          action: 'remove',
          message: deleatableMessage,
        ),
      );
    } catch (e) {
      log('ERROR IS $e');
    }
  }

  static void flush() {
    _messages.clear();
  }

  static void fillMessages(List<Message> messages) {
    _messages.addAll(messages);

    ///this will call init state of the audio element when loading which we are not calling in render method so here we have to call it
    for (final element in messages) {
      if (element.type == 'audio') {
        element.init();
      }
    }
    _allMessageStream.sink.add(messages);
  }

  static void syncMessages() {
    _allMessageStream.sink.add(_messages);
  }

  static void handle() {
    _messageStream.stream.listen(
      (MessageAction messageAction) {
        if (messageAction.action == 'add') {
          _messages.insert(0, messageAction.message);
          syncMessages();
        }
        if (messageAction.action == 'remove') {
          messageAction.message.onRemove();
          _messages.remove(messageAction.message);
          syncMessages();
        }
      },
    );
  }
}

///This class is using for render changes and
class RenderMessage extends StatefulWidget {
  const RenderMessage({required this.message, key}) : super(key: key);
  final Message message;

  @override
  MessageRenderState<RenderMessage> createState() => _RenderMessageState();
}

class _RenderMessageState extends MessageRenderState<RenderMessage>
    with AutomaticKeepAliveClientMixin {
  Widget? render;

  @override
  void initState() {
    // if (isRendered()) {

    if (context.mounted) {
      ChatMessageHandler.messageContext = context;
    }

    widget.message.setContext(context);
    if (widget.message.type != 'audio') {
      widget.message.init();
    }
    // }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      widget.message.setContext(context);
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ContextMenuRegion(
      contextMenuBuilder: (context, offset) {
        return AdaptiveTextSelectionToolbar(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: offset,
          ),
          children: <Widget>[
            if (widget.message.type == 'text' ||
                widget.message.type == 'file_and_text')
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: widget.message.type == 'file_and_text'
                          ? widget.message.message!.message.toString()
                          : widget.message.message!.message.toString(),
                    ),
                  );
                  ContextMenuController.removeAny();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: CustomText('Text copied to clipboard')),
                  );
                },
                child: Container(
                  color: context.color.brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: CustomText(
                      'Copy${widget.message.type == "file_and_text" ? " Text" : ""}',
                      color: context.color.inverseSurface),
                ),
              ),
            if (widget.message.isSentByMe)
              GestureDetector(
                onTap: () {
                  ChatMessageHandler.remove(widget.message.id);
                  ContextMenuController.removeAny();
                },
                child: Container(
                  color: context.color.brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
                  padding: const EdgeInsets.all(8),
                  child:
                      CustomText('Delete', color: context.color.inverseSurface),
                ),
              ),
          ],
        );
      },
      child: Builder(
        builder: (ctx) {
          return widget.message.render(context);
        },
      ),
    );
  }

  @override
  // TODO(R): implement wantKeepAlive
  bool get wantKeepAlive => false;
}

abstract class MessageRenderState<T extends StatefulWidget> extends State<T> {
  static List renderedMessage = [];

  bool isRendered() {
    if (renderedMessage.contains(widget.key)) {
      return true;
    } else {
      renderedMessage.add(widget.key);
      return false;
    }
  }
}
