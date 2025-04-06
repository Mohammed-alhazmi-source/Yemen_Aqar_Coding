part of '../personalized_property_screen.dart';

class NearbyInterest extends StatefulWidget {
  const NearbyInterest({
    required this.controller,
    required this.onInteraction,
    required this.type,
    super.key,
  });
  final PageController controller;

  final PersonalizedVisitType type;
  final Function(List<int> selectedNearbyPlacesIds) onInteraction;

  @override
  State<NearbyInterest> createState() => _NearbyInterestState();
}

class _NearbyInterestState extends State<NearbyInterest>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedIds = personalizedInterestSettings.outdoorFacilityIds;
  @override
  void initState() {
    context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    final facilityList =
        context.watch<FetchOutdoorFacilityListCubit>().getList();
    final facilityLength = facilityList.length;
    final state = context.watch<FetchOutdoorFacilityListCubit>().state;
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        actions: [
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
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'chooseNearbyPlaces'.translate(context),
                fontSize: context.font.large,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                width: 14,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                'getRecommandation'.translate(context),
                fontSize: context.font.normal,
                color: context.color.textColorDark,
              ),
              const SizedBox(
                height: 15,
              ),
              if (state is FetchOutdoorFacilityListInProgress) ...{
                UiUtils.progress(),
              },
              Wrap(
                children: List.generate(facilityLength, (index) {
                  final facility = facilityList[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
                    child: GestureDetector(
                      onTap: () {
                        selectedIds.addOrRemove(facility.id!);
                        widget.onInteraction.call(selectedIds);
                        setState(() {});
                      },
                      child: Chip(
                        shape: StadiumBorder(
                          side: BorderSide(color: context.color.borderColor),
                        ),
                        backgroundColor: selectedIds.contains(facility.id)
                            ? context.color.tertiaryColor
                            : context.color.secondaryColor,
                        padding: const EdgeInsets.all(5),
                        label: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CustomText(
                            facility.name.toString(),
                            color: selectedIds.contains(facility.id)
                                ? context.color.buttonColor
                                : context.color.textColorDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
