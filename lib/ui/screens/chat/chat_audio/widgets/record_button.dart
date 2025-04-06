import 'dart:async';
import 'dart:io';

import 'package:ebroker/ui/screens/chat/chat_audio/audio_state.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/globals.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/widgets/flow_shader.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/widgets/lottie_animation.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({
    required this.controller,
    required this.callback,
    required this.isSending,
    super.key,
  });

  final AnimationController controller;
  final Function(dynamic path)? callback;
  final bool isSending;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 43;

  final double lockerHeight = 200;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = '00:00';
  AudioRecorder? record;

  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    record = AudioRecorder();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth =
        MediaQuery.of(context).size.width - 2 * ChatGlobals.defaultPadding - 4;
    timerAnimation =
        Tween<double>(begin: timerWidth + ChatGlobals.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation =
        Tween<double>(begin: lockerHeight + ChatGlobals.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    if (record != null) record!.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (timer?.isActive ?? false) lockSlider() else const SizedBox.shrink(),
        if (timer?.isActive ?? false)
          cancelSlider()
        else
          const SizedBox.shrink(),
        audioButton(),
        if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChatGlobals.borderRadius),
          color: context.color.secondaryColor,
          //color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            //const FaIcon(FontAwesomeIcons.lock, size: 20),
            const Icon(Icons.lock, size: 20),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: const Column(
                children: [
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChatGlobals.borderRadius),
          color: context.color.primaryColor,
          //color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLottie)
                const LottieAnimation()
              else
                CustomText(recordDuration),
              FlowShader(
                duration: const Duration(seconds: 3),
                flowColors: [
                  context.color.tertiaryColor,
                  const Color(0xFF9E9E9E),
                ],
                child: Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_left),
                    CustomText(UiUtils.translate(context, 'slidetocancel')),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                //flowColors: const [Colors.white, Colors.grey],
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChatGlobals.borderRadius),
          color: context.color.secondaryColor,
          //color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              /*Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;
              recordDuration = "00:00";

              var filePath = await Record().stop();
              AudioState.files.add(filePath!);
              Globals.audioListKey.currentState!
                  .insertItem(AudioState.files.length - 1);
              debugPrint(filePath);*/
              await saveFile();
              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomText(recordDuration),
                const SizedBox(
                  width: 5,
                ),
                FlowShader(
                  duration: const Duration(seconds: 3),
                  flowColors: [context.color.tertiaryColor, Colors.grey],
                  child:
                      CustomText(UiUtils.translate(context, 'taploacktostop')),
                  //flowColors: const [Colors.white, Colors.grey],
                ),
                const Center(
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.green,
                  ),
                  /*  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: Colors.green,
                  ), */
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        //child: Widgets.chatSendBtnWidget(widget.isSending, isaudio: true),
        child: Container(
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.color.tertiaryColor,
            //color: Theme.of(context).primaryColor,
          ),
          child: widget.isSending
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
        ),
      ),
      onTap: () async {
        await HelperUtils.showSnackBarMessage(
          context,
          'longPressToRecord'.translate(context),
          messageDuration: 2,
        );
      },
      onLongPressDown: (_) {
        if (widget.isSending) return;
        debugPrint('onLongPressDown');
        widget.controller.forward();
      },
      onLongPressEnd: (details) async {
        if (widget.isSending) return;
        debugPrint('onLongPressEnd');

        if (isCancelled(details.localPosition, context)) {
          // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = '00:00';

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            await widget.controller.reverse();
            debugPrint('Cancelled recording');
            final filePath = await record!.stop();
            debugPrint(filePath);
            await File(filePath!).delete();
            debugPrint('Deleted $filePath');
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          await widget.controller.reverse();

          // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.heavy);
          debugPrint('Locked recording');
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          await widget.controller.reverse();
          await saveFile();
        }
      },
      onLongPressCancel: () {
        if (widget.isSending) return;
        debugPrint('onLongPressCancel');
        widget.controller.reverse();
      },
      onLongPress: () async {
        if (widget.isSending) return;
        debugPrint('onLongPress');
        // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.success);
        bool isPermission = await record!.hasPermission();
        if (isPermission) {
          await record!.start(
            const RecordConfig(),
            path:
                '${ChatGlobals.documentPath}audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
          );
          startTime = DateTime.now();
          // print("duration==$recordDuration");
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            final minDur = DateTime.now().difference(startTime!).inMinutes;
            final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
            final min = minDur < 10 ? '0$minDur' : minDur.toString();
            final sec = secDur < 10 ? '0$secDur' : secDur.toString();
            // print("duration==$min:$sec");
            setState(() {
              recordDuration = '$min:$sec';
            });
          });
        }
      },
    );
  }

  Future<void> saveFile() async {
    // if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.success);
    timer?.cancel();
    timer = null;
    startTime = null;
    recordDuration = '00:00';

    final filePath = await record?.stop();
    AudioState.files.add(filePath!);
    if (ChatGlobals.audioListKey.currentState != null) {
      ChatGlobals.audioListKey.currentState!
          .insertItem(AudioState.files.length - 1);
    }
    debugPrint(filePath);
    if (widget.callback != null) {
      widget.callback?.call(filePath);
    }
  }

  bool checkIsLocked(Offset offset) {
    return offset.dy < -35;
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return offset.dx < -(MediaQuery.of(context).size.width * 0.2);
  }
}
