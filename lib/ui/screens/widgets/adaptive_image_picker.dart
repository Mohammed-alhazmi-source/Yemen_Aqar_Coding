import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/add_property_details.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/custom_validator.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerValue<T> {
  abstract final T value;
}

class UrlValue extends ImagePickerValue {
  UrlValue(this.value, [this.metaData]);
  @override
  final String value;
  final dynamic metaData;
}

class FileValue extends ImagePickerValue<File> {
  FileValue(this.value, this.fileSize);
  @override
  final File value;
  final FileSize? fileSize;
}

class IdentifyValue extends ImagePickerValue {
  IdentifyValue(this.value) {
    if (value is File) {
      final file = value;
      final int fileSizeInBytes = file.lengthSync();

      value = FileValue(file, formatFileSize(fileSizeInBytes));
      // value = FileValue(
      //   value,
      // );
    }
    if (value is String) {
      value = UrlValue(value);
    }
  }
  @override
  dynamic value;
}

class MultiValue extends ImagePickerValue {
  MultiValue(this.value);
  @override
  List<ImagePickerValue> value;
}

class FileSize {
  const FileSize({
    required this.bytes,
    required this.kb,
    required this.mb,
    required this.gb,
  });
  final double kb;
  final double mb;
  final double gb;
  final int bytes;

  @override
  String toString() {
    return 'FileSize{kb: $kb, mb: $mb, gb: $gb, bytes: $bytes}';
  }
}

class ImageCount {
  ImageCount(this.min, this.max);
  final int min;
  final int max;
}

class AdaptiveImagePickerWidget extends StatefulWidget {
  const AdaptiveImagePickerWidget({
    required this.onSelect,
    required this.title,
    super.key,
    this.value,
    this.multiImage,
    this.onRemove,
    this.isRequired,
    this.count,
    this.allowedSizeBytes,
  });
  final String title;
  final ImageCount? count;
  final int? allowedSizeBytes;
  final bool? isRequired;
  final bool? multiImage;
  final ImagePickerValue? value;
  final void Function(dynamic value)? onRemove;
  final void Function(ImagePickerValue? selected) onSelect;

  @override
  State<AdaptiveImagePickerWidget> createState() =>
      _AdaptiveImagePickerWidgetState();
}

class _AdaptiveImagePickerWidgetState extends State<AdaptiveImagePickerWidget> {
  ImagePicker imagePicker = ImagePicker();

  Widget currentWidget = Container();
  ImagePickerValue? imagePickedValue;
  dynamic get(ImagePickerValue imagePickerValue) {
    if (imagePickerValue is UrlValue) {
      return Image.network(
        imagePickerValue.value,
        fit: BoxFit.cover,
      );
    }
    if (imagePickerValue is FileValue) {
      return Image.file(
        imagePickerValue.value,
        fit: BoxFit.cover,
      );
    }
    if (imagePickedValue is IdentifyValue) {
      return get(imagePickerValue);
    }
  }

  @override
  void initState() {
    if (widget.value != null) {
      imagePickedValue = widget.value;
    }
    super.initState();
  }

  dynamic getProvider(imagePickedValue) {
    if (imagePickedValue is FileValue) {
      return FileImage(imagePickedValue.value);
    }
    if (imagePickedValue is UrlValue) {
      return NetworkImage(imagePickedValue.value);
    }
    if (imagePickedValue is IdentifyValue) {
      return getProvider(imagePickedValue);
    }
  }

  Future<void> _onPick(FormFieldState state) async {
    // _pickTitleImage.pick(pickMultiple: false);
    // titleImageURL = "";

    if (widget.multiImage == true) {
      final list = await imagePicker.pickMultiImage();

      final multiImages = list.map((e) {
        final file = File(e.path);
        final fileSizeInBytes = file.lengthSync();
        final fv = FileValue(file, formatFileSize(fileSizeInBytes));
        return fv;
      }).toList();

      if (imagePickedValue == null) {
        imagePickedValue = MultiValue(multiImages);
      } else {
        (imagePickedValue as MultiValue?)?.value.addAll(multiImages);
      }

      state.didChange(imagePickedValue);

      widget.onSelect(imagePickedValue! as MultiValue);
      setState(() {});
      return;
    }
    final xFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      final file = File(xFile.path);
      final fileSizeInBytes = file.lengthSync();
      imagePickedValue = FileValue(file, formatFileSize(fileSizeInBytes));
      state.didChange(imagePickedValue);
      widget.onSelect(imagePickedValue! as FileValue);
    }

