part of '../personalized_property_screen.dart';

class OtherInterests extends StatefulWidget {
  const OtherInterests({
    required this.onInteraction,
    required this.type,
    super.key,
  });

  final PersonalizedVisitType type;
  final Function(
    RangeValues priceRange,
    String location,
    List<int> propertyType,
  ) onInteraction;

  @override
  State<OtherInterests> createState() => _OtherInterestsState();
}

class _OtherInterestsState extends State<OtherInterests> {
  String selectedLocation = '';
  final TextEditingController _cityController = TextEditingController();
  late final min = personalizedInterestSettings.priceRange.first;
  late final max = personalizedInterestSettings.priceRange.last;
  RangeValues _priceRangeValues = const RangeValues(0, 100);
  RangeValues _selectedRangeValues = const RangeValues(0, 50);
  final _minTextController = TextEditingController();
  final _maxTextController = TextEditingController();

  GooglePlaceRepository googlePlaceRepository = GooglePlaceRepository();
  List<int> selectedPropertyType = [0, 1];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        selectedPropertyType = personalizedInterestSettings.propertyType;
        _minTextController.text =
            personalizedInterestSettings.priceRange.first.toString();
        _maxTextController.text =
            personalizedInterestSettings.priceRange.last.toString();
        if (personalizedInterestSettings.city.isNotEmpty) {
          _cityController.text =
              personalizedInterestSettings.city.firstUpperCase();
          selectedLocation = personalizedInterestSettings.city;
        }

