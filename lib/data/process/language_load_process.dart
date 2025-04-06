// import 'dart:async';
//
// import 'package:ebroker/ui/screens/splash_screen.dart';
// import 'package:ebroker/utils/Queue/queue.dart';
// import 'package:ebroker/utils/api.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
//
// class LanguageLoadProcess extends Task {
//   @override
//   Future<bool> process() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       Hive.init(directory.path);
//       await getDefaultLanguage(
//         () {},
//
//       );
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }
