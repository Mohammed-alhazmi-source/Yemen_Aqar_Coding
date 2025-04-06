import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CustomFileField extends CustomField {
  @override
  String type = 'file';

  // Add state variables
  String? _pickedFilePath;
  MultipartFile? _selectedFile;
  bool _isFileSelected = false;

  String? get pickedFilePath => _pickedFilePath;
  MultipartFile? get selectedFile => _selectedFile;

  @override
  MultipartFile? backValue() {
    return _selectedFile;
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final file = File(result.files.single.path!);

        // Update the file information
        _pickedFilePath = file.path;
        _selectedFile = await MultipartFile.fromFile(file.path);
        _isFileSelected = true;

        // Trigger rebuild
        update(() {});
      }
    } catch (e) {
      print('Error picking file: $e');
      // You might want to show an error message to the user here
    }
  }

  @override
  void init() {
    id = data['id'];
    // Initialize with existing value if available
    if (data['value'] != null && data['value'].toString().isNotEmpty) {
      _pickedFilePath = data['value'].toString();
      _isFileSelected = true;
    }
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48.rw(context),
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                height: 24,
                width: 24,
                child: FittedBox(
                  child: UiUtils.imageType(
                    data['image'],
                    color: Constant.adaptThemeColorSvg
                        ? context.color.tertiaryColor
                        : null,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.rw(context)),
            CustomText(
              data['name'],
              fontWeight: FontWeight.w500,
              fontSize: context.font.large,
              color: context.color.textColorDark,
            ),
            if (data['is_required'] == 1) ...[
              const SizedBox(width: 5),
              CustomText('*', color: context.color.error),
            ],
          ],
        ),
        SizedBox(height: 14.rh(context)),
        GestureDetector(
          onTap: pickFile,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            color: context.color.textLightColor,
            strokeCap: StrokeCap.round,
            padding: const EdgeInsets.all(5),
            dashPattern: const [3, 3],
            child: Container(
              width: double.infinity,
              height: 43,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 5),
                  CustomText(
                    _isFileSelected
                        ? 'changeFile'.translate(context)
                        : 'addFile'.translate(context),
                    color: context.color.textLightColor,
                    fontSize: context.font.large,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_pickedFilePath != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomText(
                    'File Name: ${_pickedFilePath!.split('/').last}',
                    color: context.color.textColorDark),
              ),
              // if (_isFileSelected)
              //   IconButton(
              //     icon: Icon(Icons.close, color: context.color.inverseSurface),
              //     onPressed: () {
              //       _pickedFilePath = null;
              //       _selectedFile = null;
              //       _isFileSelected = false;
              //       update(() {});
              //     },
              //   ),
            ],
          ),
        ],
      ],
    );
  }
}