        widget.onInteraction
            .call(_selectedRangeValues, selectedLocation, selectedPropertyType);
        setState(() {});
        final state = context.read<FetchSystemSettingsCubit>().state;
        if (state is FetchSystemSettingsSuccess) {
          final settingsData = state.settings['data'];
          final minPrice = double.parse(settingsData['min_price']);
          final maxPrice = double.parse(settingsData['max_price']);
          _priceRangeValues = RangeValues(minPrice, maxPrice);
          if (min != 0.0 && max != 0.0) {
            _selectedRangeValues = RangeValues(min, max);
          } else {
            _selectedRangeValues = RangeValues(minPrice, maxPrice / 4);
          }
          // Update text controllers with initial values
          _updateTextControllers(_selectedRangeValues);
        }
      },
    );

    // Add listeners to text controllers
    _minTextController.addListener(_handleMinTextChange);
    _maxTextController.addListener(_handleMaxTextChange);

    super.initState();
  }

  @override
  void dispose() {
    // Remove listeners when disposing
    _minTextController.removeListener(_handleMinTextChange);
    _maxTextController.removeListener(_handleMaxTextChange);
    _minTextController.dispose();
    _maxTextController.dispose();
    super.dispose();
  }

  // Update text controllers when range slider changes
  void _updateTextControllers(RangeValues values) {
    _minTextController.text = values.start.toInt().toString();
    _maxTextController.text = values.end.toInt().toString();
  }

  // Handle changes in minimum value text field
  void _handleMinTextChange() {
    if (_minTextController.text.isEmpty) return;

    var newStart = double.tryParse(_minTextController.text);
    if (newStart != null) {
      if (newStart < _priceRangeValues.start) {
        newStart = _priceRangeValues.start;
        _minTextController.text = newStart.toInt().toString();
      }
      if (newStart > _selectedRangeValues.end) {
        newStart = _selectedRangeValues.end;
        _minTextController.text = newStart.toInt().toString();
      }

      setState(() {
        _selectedRangeValues = RangeValues(newStart!, _selectedRangeValues.end);
      });
      widget.onInteraction.call(
        _selectedRangeValues,
        selectedLocation,
        selectedPropertyType,
      );
    }
  }

  // Handle changes in maximum value text field
  void _handleMaxTextChange() {
    if (_maxTextController.text.isEmpty) return;

    var newEnd = double.tryParse(_maxTextController.text);
    if (newEnd != null) {
      if (newEnd > _priceRangeValues.end) {
        newEnd = _priceRangeValues.end;
        _maxTextController.text = newEnd.toInt().toString();
      }
      if (newEnd < _selectedRangeValues.start) {
        newEnd = _selectedRangeValues.start;
        _maxTextController.text = newEnd.toInt().toString();
      }

      setState(() {
        _selectedRangeValues = RangeValues(_selectedRangeValues.start, newEnd!);
      });
      widget.onInteraction.call(
        _selectedRangeValues,
        selectedLocation,
        selectedPropertyType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context, showBackButton: true, actions: [
        if (isFirstTime)
          GestureDetector(
            onTap: () {
              HelperUtils.killPreviousPages(
                context,
                Routes.main,
                {'from': 'login'},
              );
            },
            child: Chip(
                label: CustomText(
              'skip'.translate(context),
              color: context.color.buttonColor,
            )),
          ),
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  CustomText(
                    'selectCityYouWantToSee'.translate(context),
                    maxLines: 2,
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              buildCitySearchTextField(context),
              if (selectedLocation.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      CustomText(
                        'selectedLocation'.translate(context),
                        fontSize: context.font.large,
                        fontWeight: FontWeight.w600,
                        color:
                            context.color.textColorDark.withValues(alpha: 0.6),
                      ),
                      Expanded(
                          child: CustomText(
                        selectedLocation,
                        fontSize: context.font.large,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ),
              CustomText(
                'choosePropertyType'.translate(context),
                fontSize: context.font.large,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: 10,
              ),
              PropertyTypeSelector(
                onInteraction: (List<int> values) {
                  selectedPropertyType = values;
                  widget.onInteraction
                      .call(_selectedRangeValues, selectedLocation, values);

                  setState(() {});
                },
              ),
              const SizedBox(
                height: 25,
              ),
              CustomText(
                'chooseTheBudeget'.translate(context),
                fontSize: context.font.large,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CustomText('minLbl'.translate(context)),
                            CustomText(
                              _selectedRangeValues.start
                                  .toInt()
                                  .toString()
                                  .priceFormat(context: context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: RangeSlider(
                          activeColor: context.color.tertiaryColor,
                          values: _selectedRangeValues,
                          onChanged: (RangeValues value) {
                            setState(() {
                              _selectedRangeValues = value;
                              _updateTextControllers(
                                value,
                              ); // Update text controllers when slider changes
                            });
                            widget.onInteraction.call(
                              _selectedRangeValues,
                              selectedLocation,
                              selectedPropertyType,
                            );
                          },
                          min: _priceRangeValues.start,
                          max: _priceRangeValues.end,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            CustomText('maxLbl'.translate(context)),
                            CustomText(
                              _selectedRangeValues.end
                                  .toInt()
                                  .toString()
                                  .priceFormat(context: context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            action: TextInputAction.next,
                            controller: _minTextController,
                            isReadOnly: false,
                            keyboard: TextInputType.number,
                            validator: CustomTextFieldValidator.nullCheck,
                            hintText: 'min'.translate(context),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            action: TextInputAction.next,
                            controller: _maxTextController,
                            isReadOnly: false,
                            keyboard: TextInputType.number,
                            validator: CustomTextFieldValidator.nullCheck,
                            hintText: 'max'.translate(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCitySearchTextField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.color.borderColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.zero,
      child: TypeAheadField(
        builder: (context, controller, focusNode) {
          return TextField(
              autofocus: false,
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.color.tertiaryColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: context.color.tertiaryColor,
                )),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.color.tertiaryColor,
                  ),
                ),
              ));
        },
        errorBuilder: (context, error) {
          return const CustomText('Error');
        },
        loadingBuilder: (context) {
          return Center(child: UiUtils.progress());
        },
        itemBuilder: (context, GooglePlaceModel itemData) {
          final address = <String>[
            itemData.city,
            itemData.state,
            itemData.country
          ];

          return ListTile(
            tileColor: context.color.secondaryColor,
            title: CustomText(address.join(',')),
          );
        },
        suggestionsCallback: (String pattern) async {
          if (pattern.length < 2) {
            return Future.value(<GooglePlaceModel>[]);
          }
          return googlePlaceRepository.serchCities(
            pattern,
          );
        },
        onSelected: (GooglePlaceModel suggestion) {
          final addressList = <String>[
            suggestion.city,
            suggestion.state,
            suggestion.country
          ];
          final address = addressList.join(',');
          _cityController.text = address;
          selectedLocation = address;
          widget.onInteraction.call(
            _selectedRangeValues,
            selectedLocation,
            selectedPropertyType,
          );

          FocusScope.of(context).unfocus();
          setState(() {});
        },
      ),
    );
  }
}

class PropertyTypeSelector extends StatefulWidget {
  const PropertyTypeSelector({
    required this.onInteraction,
    super.key,
  });

  final Function(List<int> values) onInteraction;

  @override
  State<PropertyTypeSelector> createState() => _PropertyTypeSelectorState();
}

class _PropertyTypeSelectorState extends State<PropertyTypeSelector> {
  List<int> selectedPropertyType = [0, 1];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        if (personalizedInterestSettings.propertyType.isNotEmpty) {
          selectedPropertyType = personalizedInterestSettings.propertyType;
        }

        widget.onInteraction.call(selectedPropertyType);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAddAll([0, 1]);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label: CustomText(
              'all'.translate(context),
              fontSize: context.font.large,
              color: selectedPropertyType.containesAll([0, 1])
                  ? context.color.buttonColor
                  : context.color.textColorDark,
            ),
            backgroundColor: selectedPropertyType.containesAll([0, 1])
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAdd(0);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label: CustomText(
              'sell'.translate(context),
              fontSize: context.font.large,
              color: selectedPropertyType.isSingleElementAndIs(0)
                  ? context.color.buttonColor
                  : context.color.textColorDark,
            ),
            backgroundColor: selectedPropertyType.isSingleElementAndIs(0)
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAdd(1);
            widget.onInteraction.call(selectedPropertyType);
            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label: CustomText(
              'rent'.translate(context),
              fontSize: context.font.large,
              color: selectedPropertyType.isSingleElementAndIs(1)
                  ? context.color.buttonColor
                  : context.color.textColorDark,
            ),
            backgroundColor: selectedPropertyType.isSingleElementAndIs(1)
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
      ],
    );
  }
}
