import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/youtube_player_widget.dart';
import 'package:flutter/material.dart';

class VideoViewScreen extends StatelessWidget {
  const VideoViewScreen({
    required this.videoUrl,
    super.key,
    this.flickManager,
  });
  final String videoUrl;
  final FlickManager? flickManager;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: UiUtils.buildAppBar(context, showBackButton: true),
        body: Center(
          child: HelperUtils.checkVideoType(
            videoUrl,
            onYoutubeVideo: () {
              return YoutubePlayerWidget(
                videoUrl: videoUrl,
                onLandscape: () {},
                onPortrate: () {},
              );
            },
            onOtherVideo: () {
              if (flickManager != null) {
                return FlickVideoPlayer(flickManager: flickManager!);
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
