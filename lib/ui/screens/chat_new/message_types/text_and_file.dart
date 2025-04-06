import 'dart:developer';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:timeago/timeago.dart';

class FileAndText extends Message {
  @override
  String type = 'file_and_text';

  List<String> imageExtensions = ['png', 'jpg', 'jpeg', 'webp', 'bmp'];

  @override
  void init() {
    if (isSentNow && isSentByMe && isSent == false) {
      context!.read<SendMessageCubit>().send(
            senderId: HiveUtils.getUserId().toString(),
            recieverId: message!.receiverId!,
            attachment: message?.file,
            message: message!.message!,
            proeprtyId: message!.propertyId!,
            audio: message?.audio,
          );
    }
    super.init();
  }

  @override
  void onRemove() {
    context!.read<DeleteMessageCubit>().delete(
          messageId: id,
          receiverId: message!.receiverId!,
          senderId: '',
          propertyId: '',
        );
    super.onRemove();
  }

  @override
  Widget render(context) {
    final extension = message!.file!.split('.').last;

    if (imageExtensions.contains(extension)) {
      return ImageAttachmentWidget(
        isSentByMe: isSentByMe,
        message: message,
        onFileSent: () {
          isSent = true;
        },
        onId: (id) {
          this.id = id;
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: isSentByMe
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              width: context.screenWidth * 0.74,
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            height: 65,
                            child: Center(
                                child: CustomText(extension.toUpperCase(),
                                    fontSize: context.font.small,
                                    color: context.color.textColorDark)),
                          ),
                        ),
                        Container(
                          width: 1.5,
                          height: 50,
                          color: context.color.borderColor.darken(10),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: CustomText(message!.file!.split('/').last),
                          ),
                        ),
                        FileDownloadButton(
                          url: message!.file!,
                        ),
                      ],
                    ),
                  ),
                  if (message?.message != null &&
                      message!.message!.isNotEmpty) ...[
                    const Divider(),
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8, right: 8, left: 8),
                      child: CustomText(message!.message!),
                    ),
                  ],
                  BlocConsumer<SendMessageCubit, SendMessageState>(
                    listener: (context, state) {
                      if (state is SendMessageSuccess) {
                        id = state.messageId.toString();
                        // widget.onId.call(state.messageId.toString());
                        // widget.onFileSent.call();
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
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomText(
                message!.timeAgo!,
                fontSize: context.font.smaller,
                color: context.color.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileDownloadButton extends StatefulWidget {
  const FileDownloadButton({required this.url, super.key});
  final String url;

  @override
  State<FileDownloadButton> createState() => _FileDownloadButtonState();
}

class _FileDownloadButtonState extends State<FileDownloadButton> {
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _progressNotifier,
      builder: (context, value, child) {
        if (value != 0 && value != 1) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: value,
                color: context.color.tertiaryColor,
              ),
            ),
          );
        }

        return IconButton(
          onPressed: downloadFile,
          icon: const Icon(Icons.download),
        );
      },
    );
  }

  String getExtentionOfFile() {
    return widget.url.split('.').last;
  }

  String getFileName() {
    return widget.url.split('/').last;
  }

  Future<void> downloadFile() async {
    try {
      final downloadPath = await getDownloadPath();
      await Dio().download(
        widget.url,
        '${downloadPath!}/${getFileName()}',
        onReceiveProgress: (int count, int total) async {
          _progressNotifier.value = count / total;
          if (_progressNotifier.value == 1) {
            await HelperUtils.showSnackBarMessage(
              context,
              UiUtils.translate(context, 'fileSavedIn'),
              type: MessageType.success,
            );

            await OpenFilex.open('$downloadPath/${getFileName()}');
          }
          setState(() {});
        },
      );
    } catch (e) {
      log('Download Error is: $e');
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'errorFileSave'),
        type: MessageType.success,
      );
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        await HelperUtils.showSnackBarMessage(
          context,
          UiUtils.translate(context, 'fileNotSaved'),
          type: MessageType.success,
        );
      }
    }
    return directory?.path;
  }
}

