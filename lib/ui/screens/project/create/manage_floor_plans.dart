import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class ManageFloorPlansScreen extends StatefulWidget {
  const ManageFloorPlansScreen({required this.floorPlans, super.key});
  final List<Map>? floorPlans;

  static BlurredRouter route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return ManageFloorPlansScreen(
          floorPlans: arguments?['floorPlan'],
        );
      },
    );
  }

  @override
  CloudState<ManageFloorPlansScreen> createState() =>
      _ManageFloorPlansScreenState();
}

class _ManageFloorPlansScreenState extends CloudState<ManageFloorPlansScreen> {
  List<FloorPlan> floorPlans = [];
  List<int> removePlanId = [];

  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    if (widget.floorPlans != null) {
      widget.floorPlans?.forEach((value) {
        final floorPlan = FloorPlan(
          planKey: value['id'] is int ? ValueKey(value['id']) : value['id'],
          key: UniqueKey(),
          title: value['title'],
          imagePickerValue: value['image'] is String
              ? UrlValue(value['image'])
              : value['image'],
          onClose: (e) {
            removeFromListWhere(
              listKey: 'floorsList',
              whereKey: 'id',
              equals: e,
            );
            if (e is ValueKey) {
              removePlanId.add(e.value);
            }
            floorPlans.removeWhere((element) => element.planKey == e);
            setState(() {});
          },
        );
        floorPlans.add(floorPlan);
      });
      setState(() {});
    } else {
      final floorPlan = FloorPlan(
        planKey: GlobalKey(),
        key: UniqueKey(),
        onClose: (key) {
          removeFromGroup('floors', key);
          if (key is ValueKey) {
            removePlanId.add(key.value);
          }
          floorPlans.removeWhere((element) => element.planKey == key);
          setState(() {});
        },
      );
      floorPlans.add(floorPlan);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        clearGroup('floors');
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: 'FloorPlans'.translate(context),
        ),
        bottomNavigationBar: BottomAppBar(
          color: context.color.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: context.color.tertiaryColor,
                onPressed: () {
                  final floors = getCloudData('floorsList') as List<Map>?;

                  Navigator.pop(context, {
                    'floorPlans': floors,
                    'removed': removePlanId,
                  });
                },
                height: 50,
                child: CustomText(
                  'continue'.translate(context),
                  color: context.color.secondaryColor,
                )),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: context.screenWidth,
              child: Column(
                children: [
                  ...floorPlans,
                  MaterialButton(
                    color: context.color.tertiaryColor,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final floorPlan = FloorPlan(
                          planKey: GlobalKey(),
                          key: UniqueKey(),
                          onClose: (e) {
                            removeFromListWhere(
                              listKey: 'floorsList',
                              whereKey: 'id',
                              equals: e,
                            );
                            if (e is ValueKey) {
                              removePlanId.add(e.value);
                            }
                            floorPlans
                                .removeWhere((element) => element.planKey == e);
                            setState(() {});
                          },
                        );
                        floorPlans.add(floorPlan);
                        setState(() {});
                      }
                    },
                    elevation: 0,
                    minWidth: context.screenWidth * 0.45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomText(
                      'Add'.translate(context),
                      color: context.color.buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloorPlan extends StatefulWidget {
  const FloorPlan({
    required this.planKey,
    required this.onClose,
    super.key,
    this.title,
    this.imagePickerValue,
  });
  final Key planKey;
  final String? title;
  final ImagePickerValue? imagePickerValue;
  final Function(Key e) onClose;

  @override
  CloudState<FloorPlan> createState() {
    return FloorPlanState();
  }
}

class FloorPlanState extends CloudState<FloorPlan> {
  ImagePickerValue? imagePickerValue;

  late final TextEditingController floorTitle =
      TextEditingController(text: widget.title);

  @override
  void initState() {
    imagePickerValue = widget.imagePickerValue;
    super.initState();
  }

  @override
  void dispose() {
    floorTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText('Floor Title'.translate(context)),
              const Spacer(),
              IconButton(
                onPressed: () {
                  widget.onClose.call(widget.planKey);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextFormField(
            controller: floorTitle,
            autovalidate: AutovalidateMode.onUserInteraction,
            validator: CustomTextFieldValidator.nullCheck,
            onChange: (value) {
              appendToListWhere(
                listKey: 'floorsList',
                whereKey: 'id',
                equals: widget.planKey,
                add: {
                  'title': value,
                  'id': widget.planKey,
                  'image': imagePickerValue,
                },
              );
            },
            hintText: 'title'.translate(context),
          ),
          const SizedBox(height: 10),
          AdaptiveImagePickerWidget(
            multiImage: false,
            isRequired: true,
            value: imagePickerValue,
            title: 'pickFloorMap'.translate(context),
            onSelect: (ImagePickerValue? selected) {
              if (selected is FileValue) {
                imagePickerValue = selected;
              }

              // appendToList("floorsList", {
              //   "title": floorTitle.text,
              //   "key": widget.key,
              //   "image": imagePickerValue
              // });
              appendToListWhere(
                listKey: 'floorsList',
                whereKey: 'id',
                equals: widget.planKey,
                add: {
                  'title': floorTitle.text,
                  'id': widget.planKey,
                  'image': imagePickerValue,
                },
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
