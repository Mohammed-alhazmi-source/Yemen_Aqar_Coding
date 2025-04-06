import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class AddProjectDetails extends StatefulWidget {
  const AddProjectDetails({super.key, this.editData});

  final Map? editData;

  static BlurredRouter route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => ManageProjectCubit(),
          child: AddProjectDetails(
            editData: settings.arguments as Map?,
          ),
        );
      },
    );
  }

  @override
  CloudState<AddProjectDetails> createState() => _AddProjectDetailsState();
}

class _AddProjectDetailsState extends CloudState<AddProjectDetails> {
  late bool isEdit = widget.editData != null;
  String slug = '';
  String metaTitle = '';
  String metaDescription = '';
  String metaImageUrl = '';

  late ProjectModel? project = getEditProjectData(widget.editData?['project']);

  late final TextEditingController _titleController =
      TextEditingController(text: project?.title);
  late final TextEditingController _slugController =
      TextEditingController(text: project?.slugId ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: project?.description);
  late final TextEditingController _videoLinkController =
      TextEditingController(text: project?.videoLink);
  String selectedLocation = '';
  GooglePlaceModel? suggestion;
  final GlobalKey<FormState> _formKey = GlobalKey();

  List<Document> documentFiles = [];
  List<int> removedDocumentId = [];
  List<int> removedGalleryImageId = [];

  GooglePlaceRepository googlePlaceRepository = GooglePlaceRepository();

  late final TextEditingController _cityNameController =
      TextEditingController(text: project?.city);

  late final TextEditingController _stateNameController =
      TextEditingController(text: project?.state);

  late final TextEditingController _countryNameController =
      TextEditingController(text: project?.country);

  late final TextEditingController _addressController =
      TextEditingController(text: project?.location);

  // final TextEditingController _main=TextEditingController();
  double? latitude;
  double? longitude;
  Map? floorPlans = {};
  List<Map> floorPlansRawData = [];
  ImagePickerValue? titleImage;
  ImagePickerValue? galleryImages;
  String projectType = 'upcoming';
  List<int> removedPlansId = [];

  ProjectModel? getEditProjectData(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    return ProjectModel.fromMap(data);
  }