class ImageAttachmentWidget extends StatefulWidget {
  const ImageAttachmentWidget({
    required this.isSentByMe,
    required this.message,
    required this.onId,
    required this.onFileSent,
    super.key,
  });
  final Function(String id) onId;
  final Function() onFileSent;

  final bool isSentByMe;
  final ChatMessageModel? message;

  @override
  State<ImageAttachmentWidget> createState() => _ImageAttachmentWidgetState();
}

class _ImageAttachmentWidgetState extends State<ImageAttachmentWidget> {
  bool isFileDownloading = false;
  double persontage = 0;
  String getExtentionOfFile() {
    return widget.message!.file.toString().split('.').last;
  }

  String getFileName() {
    return widget.message!.file.toString().split('/').last;
  }

  Future<void> downloadFile() async {
    try {
      if (!(await Permission.storage.isGranted)) {
        await Permission.storage.request();
        await HelperUtils.showSnackBarMessage(
          context,
          'Please give storage permission',
        );

        return;
      }

      final downloadPath = await HelperUtils.getDownloadPath(
        onError: (err) {
          HelperUtils.showSnackBarMessage(
            context,
            UiUtils.translate(context, 'fileNotSaved'),
            type: MessageType.success,
          );
        },
      );
      await Dio().download(
        widget.message!.file!,
        '${downloadPath!}/${getFileName()}',
        onReceiveProgress: (int count, int total) async {
          persontage = count / total;

          if (persontage == 1) {
            await HelperUtils.showSnackBarMessage(
              context,
              UiUtils.translate(context, 'fileSavedIn'),
              type: MessageType.success,
            );

            await OpenFilex.open('$downloadPath/${getFileName()}');
          }
          setState(() {});
        },
      );
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'errorFileSave'),
        type: MessageType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocalFile = widget.message!.file!.startsWith('/data/user/0/');

    return Align(
      alignment:
          widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: context.screenWidth * 0.74,
            // height: context.screenHeight * 0.4,
            constraints: BoxConstraints(minHeight: context.screenHeight * 0.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.color.secondaryColor,
              border: Border.all(color: context.color.borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.screenHeight * 0.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () {
                        final fileImage =
                            FileImage(File(widget.message!.file!));
                        final networkImage =
                            NetworkImage(widget.message!.file!);

                        late ImageProvider image;
                        if (isLocalFile) {
                          image = fileImage;
                        } else {
                          image = networkImage;
                        }

                        UiUtils.showFullScreenImage(
                          context,
                          downloadOption: true,
                          provider: image,
                        );
                      },
                      child: isLocalFile
                          ? BlurredImage(
                              image: FileImage(File(widget.message!.file!)),
                            )
                          : BlurredImage(
                              image: NetworkImage(widget.message!.file!),
                            ),
                    ),
                  ),
                ),
                if (widget.message!.message != '' &&
                    widget.message!.message != '[File]')
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                    child: CustomText(widget.message?.message ?? ''),
                  ),
                BlocConsumer<SendMessageCubit, SendMessageState>(
                  listener: (context, state) {
                    if (state is SendMessageSuccess) {
                      log('message senttt ${state.messageId}');
                      // this.id = state.messageId.toString();
                      widget.onId.call(state.messageId.toString());
                      widget.onFileSent.call();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomText(
              widget.message?.timeAgo ?? format(DateTime.now()),
              fontSize: context.font.smaller,
              color: context.color.textLightColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BlurredImage extends StatelessWidget {
  const BlurredImage({required this.image, super.key});
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: image, fit: BoxFit.cover),
        SizedBox(
          height: 220,
          width: 150,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 5),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        Image(
          image: image,
        ),
      ],
    );
  }
}
