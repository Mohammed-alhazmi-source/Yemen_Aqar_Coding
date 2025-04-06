import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:ebroker/ui/screens/home/widgets/property_horizontal_card.dart';
import 'package:ebroker/ui/screens/widgets/errors/no_data_found.dart';
import 'package:ebroker/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:ebroker/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int propertyScreenCurrentPage = 0;
ValueNotifier<Map> emptyCheckNotifier =
    ValueNotifier({'isSellEmpty': false, 'isRentEmpty': false});

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => MyPropertyState();
}

enum FilterType { status, propertyType }

class MyPropertyState extends State<PropertiesScreen>
    with TickerProviderStateMixin {
  int offset = 0;
  int total = 0;
  bool isSellEmpty = false;
  bool isRentEmpty = false;
  final controller = ScrollController();
  String selectedType = '';
  String selectedStatus = '';
  // Track temporary filter selections
  late String tempSelectedType;
  late String tempSelectedStatus;

  @override
  void initState() {
    tempSelectedType = selectedType;
    tempSelectedStatus = selectedStatus;
    fetchMyProperties();
    addScrollListener();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  addScrollListener() {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (context.read<FetchMyPropertiesCubit>().hasMoreData()) {
          context.read<FetchMyPropertiesCubit>().fetchMoreProperties(
              type: selectedType.toLowerCase(),
              status: selectedStatus.toLowerCase());
        }
      }
    });
  }

  Future<void> fetchMyProperties() async {
    await context.read<FetchMyPropertiesCubit>().fetchMyProperties(
          type: selectedType.toLowerCase(),
          status: selectedStatus.toLowerCase(),
        );
  }

  String statusText(String text) {
    if (text == '1') {
      return UiUtils.translate(context, 'active');
    } else if (text == '0') {
      return UiUtils.translate(context, 'inactive');
    } else if (text == 'rejected') {
      return UiUtils.translate(context, 'rejected');
    } else if (text == 'pending') {
      return UiUtils.translate(context, 'pending');
    }
    return '';
  }

  Color statusColor(String text) {
    if (text == '1') {
      return Colors.green;
    } else if (text == '0') {
      return Colors.orangeAccent;
    } else if (text == 'rejected') {
      return Colors.redAccent;
    } else if (text == 'pending') {
      return Colors.blue;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'myProperty'),
        hideTopBorder: true,
        actions: [
          GestureDetector(
            onTap: show,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: UiUtils.getSvg(
                  AppIcons.filter,
                  width: 24,
                  height: 24,
                )),
          )
        ],
      ),
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await fetchMyProperties();
        },
        child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
          builder: (context, state) {
            if (state is FetchMyPropertiesInProgress) {
              return buildMyPropertyShimmer();
            }
            if (state is FetchMyPropertiesFailure) {}
            if (state is FetchMyPropertiesSuccess && state.myProperty.isEmpty) {
              return NoDataFound(
                onTap: fetchMyProperties,
              );
            }
            if (state is FetchMyPropertiesSuccess &&
                state.myProperty.isNotEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                controller: controller,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                itemCount:
                    state.myProperty.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 2,
                  );
                },
                itemBuilder: (context, index) {
                  final property = state.myProperty[index];
                  final status = property.requestStatus.toString() == 'approved'
                      ? property.status.toString()
                      : property.requestStatus.toString();
                  return BlocProvider(
                    create: (context) => AddToFavoriteCubitCubit(),
                    child: PropertyHorizontalCard(
                      property: property,
                      showLikeButton: false,
                      statusButton: StatusButton(
                        lable: statusText(status),
                        color: statusColor(status).withValues(alpha: 0.2),
                        textColor: statusColor(status),
                      ),
                      // useRow: true,
                    ),
                  );
                },
              );
            }
            return SomethingWentWrong();
          },
        ),
      ),
    );
  }

  void show() {
    // Reset temporary selections to current values when opening filter
    tempSelectedType = selectedType;
    tempSelectedStatus = selectedStatus;

    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: context.color.secondaryColor,
        isScrollControlled: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
                color: context.color.secondaryColor,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Filter',
                      color: context.color.inverseSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      'Status',
                      color: context.color.inverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildFilterCheckbox('All', tempSelectedStatus, '',
                              FilterType.status, setModalState),
                          buildFilterCheckbox('Approved', tempSelectedStatus,
                              'approved', FilterType.status, setModalState),
                          buildFilterCheckbox('Rejected', tempSelectedStatus,
                              'rejected', FilterType.status, setModalState),
                          buildFilterCheckbox('Pending', tempSelectedStatus,
                              'pending', FilterType.status, setModalState),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      'Type',
                      color: context.color.inverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildFilterCheckbox('All', tempSelectedType, '',
                              FilterType.propertyType, setModalState),
                          buildFilterCheckbox('Sell', tempSelectedType, 'sell',
                              FilterType.propertyType, setModalState),
                          buildFilterCheckbox('Rent', tempSelectedType, 'rent',
                              FilterType.propertyType, setModalState),
                          buildFilterCheckbox('Sold', tempSelectedType, 'sold',
                              FilterType.propertyType, setModalState),
                          buildFilterCheckbox('Rented', tempSelectedType,
                              'rented', FilterType.propertyType, setModalState),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    UiUtils.buildButton(context, onPressed: () async {
                      // Apply the temporary selections
                      setState(() {
                        selectedType = tempSelectedType;
                        selectedStatus = tempSelectedStatus;
                      });

                      // Close the modal
                      Navigator.pop(context);

                      // Fetch properties with new filters
                      await fetchMyProperties();
                    },
                        height: 50,
                        buttonTitle: 'applyFilter'.translate(context))
                  ],
                ),
              );
            },
          );
        });
  }

  Widget buildFilterCheckbox(String title, String currentValue,
      String optionValue, FilterType filterType, StateSetter setModalState) {
    bool isSelected = currentValue.toLowerCase() == optionValue.toLowerCase();

    return GestureDetector(
      onTap: () {
        setModalState(() {
          switch (filterType) {
            case FilterType.status:
              tempSelectedStatus = optionValue.toLowerCase();
            case FilterType.propertyType:
              tempSelectedType = optionValue.toLowerCase();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? context.color.tertiaryColor
                : context.color.borderColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? context.color.tertiaryColor
              : context.color.primaryColor,
        ),
        child: CustomText(
          title,
          color: isSelected
              ? context.color.buttonColor
              : context.color.inverseSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildMyPropertyShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 26,
        horizontal: 16,
      ),
      itemCount: 15,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: CustomShimmer(height: 90, width: 90),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmer(
                      height: 10,
                      width: context.screenWidth - 50,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomShimmer(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmer(
                      height: 10,
                      width: context.screenWidth / 1.2,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmer(
                      height: 10,
                      width: context.screenWidth / 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
