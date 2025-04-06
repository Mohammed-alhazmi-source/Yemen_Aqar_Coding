import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  const YoutubePlayerWidget({
    required this.videoUrl,
    required this.onLandscape,
    required this.onPortrate,
    super.key,
  });
  final VoidCallback onLandscape;
  final VoidCallback onPortrate;

  final String videoUrl;

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController controller;

  String getVideoId() {
    return YoutubePlayer.convertUrlToId(widget.videoUrl)!;
  }

  @override
  void initState() {
    controller = YoutubePlayerController(
      initialVideoId: getVideoId(),
      flags: const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        widget.onLandscape.call();
      },
      onExitFullScreen: () {
        widget.onPortrate.call();
      },
      player: YoutubePlayer(
        controller: controller,
      ),
      builder: (context, child) {
        return child;
      },
    );
  }
}
