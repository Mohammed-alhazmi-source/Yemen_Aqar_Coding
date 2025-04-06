part of '../chat_widget.dart';

class AttachmentMessage extends StatefulWidget {
  const AttachmentMessage({
    required this.url,
    required this.isSentByMe,
    super.key,
  });
  final String url;
  final bool isSentByMe;

  @override
  State<AttachmentMessage> createState() => _AttachmentMessageState();
}

class _AttachmentMessageState extends State<AttachmentMessage> {
  bool isFileDownloading = false;
  double persontage = 0;
  String getExtentionOfFile() {
    return widget.url.split('.').last;
  }

  String getFileName() {
    return widget.url.split('/').last;
  }

  Future<void> downloadFile() async {
    await Permission.storage.request();
    try {
      if (!(await Permission.storage.isGranted)) {
        await HelperUtils.showSnackBarMessage(
          context,
          'Please give storage permission',
        );

        return;
      }

      final downloadPath = await getDownloadPath();
      await Dio().download(
        widget.url,
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

  @override
  Widget build(BuildContext context) {
    // if (tempIssue != null) {
    //   return GestureDetector(
    //       onTap: () async {
    //         await Clipboard.setData(ClipboardData(text: tempIssue.toString()));
    //       },
    //       child: CustomText(tempIssue.toString()));
    // }
    return Row(
      children: [
        InkWell(
          onTap: () async {
            await downloadFile();
          },
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.color.secondaryColor.withValues(alpha: 0.064),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.color.borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (persontage != 0 && persontage != 1) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 1.7,
                        color: context.color.tertiaryColor,
                        value: persontage,
                      ),
                      const Icon(Icons.close),
                    ],
                  ),
                ] else ...[
                  CustomText(
                    getExtentionOfFile().toUpperCase(),
                    color: widget.isSentByMe
                        ? Colors.black
                        : context.color.textColorDark,
                  ),
                  Icon(
                    Icons.download,
                    size: 14,
                    color: context.color.tertiaryColor,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Container(
            height: 50,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CustomText(
                getFileName(),
                maxLines: 1,
                color: widget.isSentByMe
                    ? Colors.black
                    : context.color.textColorDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