    setState(() {});
  }

  _onRemove(dynamic value, FormFieldState state) {
    if (widget.multiImage == true) {
      if (imagePickedValue is MultiValue) {
        (imagePickedValue! as MultiValue).value.remove(value);
        widget.onRemove?.call(value);
      }
      widget.onSelect(imagePickedValue);
    } else {
      imagePickedValue = null;
      state.didChange(null);
      widget.onRemove?.call(null);

      widget.onSelect(null);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (imagePickedValue is MultiValue) {}
    if (imagePickedValue != null) {
      currentWidget = GestureDetector(
        onTap: () {
          UiUtils.showFullScreenImage(
            context,
            provider: getProvider(imagePickedValue),
          );
        },
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(5),
              clipBehavior: Clip.antiAlias,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: get(imagePickedValue!),
            ),
          ],
        ),
      );
    } else {
      currentWidget = Container();
    }
    return CustomValidator<ImagePickerValue>(
      initialValue: widget.value,
      validator: (value) {
        if (widget.isRequired == true) {
          if (value == null) {
            return 'Please pick image';
          }
          if (value is MultiValue) {
            if (value.value.isEmpty) {
              return 'Please pick image';
            }
          }

          if (value is FileValue) {
            if (widget.allowedSizeBytes != null &&
                value.fileSize!.bytes > widget.allowedSizeBytes!) {
              final size = formatFileSize(widget.allowedSizeBytes!);
              return 'Max ${size.kb ~/ 1}KB your file size: ${value.fileSize!.kb ~/ 1}KB';
            }
          }
          if (widget.count != null &&
              widget.multiImage == true &&
              widget.isRequired == true) {
            if (imagePickedValue is MultiValue) {
              final images = (imagePickedValue! as MultiValue).value.length;
              if (widget.count?.min != null && images < widget.count!.min) {
                return 'Minimum ${widget.count!.min} images required';
              }

              if (widget.count?.max != null && images > widget.count!.max) {
                return 'Maximum ${widget.count!.max} images are allowed';
              }
            }
          }
        }

        return null;
      },
      builder: (state) {
        return Wrap(
          children: [
            if (imagePickedValue == null)
              DottedBorder(
                color: state.hasError
                    ? context.color.error
                    : context.color.textLightColor,
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: GestureDetector(
                  onTap: () {
                    _onPick(state);
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    height: 48.rh(context),
                    child: CustomText(widget.title),
                  ),
                ),
              ),
            // if (state.hasError)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 4),
            //     child: CustomText(state.errorText!)
            //         .color(context.color.error)
            //         .size(context.font.small),
            //   ),
            if (imagePickedValue is! MultiValue)
              Stack(
                children: [
                  currentWidget,
                  closeButton(context, () {
                    _onRemove(null, state);
                  }),
                ],
              ),
            if (imagePickedValue is MultiValue) ...{
              ...(imagePickedValue! as MultiValue)
                  .value
                  .map((ImagePickerValue impvalue) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(
                          context,
                          provider: getProvider(impvalue),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: get(impvalue),
                          ),
                        ],
                      ),
                    ),
                    closeButton(context, () {
                      _onRemove(impvalue, state);
                    }),
                  ],
                );
              }),
            },
            if (imagePickedValue != null)
              uploadPhotoCard(
                context,
                onTap: () {
                  _onPick(state);
                },
              )
            // GestureDetector(
            //   onTap: () {
            //     _pickTitleImage.resumeSubscription();
            //     _pickTitleImage.pick(pickMultiple: false);
            //     _pickTitleImage.pauseSubscription();
            //     titleImageURL = "";
            //     setState(() {});
            //   },
            //   child: Container(
            //     width: 100,
            //     height: 100,
            //     margin: const EdgeInsets.all(5),
            //     clipBehavior: Clip.antiAlias,
            //     decoration:
            //         BoxDecoration(borderRadius: BorderRadius.circular(10)),
            //     child: DottedBorder(
            //         borderType: BorderType.RRect,
            //         radius: Radius.circular(10),
            //         child: Container(
            //           alignment: Alignment.center,
            //           child: CustomText("Upload \n Photo"),
            //         )),
            //   ),
            // ),
            ,
            Row(
              children: [
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CustomText(
                      state.errorText!,
                      color: context.color.error,
                      fontSize: context.font.small,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

FileSize formatFileSize(int fileSizeInBytes) {
  const KB = 1024;
  const MB = 1024 * KB;
  const GB = 1024 * MB;
  return FileSize(
    bytes: fileSizeInBytes,
    mb: fileSizeInBytes / MB,
    gb: fileSizeInBytes / GB,
    kb: fileSizeInBytes / KB,
  );
}
