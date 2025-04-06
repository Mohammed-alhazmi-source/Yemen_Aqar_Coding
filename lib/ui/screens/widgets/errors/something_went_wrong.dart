import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({super.key, this.error});
  final FlutterErrorDetails? error;

  static void asGlobalErrorBuilder() {
    if (kReleaseMode) {
      ErrorWidget.builder =
          (FlutterErrorDetails flutterErrorDetails) => SomethingWentWrong(
                error: flutterErrorDetails,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: SvgPicture.asset(AppIcons.somethingwentwrong)),
        const SizedBox(
          height: 10,
        ),
        CustomText(
          '${'somethingWentWrng'.translate(context)} !',
          fontWeight: FontWeight.bold,
          fontSize: context.font.larger,
        ),
      ],
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.stack, super.key});
  final StackTrace stack;
  void _generateError(context) {
    final filteredStackLines = stack.toString().split('\n').where((line) {
      return !line.contains('package:flutter');
    }).map((line) {
      final parts = line.split(' ');
      return parts.length > 1 ? parts[1] : line;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorDetailScreen(stackLines: filteredStackLines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _generateError(context);
      },
      child: const CustomText('Generate Error'),
    );
  }
}

class ErrorDetailScreen extends StatelessWidget {
  const ErrorDetailScreen({required this.stackLines, super.key});
  final List<String> stackLines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText('Filtered and Prettified Error Stack Trace'),
      ),
      body: ListView.builder(
        itemCount: stackLines.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: CustomText(_formatStackTraceLine(stackLines[index])),
          );
        },
      ),
    );
  }
}

String _formatStackTraceLine(String line) {
  // Example format: "at Class.method (file.dart:42:23)"
  final startIndex = line.indexOf('at ') + 3;
  final endIndex = line.lastIndexOf('(');
  return line.substring(startIndex, endIndex);
}
