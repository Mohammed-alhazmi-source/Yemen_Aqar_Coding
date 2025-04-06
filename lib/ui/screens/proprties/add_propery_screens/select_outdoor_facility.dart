import 'package:ebroker/data/model/outdoor_facility.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';

class SelectOutdoorFacility extends StatefulWidget {
  const SelectOutdoorFacility({required this.apiParameters, super.key});

  final Map<String, dynamic>? apiParameters;

  static Route route(RouteSettings settings) {
    final apiParameters = settings.arguments! as Map<String, dynamic>;
    return BlurredRouter(
      builder: (context) {
        return SelectOutdoorFacility(
          apiParameters: apiParameters,
        );
      },
    );
  }

  @override
  State<SelectOutdoorFacility> createState() => _SelectOutdoorFacilityState();
}

class _SelectOutdoorFacilityState extends State<SelectOutdoorFacility>
    with ChangeNotifier {
  final ValueNotifier<List<int>> _selectedIdsList = ValueNotifier([]);
  List<OutdoorFacility> facilityList = [];
  Map<int, TextEditingController> distanceFieldList = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    var facilities = <AssignedOutdoorFacility>[];
    facilities = widget.apiParameters?['assign_facilities'] ?? [];

    // context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed();
    facilityList = context.read<FetchOutdoorFacilityListCubit>().getList();

    setState(() {});
    _selectedIdsList.addListener(() {
      for (final element in _selectedIdsList.value) {
        if (!distanceFieldList.keys.contains(element)) {
          if (widget.apiParameters?['isUpdate'] ?? false) {
            final match =
                facilities.where((x) => x.facilityId == element).toList();

            if (match.isNotEmpty) {
              distanceFieldList[element] =
                  TextEditingController(text: match.first.distance.toString());
            } else {
              distanceFieldList[element] = TextEditingController();
            }
          } else {
            distanceFieldList[element] = TextEditingController();
          }
        }
      }
      setState(() {});
    });

    if (widget.apiParameters?['isUpdate'] ?? false) {
      for (final element in facilities) {
        if (!_selectedIdsList.value.contains(element)) {
          _selectedIdsList.value.add(element.facilityId!);
          _selectedIdsList.notifyListeners();
        }
      }
    }
    super.initState();
  }

  Map<String, dynamic> assembleOutdoorFacility() {
    final facilitymap = <String, dynamic>{};
    for (var i = 0; i < distanceFieldList.entries.length; i++) {
      final MapEntry element = distanceFieldList.entries.elementAt(i);

      facilitymap.addAll({
        'facilities[$i][facility_id]': element.key,
        'facilities[$i][distance]': element.value.text,
      });
    }

    return facilitymap;
  }

  OutdoorFacility getSelectedFacility(int id) {
    try {
      return facilityList
          .where((OutdoorFacility element) => element.id == id)
          .first;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // log(facilityList.toString());
    final fetchInProgress = context.watch<FetchOutdoorFacilityListCubit>().state
        is FetchOutdoorFacilityListInProgress;
    final fetchFails = context.watch<FetchOutdoorFacilityListCubit>().state
        is FetchOutdoorFacilityListInProgress;

    return BlocListener<FetchOutdoorFacilityListCubit,
        FetchOutdoorFacilityListState>(
      listener: (context, state) {
        if (state is FetchOutdoorFacilityListSucess) {
          facilityList =
              context.read<FetchOutdoorFacilityListCubit>().getList();
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          actions: const [
            Spacer(),
            CustomText('4/4'),
            SizedBox(
              width: 14,
            ),
          ],
          title: 'selectNearestPlaces'.translate(context),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            distanceFieldList.forEach((element, v) {});
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: UiUtils.buildButton(
              context,
              onPressed: () {
                final parameters = widget.apiParameters;

                ///adding facility data to api payload
                parameters!.addAll(assembleOutdoorFacility());
                parameters
                  ..remove('assign_facilities')
                  ..remove('isUpdate');
                if (_formKey.currentState!.validate()) {
                  context.read<CreatePropertyCubit>().create(
                        parameters: parameters,
                      );
                }
              },
              buttonTitle: widget.apiParameters?['action_type'] == '0'
                  ? UiUtils.translate(context, 'update')
                  : UiUtils.translate(context, 'submitProperty'),
            ),
          ),
        ),
        body: Builder(
          builder: (context) {
            if (fetchInProgress) {
              return Center(
                child: UiUtils.progress(),
              );
            }
            if (fetchFails) {
              return const Center(
                child: CustomText('Something Went wrong'),
              );
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(15, 10, 15, 0),
                    child: CustomText('selectPlaces'.translate(context)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  BlocBuilder<FetchOutdoorFacilityListCubit,
                      FetchOutdoorFacilityListState>(
                    builder: (context, state) {
                      if (state is FetchOutdoorFacilityListFailure) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: SomethingWentWrong(),
                        );
                      }
                      if (state is FetchOutdoorFacilityListSucess &&
                          state.outdoorFacilityList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: NoDataFound(),
                        );
                      }
                      if (state is FetchOutdoorFacilityListSucess &&
                          state.outdoorFacilityList.isNotEmpty) {
                        return ValueListenableBuilder<List<int>>(
                          valueListenable: _selectedIdsList,
                          builder: (context, List<int> value, child) {
                            return OutdoorFacilityTable(
                              length: state.outdoorFacilityList.length,
                              child: (index) {
                                final outdoorFacilityList =
                                    state.outdoorFacilityList[index];

                                return buildTypeCard(
                                  index,
                                  context,
                                  outdoorFacilityList,
                                  onSelect: (id) {
                                    if (_selectedIdsList.value.contains(id)) {
                                      _selectedIdsList.value.remove(id);

                                      ///Dispose and remove from object
                                      distanceFieldList[id]?.dispose();
                                      distanceFieldList.remove(id);
                                      _selectedIdsList.notifyListeners();
                                    } else {
                                      _selectedIdsList.value.add(id);
                                      _selectedIdsList.notifyListeners();
                                    }
                                  },
                                  isSelected:
                                      value.contains(outdoorFacilityList.id),
                                );
                              },
                            );
                          },
                        );
                      }

                      return Container();
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedIdsList,
                    builder: (context, value, child) {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedIdsList.value.isEmpty)
                                const SizedBox.shrink()
                              else
                                CustomText('selectedItems'.translate(context)),
                              const SizedBox(
                                height: 10,
                              ),
                              ...List.generate(_selectedIdsList.value.length,
                                  (index) {
                                if (fetchInProgress) {
                                  return const SizedBox.shrink();
                                }

                                final facility = getSelectedFacility(
                                  _selectedIdsList.value[index],
                                );
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: OutdoorFacilityDistanceField(
                                    facility: facility,
                                    controller: distanceFieldList[facility.id]!,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildTypeCard(
    int index,
    BuildContext context,
    OutdoorFacility facility, {
    required bool isSelected,
    required Function(int id) onSelect,
  }) {
    return GestureDetector(
      onTap: () {
        onSelect.call(facility.id!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? context.color.tertiaryColor
              : context.color.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    offset: const Offset(1, 3),
                    blurRadius: 6,
                    color: context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                ]
              : null,
          border: isSelected
              ? null
              : Border.all(color: context.color.borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.rh(context),
              width: 20.rw(context),
              child: UiUtils.imageType(
                facility.image!,
                color: isSelected
                    ? context.color.secondaryColor
                    : (Constant.adaptThemeColorSvg
                        ? context.color.tertiaryColor
                        : null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2),
              child: CustomText(
                facility.name!,
                textAlign: TextAlign.center,
                color: isSelected
                    ? context.color.secondaryColor
                    : context.color.tertiaryColor,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutdoorFacilityDistanceField extends StatelessWidget {
  const OutdoorFacilityDistanceField({
    required this.facility,
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  final OutdoorFacility facility;

  @override
  Widget build(BuildContext context) {
    final distanceOption = context
        .read<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.distanceOption);
    return Row(
      children: [
        Container(
          width: 48.rw(context),
          height: 48.rh(context),
          decoration: BoxDecoration(
            color: context.color.tertiaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FittedBox(
            fit: BoxFit.none,
            child: SizedBox(
              height: 24,
              width: 24,
              child: UiUtils.imageType(
                facility.image ?? '',
                color: context.color.tertiaryColor,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomText(
              facility.name ?? '',
              maxLines: 3,
            ),
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            keyboard: TextInputType.number,
            validator: CustomTextFieldValidator.nullCheck,
            hintText: '00',
            formaters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            controller: controller,
            dense: true,
            suffix: SizedBox(
              width: 5,
              child: Center(
                child: CustomText(
                  '$distanceOption'.firstUpperCase(),
                  color: context.color.textLightColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

class OutdoorFacilityWithController {
  const OutdoorFacilityWithController({
    required this.facility,
    required this.controller,
  });

  factory OutdoorFacilityWithController.fromMap(Map<String, dynamic> map) {
    return OutdoorFacilityWithController(
      facility: map['facility'] as OutdoorFacility,
      controller: map['controller'] as TextEditingController,
    );
  }

  final OutdoorFacility facility;
  final TextEditingController controller;

  @override
  String toString() {
    return 'OutdoorFacilityWithController{ facility: $facility, controller: $controller,}';
  }

  OutdoorFacilityWithController copyWith({
    OutdoorFacility? facility,
    TextEditingController? controller,
  }) {
    return OutdoorFacilityWithController(
      facility: facility ?? this.facility,
      controller: controller ?? this.controller,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facility': facility,
      'controller': controller,
    };
  }
}

class OutdoorFacilityTable extends StatefulWidget {
  const OutdoorFacilityTable({
    required this.child,
    required this.length,
    super.key,
  });

  final int length;
  final Widget Function(int index) child;

  @override
  State<OutdoorFacilityTable> createState() => _OutdoorFacilityTableState();
}

class _OutdoorFacilityTableState extends State<OutdoorFacilityTable> {
  final PageController _pageController = PageController();
  int rowCount = 3;
  Map? sizeMap = {};
  int colCount = 3;
  late int totalData = widget.length;
  int itemsPerPage = 9;
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: (sizeMap?.isEmpty ?? true)
              ? 290
              : (sizeMap?[Key(selectedPage.toString())]?.height ?? 290),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              selectedPage = value;
              setState(() {});
            },
            physics: const BouncingScrollPhysics(),
            itemCount: (totalData / itemsPerPage).ceil(),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage) > totalData
                  ? totalData
                  : (startIndex + itemsPerPage);

              final gridData = List.generate(
                endIndex - startIndex,
                (index) {
                  return 'Data ${startIndex + index + 1}';
                },
              );

              final pageKey = Key(pageIndex.toString());
              return GridView.builder(
                shrinkWrap: true,
                key: pageKey,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisCount: colCount,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  height: 83,
                ),
                itemCount: gridData.length,
                itemBuilder: (BuildContext c, int index) {
                  final dataIndex = startIndex + index;
                  return widget.child.call(dataIndex);
                },
              );
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate((totalData / itemsPerPage).ceil(), (index) {
              final isSelected = selectedPage == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    border: isSelected
                        ? const Border()
                        : Border.all(color: context.color.textColorDark),
                    color: isSelected
                        ? context.color.tertiaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
