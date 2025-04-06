import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:flutter/material.dart';

class TextMessage extends Message {
  TextMessage() {
    id = DateTime.now().toString();
  }

  @override
  void init() {
    if (isSentNow && isSentByMe && isSent == false) {
      context?.read<SendMessageCubit>().send(
            senderId: HiveUtils.getUserId().toString(),
            recieverId: message!.receiverId!,
            attachment: message?.file,
            message: message!.message!,
            proeprtyId: message!.propertyId!,
            audio: message?.audio,
          );
    }

    ///if this message is not sent now so it will set id from server
    if (isSentNow == false) {
      id = message!.id!;
    }

    super.init();
  }

  @override
  Future<void> onRemove() async {
    await context!.read<DeleteMessageCubit>().delete(
          messageId: id,
          receiverId: message!.receiverId!,
          senderId: '',
          propertyId: '',
        );

    super.onRemove();
  }

  @override
  Widget render(BuildContext context) {
    var messageColor = context.color.textColorDark;
    if (isSentByMe) {
      messageColor = context.color.brightness == Brightness.light
          ? context.color.secondaryColor
          : context.color.textColorDark;
    }

    return Align(
      alignment: isSentByMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsetsDirectional.only(end: isSentByMe ? 0 : 10),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: context.screenWidth * 0.74),
              decoration: isSentByMe
                  ? getSentByMeDecoration(context)
                  : getOtherUserDecoration(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.screenWidth * 0.76,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomText(
                            message?.message ?? '',
                            fontSize: context.font.normal,
                            color: messageColor,
                          ),
                        ),
                      );
                    },
                  ),
                  BlocConsumer<SendMessageCubit, SendMessageState>(
                    listener: (context, state) {
                      if (state is SendMessageSuccess) {
                        id = state.messageId.toString();
                        isSent = true;
                      }
                    },
                    builder: (context, state) {
                      if (state is SendMessageInProgress) {
                        return const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.watch_later_outlined,
                            size: 10,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration getSentByMeDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.tertiaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }

  BoxDecoration getOtherUserDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.color.borderColor, width: 1.5),
    );
  }

  @override
  String type = 'text';
}
