part of '../personalized_property_screen.dart';

class CategoryInterestChoose extends StatefulWidget {
  const CategoryInterestChoose({
    required this.controller,
    required this.onInteraction,
    required this.type,
    required this.onClearFilter,
    super.key,
  });
  final PageController controller;
  final VoidCallback onClearFilter;
  final PersonalizedVisitType type;
  final Function(List<int> selectedCategoryId) onInteraction;

  @override
  State<CategoryInterestChoose> createState() => _CategoryInterestChooseState();
}

class _CategoryInterestChooseState extends State<CategoryInterestChoose>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedCategoryId = personalizedInterestSettings.categoryIds;

  @override
  Widget build(BuildContext context) {
    final isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        actions: [
          if (!isFirstTime && selectedCategoryId.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.onClearFilter.call();
              },
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 18),
                child: CustomText(
                  'clear'.translate(context),
                  fontWeight: FontWeight.bold,
                  showUnderline: true,
                  color: context.color.textColorDark,
                  fontSize: context.font.large,
                ),
              ),
            ),
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
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'chooseYourInterest'.translate(context),
              fontSize: context.font.large,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(
              height: 25,
            ),
            Wrap(
              children: List.generate(
                  context.watch<FetchCategoryCubit>().getCategories().length,
                  (index) {
                final categorie =
                    context.watch<FetchCategoryCubit>().getCategories()[index];
                final isSelected = selectedCategoryId
                    .contains(int.parse(categorie.id!.toString()));
                return Padding(
                  padding: const EdgeInsets.all(3),
                  child: GestureDetector(
                    onTap: () {
                      selectedCategoryId
                          .addOrRemove(int.parse(categorie.id!.toString()));
                      widget.onInteraction.call(selectedCategoryId);
                      setState(() {});
                    },
                    child: Chip(
                      shape: StadiumBorder(
                        side: BorderSide(color: context.color.borderColor),
                      ),
                      backgroundColor: isSelected
                          ? context.color.tertiaryColor
                          : context.color.secondaryColor,
                      padding: const EdgeInsets.all(5),
                      label: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CustomText(
                          categorie.category.toString(),
                          color: isSelected
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
