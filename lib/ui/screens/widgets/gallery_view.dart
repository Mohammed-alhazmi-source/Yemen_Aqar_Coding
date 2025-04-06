import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebroker/utils/AdMob/interstitialAdManager.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class GalleryViewWidget extends StatefulWidget {
  const GalleryViewWidget({
    required this.images,
    required this.initalIndex,
    super.key,
  });
  final List images;
  final int initalIndex;

  @override
  State<GalleryViewWidget> createState() => _GalleryViewWidgetState();
}

class _GalleryViewWidgetState extends State<GalleryViewWidget> {
  List images = [];
  late PageController controller =
      PageController(initialPage: widget.initalIndex);
  late int page = widget.initalIndex;
  InterstitialAdManager admanager = InterstitialAdManager();

  @override
  void initState() {
    images = List.from(widget.images);
    admanager.load();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: context.color.tertiaryColor),
        ),
        backgroundColor: const Color.fromARGB(17, 0, 0, 0),
        body: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: PageView.builder(
            controller: controller,
            onPageChanged: (value) async {
              page = value;
              if (page.isEven) {
                await admanager.show();
              }
              setState(() {});
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                maxScale: 5,
                child: CachedNetworkImage(
                  imageUrl: images[index],
                ),
              );
            },
            itemCount:
                (images..removeWhere((element) => (element == ''))).length,
          ),
        ),
      ),
    );
  }
}