  String generateSlug(String input) {
    return input
        .replaceAll(' ', '-')
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w-]'), '');
  }

  @override
  void initState() {
    //add documents in edit mode
    _titleController.addListener(() {
      setState(() {
        if (project?.slugId != null && project?.slugId != '') {
          _slugController.text = project?.slugId ?? '';
        }
        _slugController.text = generateSlug(_titleController.text);
      });
    });
    metaTitle = widget.editData?['meta_title'] ?? '';
    metaDescription = widget.editData?['meta_description'] ?? '';
    metaImageUrl = widget.editData?['meta_image'] ?? '';
    final list = project?.documents?.map((document) {
      return UrlDocument(document.name!, document.id!);
    }).toList();

    if (list != null) {
      documentFiles = List<Document>.from(list as List<Document>);
    }
    projectType = project?.type ?? 'upcoming';
    if (project != null && project?.image != '') {
      titleImage = UrlValue(project!.image!);
    }

    if (project != null && project!.gallaryImages!.isNotEmpty) {
      galleryImages = MultiValue(
        project!.gallaryImages!.map((e) => UrlValue(e.name!)).toList(),
      );
    }

    ///add plans in edit mode
    project?.plans?.forEach((plan) {
      floorPlansRawData.add({
        'title': plan.title,
        'id': plan.id,
        'image': plan.document,
      });
    });

    setState(() {});
    super.initState();
  }

  Map<String, dynamic> projectDetails = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: 'projectDetails'.translate(context),
        showBackButton: true,
      ),
      bottomNavigationBar: BottomAppBar(
        color: context.color.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: context.color.tertiaryColor,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Map documents;
                  documents = {};
                  try {
                    documents = documentFiles.fold({}, (pr, el) {
                      if (el is FileDocument) {
                        pr.addAll({
                          'documents[${pr.length}]':
                              MultipartFile.fromFileSync(el.value.path),
                        });
                      }
                      return pr;
                    });
                  } catch (e) {
                    log('issue is $e');
                  }

                  projectDetails = {
                    'title': _titleController.text,
                    'slug_id': _slugController.text,
                    'description': _descriptionController.text,
                    'latitude': latitude,
                    'longitude': longitude,
                    'city': _cityNameController.text,
                    'state': _stateNameController.text,
                    'country': _countryNameController.text,
                    'location': _addressController.text,
                    'video_link': _videoLinkController.text,
                    if (titleImage != null &&
                        titleImage is! UrlValue &&
                        titleImage?.value != '')
                      'image': titleImage,
                    'gallery_images': galleryImages,
                    ...documents,
                    'is_edit': isEdit,
                    'project': project,
                    'type': projectType,
                    'remove_gallery_images': removedGalleryImageId.join(','),
                    'remove_documents': removedDocumentId.join(','),
                    'remove_plans': removedPlansId.join(','),
                    'meta_title': metaTitle,
                    'meta_description': metaDescription,
                    'meta_image': metaImageUrl,

                    ////If there is data it will add into it
                    ...widget.editData ?? {},
                  };
                  addCloudData(
                    'add_project_details',
                    projectDetails,
                  );
                  //this will create Map from List<Map>

                  floorPlansRawData
                      .removeWhere((element) => element['image'] is String);

                  final fold =
                      floorPlansRawData.fold({}, (previousValue, element) {
                    previousValue.addAll({
                      'plans[${previousValue.length ~/ 2}][id]':
                          (element['id'] is ValueKey)
                              ? (element['id'] as ValueKey).value
                              : '',
                      'plans[${previousValue.length ~/ 2}][document]':
                          element['image'],
                      'plans[${previousValue.length ~/ 2}][title]':
                          element['title'],
                    });
                    return previousValue;
                  });

                  addCloudData('floor_plans', fold);
                  Navigator.pushNamed(
                    context,
                    Routes.projectMetaDataScreens,
                    arguments: {
                      'project': projectDetails,
                    },
                  );
                }
              },
              height: 50,
              child: CustomText(
                'continue'.translate(context),
                color: context.color.secondaryColor,
              )),
        ),
      ),
      body: BlocListener<ManageProjectCubit, ManageProjectState>(
        listener: (context, state) {
          if (state is ManageProjectInProgress) {
            Widgets.showLoader(context);
          }

          if (state is ManageProjectInSuccess) {
            context.read<FetchMyProjectsListCubit>().update(state.project);
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(
              context,
              'projectUpdatedSuccessfully'.translate(context),
            );
            Navigator.of(context)
              ..pop()
              ..pop();
          }
          if (state is ManageProjectInFail) {
            throw state.error;
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'projectName'.translate(context)),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  height(),
                  CustomTextFormField(
                    controller: _titleController,
                    validator: CustomTextFieldValidator.nullCheck,
                    action: TextInputAction.next,
                    hintText: 'projectName'.translate(context),
                  ),
                  height(),
                  CustomText('slugIdLbl'.translate(context)),
                  height(),
                  CustomTextFormField(
                    controller: _slugController,
                    validator: CustomTextFieldValidator.slugId,
                    action: TextInputAction.next,
                    hintText: UiUtils.translate(context, 'slugIdOptional'),
                  ),
                  height(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Description'.translate(context)),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  height(),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _descriptionController,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: UiUtils.translate(context, 'writeSomething'),
                    maxLine: 100,
                    minLine: 6,
                  ),
                  height(),
                  projectTypeField(context),
                  height(),
                  buildLocationChooseHeader(),
                  height(),
                  buildProjectLocationTextFields(),
                  height(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'uploadMainPicture'.translate(context)),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  height(),
                  AdaptiveImagePickerWidget(
                    isRequired: true,
                    multiImage: false,
                    allowedSizeBytes: 3000000,
                    value: isEdit ? UrlValue(project!.image!) : null,
                    title: UiUtils.translate(context, 'addMainPicture'),
                    onSelect: (ImagePickerValue? selected) {
                      titleImage = selected;
                      setState(() {});
                    },
                  ),
                  height(),
                  CustomText('uploadOtherImages'.translate(context)),
                  height(),
                  AdaptiveImagePickerWidget(
                    title: UiUtils.translate(context, 'addOtherImage'),
                    onRemove: (value) {
                      if (value is UrlValue) {
                        removedGalleryImageId.add(value.metaData['id']);
                      }
                    },
                    multiImage: true,
                    value: MultiValue([
                      ...project?.gallaryImages?.map(
                            (e) => UrlValue(e.name!, {
                              'id': e.id!,
                            }),
                          ) ??
                          [],
                    ]),
                    onSelect: (ImagePickerValue? selected) {
                      if (selected is MultiValue) {
                        galleryImages = selected;
                        setState(() {});
                      }
                    },
                  ),
                  height(),
                  CustomText('videoLink'.translate(context)),
                  height(),
                  CustomTextFormField(
                    action: TextInputAction.next,
                    controller: _videoLinkController,
                    validator: CustomTextFieldValidator.link,
                    hintText: 'http://example.com/video.mp4',
                  ),
                  height(),
                  CustomText('projectDocuments'.translate(context)),
                  height(),
                  buildDocumentPicker(context),
                  ...documentList(),
                  height(),
                  Row(
                    children: [
                      Column(
                        children: [
                          CustomText(
                            'floorPlans'.translate(context),
                          ),
                          CustomText(
                            '${floorPlansRawData.length}',
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      const Spacer(),
                      MaterialButton(
                        elevation: 0,
                        color:
                            context.color.tertiaryColor.withValues(alpha: 0.1),
                        onPressed: () async {
                          final data = await Navigator.pushNamed(
                            context,
                            Routes.manageFloorPlansScreen,
                            arguments: {'floorPlan': floorPlansRawData},
                          ) as Map?;
                          if (data != null) {
                            floorPlansRawData = data['floorPlans'] ?? [];

                            removedPlansId = data['removed'];
                          }
                          setState(() {});
                        },
                        child: const CustomText('Manage'),
                      ),
                    ],
                  ),
                  height(30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget projectTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText('projectStatus'.translate(context)),
        height(),
        InputDecorator(
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: context.color.textColorDark.withValues(alpha: 0.7),
              fontSize: context.font.large,
            ),
            filled: true,
            fillColor: context.color.secondaryColor,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: context.color.tertiaryColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: DropdownButton(
            isExpanded: true,
            value: projectType,
            isDense: true,
            borderRadius: BorderRadius.zero,
            padding: EdgeInsets.zero,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(
                value: 'upcoming',
                child: CustomText('Upcoming'.translate(context)),
              ),
              DropdownMenuItem(
                value: 'under_construction',
                child: CustomText('under_construction'.translate(context)),
              ),
            ],
            onChanged: (value) {
              projectType = value!;
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Column buildProjectLocationTextFields() {
    return Column(
      children: [
        CustomTextFormField(
          action: TextInputAction.next,
          controller: _cityNameController,
          isReadOnly: false,
          validator: CustomTextFieldValidator.nullCheck,
          hintText: UiUtils.translate(context, 'city'),
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          action: TextInputAction.next,
          controller: _stateNameController,
          isReadOnly: false,
          validator: CustomTextFieldValidator.nullCheck,
          hintText: UiUtils.translate(context, 'state'),
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          action: TextInputAction.next,
          controller: _countryNameController,
          isReadOnly: false,
          validator: CustomTextFieldValidator.nullCheck,
          hintText: UiUtils.translate(context, 'country'),
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          action: TextInputAction.next,
          controller: _addressController,
          hintText: UiUtils.translate(context, 'addressLbl'),
          maxLine: 100,
          validator: CustomTextFieldValidator.nullCheck,
          minLine: 4,
        ),
      ],
    );
  }

  SizedBox buildLocationChooseHeader() {
    return SizedBox(
      height: 35.rh(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'projectLocation'.translate(context)),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          // const Spacer(),
          ChooseLocationFormField(
            initialValue: false,
            validator: (bool? value) {
              if (project != null) return null;

              if (value == true) {
                return null;
              } else {
                return 'Select location';
              }
            },
            build: (state) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: state.hasError ? Colors.red : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: InkWell(
                  onTap: () {
                    _onTapChooseLocation.call(state);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiUtils.getSvg(
                        AppIcons.location,
                        color: context.color.textLightColor,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      CustomText(
                        UiUtils.translate(
                          context,
                          'chooseLocation',
                        ),
                        fontSize: context.font.normal,
                        color: context.color.tertiaryColor,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const CustomText(
                        ' *',
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onTapChooseLocation(FormFieldState state) async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();

      final placeMark = await Navigator.pushNamed(
        context,
        Routes.chooseLocaitonMap,
        arguments: {
          'latitude': project != null ? double.parse(project!.latitude!) : null,
          'longitude':
              project != null ? double.parse(project!.longitude!) : null,
        },
      ) as Map?;
      final latlng = placeMark?['latlng'] as LatLng?;
      final place = placeMark?['place'] as Placemark?;

      if (latlng != null && place != null) {
        latitude = latlng.latitude;
        longitude = latlng.longitude;

        _cityNameController.text = place.locality ?? '';
        _countryNameController.text = place.country ?? '';
        _stateNameController.text = place.administrativeArea ?? '';
        _addressController.text =
            [place.locality, place.administrativeArea, place.country].join(',');
        // _addressController.text = getAddress(place);

        state.didChange(true);
      } else {
        // state.didChange(false);
      }
    } catch (e, st) {
      log('THE ISSUE IS $st');
    }
  }

  Widget height([double? h]) {
    return SizedBox(
      height: h?.rh(context) ?? 15.rh(context),
    );
  }

  List<Widget> documentList() {
    return documentFiles.map((document) {
      var fileName = '';
      if (document is FileDocument) {
        fileName = document.value.path.split('/').last;
      } else {
        fileName = document.value.toString().split('/').last;
      }

      return ListTile(
        title: CustomText(
          fileName,
          maxLines: 2,
        ),
        dense: true,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (document is UrlDocument) {
              removedDocumentId.add(document.id);
            }
            documentFiles.remove(document);
            setState(() {});
          },
        ),
      );
    }).toList();
  }

  Widget buildDocumentPicker(BuildContext context) {
    return Row(
      children: [
        DottedBorder(
          borderType: BorderType.RRect,
          color: context.color.textLightColor,
          radius: const Radius.circular(20),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: IconButton(
                onPressed: () async {
                  final filePickerResult = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                  );
                  if (filePickerResult != null) {
                    final list = List<Document>.from(
                      filePickerResult.files.map((e) {
                        return FileDocument(File(e.path!));
                      }).toList(),
                    );
                    documentFiles.addAll(list);
                  }

                  setState(() {});
                },
                icon: const Icon(Icons.upload),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText('UploadDocs'.translate(context)),
            const SizedBox(
              height: 4,
            ),
            CustomText(documentFiles.length.toString()),
          ],
        ),
      ],
    );
  }
}

abstract class Document<T> {
  abstract final T value;
}

class FileDocument extends Document {
  FileDocument(this.value);

  @override
  final File value;
}

class UrlDocument extends Document {
  UrlDocument(this.value, this.id);

  @override
  final String value;
  final int id;
}
