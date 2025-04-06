abstract class NativeDeepLinkUtility {
  void handle(Uri uri, ProcessResult? result);
  Future<void> handleLink(String url) async {
    // final parse = Uri.parse(url);
    // final nativeDeepLinkManager = NativeDeepLinkManager();
    // final processResult = await nativeDeepLinkManager.process(parse);
    // nativeDeepLinkManager.handle(parse, processResult);
  }

  // MaterialPageRoute build(RouteSettings settings) {
  //   return MaterialPageRoute(
  //     builder: (context) {
  //       return NativeLinkWidget(
  //         settings: settings,
  //       );
  //     },
  //   );
  // }

  Future<ProcessResult?> process(Uri uri);
}

class ProcessResult<T> {
  ProcessResult(this.result);
  final T result;
}
