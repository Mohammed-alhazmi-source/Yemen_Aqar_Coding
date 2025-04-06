import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoPlayerWideget extends StatefulWidget {
  const VideoPlayerWideget({required this.url, super.key, this.padding});

  final String url;
  final EdgeInsetsGeometry? padding;

  @override
  State<VideoPlayerWideget> createState() => _VideoPlayerWidegetState();
}

class _VideoPlayerWidegetState extends State<VideoPlayerWideget> {
  YoutubeExplode youtubeExplode = YoutubeExplode();
  String? url;

  getYoutubeVideo(url) async {
    try {
      final video = await youtubeExplode.videos.get(url);
      final manifest =
          await youtubeExplode.videos.streams.getManifest(video.id.value);

      final videoQuality = manifest.muxed.sortByVideoQuality().bestQuality;
      url = videoQuality.url.toString();
      _flickmanager = FlickManager(
        autoPlay: false,
        videoPlayerController:
            VideoPlayerController.networkUrl(videoQuality.url),
      );
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  Future getYoutubeVideoQualityUrls() async {
    await YtbRepo().getVideoMetadata('https://youtu.be/lSf5ThEETPk');
  }

  bool isYoutube(String url) {
    return HelperUtils.isYoutubeVideo(url);
  }

  FlickManager? _flickmanager;

  @override
  void initState() {
    if (isYoutube(widget.url)) {
      getYoutubeVideo(widget.url);
    } else {
      _flickmanager = FlickManager(
        autoPlay: false,
        videoPlayerController:
            VideoPlayerController.networkUrl(Uri.parse(widget.url)),
      );
      setState(() {});
    }
    super.initState();
  }

  @override
  void dispose() {
    _flickmanager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flickmanager != null) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: FlickVideoPlayer(
          flickManager: _flickmanager!,
        ),
      );
    }
    return Container(
      height: 0,
    );
  }
}
