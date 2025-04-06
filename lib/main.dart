import 'package:ebroker/app/register_cubits.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/globals.dart';
import 'package:ebroker/ui/screens/chat_new/message_types/registerar.dart';
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'dart:convert';

//////////////
///V-1.2.2///
////////////



void main() async {
  // await Hive.initFlutter();
  // saveJsonToFile('languageBox');
  // saveJsonToFile('userdetailsbox');
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
}

// تحويل ملف .hive الى ملف json حتى نستطيع قراءة البيانات بشكل اسهل 
// امكانية تصدير البيانات بسهولة لاغراض النسخ او النقل 
// قراءة البيانات خارج التطبيق باستخدام برامج json viewer
// Future<void> saveJsonToFile(String boxName) async {
//   var box = await Hive.openBox(boxName);
//   Map<String, dynamic> data = box.toMap().map((key, value) => MapEntry(key.toString(), value));

//   String jsonString = jsonEncode(data);
//   print(jsonString);
//   // الحصول على مسار التخزين في الجهاز
//   final directory = await getApplicationDocumentsDirectory();
//   final file = File('${directory.path}/$boxName.json');

//   // حفظ الملف
//   await file.writeAsString(jsonString,mode: FileMode.write);

//   print("✅ تم حفظ بيانات $boxName في ملف: ${file.path}");
// }


class EntryPoint extends StatefulWidget {
  const EntryPoint({
    super.key,
  });
  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    ChatMessageHandler.handle();
    ChatGlobals.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ...RegisterCubits().register(),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return const App();
        },
      ),
    );
  }
}

