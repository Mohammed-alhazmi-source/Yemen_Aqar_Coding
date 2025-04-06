// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:developer';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:ebroker/data/cubits/Interested/get_interested_user_cubit.dart';
import 'package:ebroker/data/cubits/Report/property_report_cubit.dart';
import 'package:ebroker/data/cubits/Utility/mortgage_calculator_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/cubits/property/Interest/change_interest_in_property_cubit.dart';
import 'package:ebroker/data/cubits/property/change_property_status_cubit.dart';
import 'package:ebroker/data/cubits/property/delete_property_cubit.dart';
import 'package:ebroker/data/cubits/property/update_property_status.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/interested_user_model.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:ebroker/ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/mortgage_calculator.dart';
import 'package:ebroker/ui/screens/proprties/widgets/report_property_widget.dart';
import 'package:ebroker/ui/screens/widgets/all_gallary_image.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/panaroma_image_view.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:ebroker/ui/screens/widgets/video_view_screen.dart';
import 'package:ebroker/utils/AdMob/interstitialAdManager.dart';
import 'package:ebroker/utils/Network/networkAvailability.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PropertyDetails extends StatefulWidget {
  final PropertyModel? property;

  final bool? fromMyProperty;
  final bool? fromCompleteEnquiry;
  final bool? fromPropertyAddSuccess;

  const PropertyDetails({
    required this.property,
    super.key,
    this.fromPropertyAddSuccess,
    this.fromMyProperty,
    this.fromCompleteEnquiry,
  });

  @override
  PropertyDetailsState createState() => PropertyDetailsState();

  static Route route(RouteSettings routeSettings) {
    try {
      final arguments = routeSettings.arguments as Map?;
      return BlurredRouter(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChangeInterestInPropertyCubit(),
            ),
            BlocProvider(
              create: (context) => UpdatePropertyStatusCubit(),
            ),
            BlocProvider(
              create: (context) => DeletePropertyCubit(),
            ),
            BlocProvider(
              create: (context) => PropertyReportCubit(),
            ),
            BlocProvider(
              create: (context) => GetInterestedUserCubit(),
            ),
            BlocProvider(
              create: (context) => FetchAgentsPropertyCubit(),
            ),
          ],
          child: PropertyDetails(
            property: arguments?['propertyData'],
            fromMyProperty: arguments?['fromMyProperty'] ?? false,
            fromCompleteEnquiry: arguments?['fromCompleteEnquiry'] ?? false,
            fromPropertyAddSuccess: arguments?['fromSuccess'] ?? false,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FlickManager? flickManager;
  ValueNotifier<bool> shouldShowSubscriptionOverlay = ValueNotifier(false);

  // late Property propertyData;
  int selectedIndexExpansionTileForYears = -1;
  int selectedIndexExpansionTileForMonths = -1;
  bool favoriteInProgress = false;
  bool isPlayingYoutubeVideo = false;
  bool fromMyProperty = false; //get its value from Widget
  bool fromCompleteEnquiry = false; //get its value from Widget
  List promotedProeprtiesIds = [];
  bool toggleEnqButton = false;
  PropertyModel? property;
  bool isPromoted = false;
  bool showGoogleMap = false;
  bool isEnquiryFromChat = false;
  BannerAd? _bannerAd;
  bool isVerified = false;
  bool isEnabled = false;
  bool isApproved = false;
  bool isProfileCompleted = HiveUtils.getUserDetails().email != '' &&
      HiveUtils.getUserDetails().mobile != '' &&
      HiveUtils.getUserDetails().name != '' &&
      HiveUtils.getUserDetails().address != '' &&
      HiveUtils.getUserDetails().profile != '';
  @override
  bool get wantKeepAlive => true;
  GlobalKey appBarKey = GlobalKey();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Gallery>? gallary;
  String youtubeVideoThumbnail = '';
  late bool? isLoaded;
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  bool isPremiumProperty = true;
  bool isPremiumUser = false;
  bool isReported = false;

  bool shouldRestrictPropertyAccess() {
    if (isPremiumProperty &&
        !isPremiumUser &&
        property!.addedBy.toString() != HiveUtils.getUserId()) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    isEnabled = widget.property?.status.toString() == '1';
    isApproved = widget.property?.requestStatus.toString() == 'approved';
    isVerified = widget.property?.isVerified ?? false;
    isPremiumProperty = widget.property?.allPropData['is_premium'] ?? false;

    isPremiumUser = context
            .read<FetchSystemSettingsCubit>()
            .getRawSettings()['is_premium'] ??
        false;
    isReported = widget.property?.allPropData?['is_reported'] ?? false;

    loadAd();
    interstitialAdManager.load();
    // customListenerForConstant();
    //add title image along with gallery images
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    context.read<GetInterestedUserCubit>().fetch(
          '${widget.property?.id}',
        );
    if (HiveUtils.isGuest() == false) {
      context.read<GetChatListCubit>().fetch();
    }
    context.read<GetChatListCubit>().fetch();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        showGoogleMap = true;
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      gallary = List.from(widget.property!.gallery!);
      if (widget.property?.video != '' && widget.property?.video != null) {
        injectVideoInGallery();
        setState(() {});
      }
    });

    property = widget.property;
    setData();

    setViewedProperty();
    if (widget.property?.video != '' &&
        widget.property?.video != null &&
        !HelperUtils.isYoutubeVideo(widget.property?.video ?? '')) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(property!.video!),
        ),
      );
      flickManager?.onVideoEnd = () {};
    }

    if (widget.property?.video != '' &&
        widget.property?.video != null &&
        HelperUtils.isYoutubeVideo(widget.property?.video ?? '')) {
      final videoId = YoutubePlayer.convertUrlToId(property!.video!);
      final thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      setState(() {});
    }
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: Constant.admobBannerAndroid,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  void setData() {
    fromMyProperty = widget.fromMyProperty!;
    fromCompleteEnquiry = widget.fromCompleteEnquiry!;
  }

  void setViewedProperty() {
    if (property!.addedBy.toString() != HiveUtils.getUserId()) {
      context.read<SetPropertyViewCubit>().set(
            property!.id!.toString(),
          );
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(
        property?.latitude ?? '0',
      ),
      double.parse(
        property?.longitude ?? '0',
      ),
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  void injectVideoInGallery() {
    ///This will inject video in image list just like another platforms
    if ((gallary?.length ?? 0) < 2) {
      if (widget.property?.video != null && widget.property?.video != '') {
        gallary?.add(
          Gallery(
            id: 99999999999,
            image: property!.video ?? '',
            imageUrl: '',
            isVideo: true,
          ),
        );
      }
    } else {
      gallary?.insert(
        0,
        Gallery(
          id: 99999999999,
          image: property!.video!,
          imageUrl: '',
          isVideo: true,
        ),
      );
    }
    setState(() {});
  }

  String? _statusFilter(String value) {
    if (value == 'Sell' || value == 'sell') {
      return 'sold'.translate(context);
    }
    if (value == 'Rent' || value == 'rent') {
      return 'Rented'.translate(context);
    }

    return null;
  }

  int? _getStatus(type) {
    int? value;
    if (type == 'Sell' || type == 'sell') {
      value = 2;
    } else if (type == 'Rent' || type == 'rent') {
      value = 3;
    } else if (type == 'Rented' || type == 'rented') {
      value = 1;
    }
    return value;
  }

  bool hasDocuments() {
    return widget.property!.documents!.isNotEmpty;
  }

//main build
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var rentPrice = property!.price!
        .priceFormat(
          enabled: Constant.isNumberWithSuffix == true,
          context: context,
        )
        .formatAmount(prefix: true);

    if (property?.rentduration != '' && property?.rentduration != null) {
      rentPrice =
          ('$rentPrice / ') + (property!.rentduration ?? '').translate(context);
    }

    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await interstitialAdManager.show();
          context.read<MortgageCalculatorCubit>().emptyMortgageCalculatorData();
          if (widget.property?.addedBy.toString() == HiveUtils.getUserId()) {
            context.read<FetchMyPropertiesCubit>().fetchMyProperties(
                  type: '',
                  status: '',
                );
          }
          if (widget.fromPropertyAddSuccess ?? false) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            setState(() {
              showGoogleMap = false;
            });
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          }
        },
        child: SafeArea(
          child: BlocListener<GetSubsctiptionPackageLimitsCubit,
              GetSubscriptionPackageLimitsState>(
            listener: (context, state) {
              if (state is GetSubscriptionPackageLimitsSuccess) {
                isPremiumUser = state.hasSubscription;
                setState(() {});
              }
            },
            child: Stack(
              children: [
                Scaffold(
                  appBar: UiUtils.buildAppBar(
                    context,
                    hideTopBorder: true,
                    showBackButton: true,
                    actions: [
                      const Spacer(),
                      if (!HiveUtils.isGuest()) ...[
                        if (int.parse(HiveUtils.getUserId() ?? '0') ==
                            property?.addedBy)
                          IconButton(
                            onPressed: () async {
                              final interestedUserCubitReference =
                                  context.read<GetInterestedUserCubit>();
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: context.color.secondaryColor,
                                constraints: BoxConstraints(
                                  minWidth: double.infinity,
                                  maxHeight: context.screenHeight * 0.7,
                                  minHeight: context.screenHeight * 0.3,
                                ),
                                builder: (context) {
                                  return InterestedUserListWidget(
                                    totalCount:
                                        '${widget.property?.totalInterestedUsers}',
                                    interestedUserCubitReference:
                                        interestedUserCubitReference,
                                  );
                                },
                              );
                              return;
                            },
                            icon: Icon(
                              Icons.analytics,
                              color: context.color.tertiaryColor,
                            ),
                          ),
                        if (!(int.parse(HiveUtils.getUserId() ?? '0') ==
                            property?.addedBy))
                          IconButton(
                            onPressed: () {
                              HelperUtils.share(
                                context,
                                property!.id!,
                                property?.slugId ?? '',
                              );
                            },
                            icon: Icon(
                              Icons.share,
                              color: context.color.tertiaryColor,
                            ),
                          ),
                      ],
                      if (property?.addedBy.toString() == HiveUtils.getUserId())
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            final state =
                                context.read<ChangePropertyStatusCubit>().state;
                            final successState = context
                                .read<ChangePropertyStatusCubit>()
                                .state is ChangePropertyStatusSuccess;
                            final failureState = context
                                .read<ChangePropertyStatusCubit>()
                                .state is ChangePropertyStatusFailure;
                            if (value == 'enable') {
                              await context
                                  .read<ChangePropertyStatusCubit>()
                                  .enableProperty(
                                      propertyId: property!.id!,
                                      status: property!.status as int);
                              if (successState) {
                                isEnabled = true;
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  (state as ChangePropertyStatusSuccess)
                                          .message ??
                                      'statusChanged'.translate(context),
                                  type: MessageType.success,
                                );
                              } else if (failureState) {
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  (state as ChangePropertyStatusFailure).error,
                                  type: MessageType.success,
                                );
                              }
                              return;
                            }
                            if (value == 'disable') {
                              await context
                                  .read<ChangePropertyStatusCubit>()
                                  .disableProperty(
                                      propertyId: property!.id!,
                                      status: property!.status as int);
                              if (successState) {
                                isEnabled = false;
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  (state as ChangePropertyStatusSuccess)
                                          .message ??
                                      'statusChanged'.translate(context),
                                  type: MessageType.success,
                                );
                              } else if (failureState) {
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  (state as ChangePropertyStatusFailure).error,
                                  type: MessageType.success,
                                );
                              }

                              return;
                            }
                            if (value == 'share') {
                              HelperUtils.share(
                                context,
                                property!.id!,
                                property?.slugId ?? '',
                              );
                              return;
                            }
                            if (value == 'interestedUsers') {
                              final interestedUserCubitReference =
                                  context.read<GetInterestedUserCubit>();
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: context.color.secondaryColor,
                                constraints: BoxConstraints(
                                  minWidth: double.infinity,
                                  maxHeight: context.screenHeight * 0.7,
                                  minHeight: context.screenHeight * 0.3,
                                ),
                                builder: (context) {
                                  return InterestedUserListWidget(
                                    totalCount:
                                        '${widget.property?.totalInterestedUsers}',
                                    interestedUserCubitReference:
                                        interestedUserCubitReference,
                                  );
                                },
                              );
                              return;
                            }
                            if (value == 'changeStatus') {
                              final action = await UiUtils.showBlurredDialoge(
                                context,
                                dialoge: BlurredDialogBuilderBox(
                                  title:
                                      'changePropertyStatus'.translate(context),
                                  acceptButtonName: 'change'.translate(context),
                                  contentBuilder: (context, s) {
                                    return FittedBox(
                                      fit: BoxFit.none,
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  context.color.tertiaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            width: s.maxWidth / 4,
                                            height: 50,
                                            child: Center(
                                              child: CustomText(
                                                property!.properyType!
                                                    .translate(context),
                                                color:
                                                    context.color.buttonColor,
                                              ),
                                            ),
                                          ),
                                          CustomText(
                                            'toArrow'.translate(context),
                                          ),
                                          Container(
                                            width: s.maxWidth / 4,
                                            decoration: BoxDecoration(
                                              color: context.color.tertiaryColor
                                                  .withValues(alpha: 0.4),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            height: 50,
                                            child: Center(
                                                child: CustomText(
                                                    _statusFilter(
                                                          property!
                                                              .properyType!,
                                                        ) ??
                                                        '',
                                                    color: context
                                                        .color.buttonColor)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                              if (action == true) {
                                Future.delayed(Duration.zero, () {
                                  context
                                      .read<UpdatePropertyStatusCubit>()
                                      .update(
                                        propertyId: property!.id,
                                        status:
                                            _getStatus(property!.properyType),
                                      );
                                });
                              }
                            }
                          },
                          color: context.color.secondaryColor,
                          itemBuilder: (BuildContext context) {
                            return [
                              if (isApproved == true && isEnabled == false)
                                PopupMenuItem<String>(
                                  value: 'enable',
                                  textStyle: TextStyle(
                                    color: context.color.textColorDark,
                                  ),
                                  child: CustomText(
                                    'enable'.translate(context),
                                  ),
                                ),
                              if (isApproved == true && isEnabled == true)
                                PopupMenuItem<String>(
                                  value: 'disable',
                                  textStyle: TextStyle(
                                    color: context.color.textColorDark,
                                  ),
                                  child: CustomText(
                                    'disable'.translate(context),
                                  ),
                                ),
                              PopupMenuItem<String>(
                                value: 'share',
                                textStyle: TextStyle(
                                  color: context.color.textColorDark,
                                ),
                                child: CustomText(
                                  'share'.translate(context),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'interestedUsers',
                                textStyle: TextStyle(
                                  color: context.color.textColorDark,
                                ),
                                child: CustomText(
                                    'interestedUsers'.translate(context)),
                              ),
                              PopupMenuItem<String>(
                                value: 'changeStatus',
                                textStyle: TextStyle(
                                  color: context.color.textColorDark,
                                ),
                                child: CustomText(
                                    'changeStatus'.translate(context)),
                              ),
                            ];
                            // return {
                            //   'changeStatus'.translate(context),
                            // }.map((String choice) {
                            //   return PopupMenuItem<String>(
                            //     value: choice,
                            //     textStyle: TextStyle(
                            //       color: context.color.textColorDark,
                            //     ),
                            //     child: CustomText(choice),
                            //   );
                            // }).toList();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.more_vert_rounded,
                              color: context.color.tertiaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  backgroundColor: context.color.backgroundColor,
                  floatingActionButton: (property == null ||
                          property!.addedBy.toString() == HiveUtils.getUserId())
                      ? const SizedBox.shrink()
                      : Container(),
                  bottomNavigationBar: isPlayingYoutubeVideo == false
                      ? BottomAppBar(
                          key: appBarKey,
                          padding: EdgeInsets.zero,
                          color: context.color.secondaryColor,
                          child: bottomNavBar(),
                        )
                      : null,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  body: BlocListener<DeletePropertyCubit, DeletePropertyState>(
                    listener: (context, state) {
                      if (state is DeletePropertyInProgress) {
                        Widgets.showLoader(context);
                      }

                      if (state is DeletePropertySuccess) {
                        Widgets.hideLoder(context);
                        Future.delayed(
                          const Duration(milliseconds: 1000),
                          () {
                            Navigator.pop(context, true);
                          },
                        );
                      }
                      if (state is DeletePropertyFailure) {
                        Widgets.showLoader(context);
                      }
                    },
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: BlocListener<UpdatePropertyStatusCubit,
                            UpdatePropertyStatusState>(
                          listener: (context, state) {
                            if (state is UpdatePropertyStatusSuccess) {
                              Widgets.hideLoder(context);
                              Fluttertoast.showToast(
                                msg: 'statusUpdated'.translate(context),
                                backgroundColor: successMessageColor,
                                gravity: ToastGravity.TOP,
                                toastLength: Toast.LENGTH_LONG,
                              );

                              (cubitReference!).updateStatus(
                                property!.id!,
                                property!.properyType!,
                              );
                              setState(() {});
                            }
                            if (state is UpdatePropertyStatusFail) {
                              Widgets.hideLoder(context);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  isPlayingYoutubeVideo == false ? 20.0 : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),

                                if (!isPlayingYoutubeVideo)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: SizedBox(
                                          height: 227.rh(context),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // google map doesn't allow blur so we hide it:)
                                                  showGoogleMap = false;
                                                  setState(() {});
                                                  UiUtils.showFullScreenImage(
                                                    context,
                                                    provider: NetworkImage(
                                                      property!.titleImage!,
                                                    ),
                                                    then: () {
                                                      showGoogleMap = true;
                                                      setState(() {});
                                                    },
                                                  );
                                                },
                                                child: UiUtils.getImage(
                                                  property!.titleImage!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 227.rh(context),
                                                  showFullScreenImage: true,
                                                ),
                                              ),
                                              PositionedDirectional(
                                                top: 20,
                                                end: 20,
                                                child: LikeButtonWidget(
                                                  propertyId: property!.id!,
                                                  isFavourite:
                                                      property!.isFavourite!,
                                                  onStateChange: (
                                                    AddToFavoriteCubitState
                                                        state,
                                                  ) {
                                                    if (state
                                                        is AddToFavoriteCubitInProgress) {
                                                      favoriteInProgress = true;
                                                      setState(
                                                        () {},
                                                      );
                                                    } else {
                                                      favoriteInProgress =
                                                          false;
                                                      setState(
                                                        () {},
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              PositionedDirectional(
                                                bottom: 5,
                                                end: 18,
                                                child: Visibility(
                                                  visible:
                                                      property?.threeDImage !=
                                                          '',
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        BlurredRouter(
                                                          builder: (context) =>
                                                              PanaromaImageScreen(
                                                            imageUrl: property!
                                                                .threeDImage!,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: context.color
                                                            .secondaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      height: 40.rh(context),
                                                      width: 40.rw(context),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: UiUtils.getSvg(
                                                          AppIcons.v360Degree,
                                                          color: context.color
                                                              .tertiaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              advertisementLabel(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          UiUtils.imageType(
                                            property?.category!.image ?? '',
                                            width: 18,
                                            height: 18,
                                            color: Constant.adaptThemeColorSvg
                                                ? context.color.tertiaryColor
                                                : null,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: 158.rw(context),
                                            child: CustomText(
                                              property!.category!.category!,
                                              maxLines: 1,
                                              fontWeight: FontWeight.w400,
                                              fontSize: context.font.normal,
                                              color: UiUtils.makeColorLight(
                                                context.color.textColorDark,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3.5),
                                              color:
                                                  context.color.tertiaryColor,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Center(
                                                child: CustomText(
                                                  property!.properyType
                                                      .toString()
                                                      .toLowerCase()
                                                      .translate(context),
                                                  fontSize: context.font.small,
                                                  color:
                                                      context.color.buttonColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: CustomText(
                                              property!.title!.firstUpperCase(),
                                              fontWeight: FontWeight.w600,
                                              fontSize: context.font.larger,
                                              color:
                                                  context.color.textColorDark,
                                            ),
                                          ),
                                          CustomText(
                                            property?.postCreated ?? '',
                                            color: context.color.textColorDark
                                                .withValues(alpha: 0.6),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 13),
                                      Row(
                                        children: [
                                          if (property!.properyType
                                                  .toString()
                                                  .toLowerCase() ==
                                              'rent') ...[
                                            CustomText(
                                              rentPrice,
                                              fontWeight: FontWeight.w700,
                                              fontSize: context.font.larger,
                                              color:
                                                  context.color.tertiaryColor,
                                            ),
                                          ] else ...[
                                            CustomText(
                                              property!.price!
                                                  .priceFormat(
                                                    enabled: Constant
                                                            .isNumberWithSuffix ==
                                                        true,
                                                    context: context,
                                                  )
                                                  .formatAmount(prefix: true),
                                              fontWeight: FontWeight.w700,
                                              fontSize: context.font.larger,
                                              color:
                                                  context.color.tertiaryColor,
                                            ),
                                          ],
                                          if (Constant.isNumberWithSuffix) ...[
                                            if (property!.properyType
                                                    .toString()
                                                    .toLowerCase() !=
                                                'rent') ...[
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              CustomText(
                                                '(${property!.price!})',
                                                fontWeight: FontWeight.w500,
                                                fontSize: context.font.larger,
                                                color:
                                                    context.color.tertiaryColor,
                                              ),
                                            ],
                                          ],
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (widget.property?.properyType
                                              .toString()
                                              .toLowerCase() ==
                                          'sell') ...[
                                        _buildMortgageCalculatorContainer(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                      Container(
                                        padding: EdgeInsets.zero,
                                        width: double.infinity,
                                        child: GridView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          semanticChildCount:
                                              property?.parameters?.length ?? 0,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 2,
                                            mainAxisExtent: 51,
                                          ),
                                          itemCount:
                                              property?.parameters?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            final parameter =
                                                property?.parameters![index];
                                            return Container(
                                              padding: EdgeInsets.zero,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 40.rw(context),
                                                    height: 40.rh(context),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: context
                                                          .color.tertiaryColor
                                                          .withValues(
                                                        alpha: 0.2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                    child: SizedBox(
                                                      height: 30.rh(context),
                                                      width: 30.rw(context),
                                                      child: FittedBox(
                                                        child:
                                                            UiUtils.imageType(
                                                          parameter?.image ??
                                                              '',
                                                          fit: BoxFit.cover,
                                                          color: Constant
                                                                  .adaptThemeColorSvg
                                                              ? context.color
                                                                  .tertiaryColor
                                                              : null,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.rw(context),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CustomText(
                                                          parameter?.name ?? '',
                                                          textAlign:
                                                              TextAlign.start,
                                                          fontSize: context
                                                              .font.small,
                                                          color: context.color
                                                              .textColorDark
                                                              .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                        ),
                                                        if (parameter
                                                                ?.typeOfParameter ==
                                                            'file') ...{
                                                          InkWell(
                                                              onTap: () async {
                                                                await urllauncher
                                                                    .launchUrl(
                                                                  Uri.parse(
                                                                    parameter!
                                                                        .value,
                                                                  ),
                                                                  mode: LaunchMode
                                                                      .externalApplication,
                                                                );
                                                              },
                                                              child: CustomText(
                                                                UiUtils
                                                                    .translate(
                                                                  context,
                                                                  'viewFile',
                                                                ),
                                                                showUnderline:
                                                                    true,
                                                                color: context
                                                                    .color
                                                                    .tertiaryColor,
                                                              )),
                                                        } else if (parameter
                                                                ?.value
                                                            is List) ...{
                                                          Container(
                                                            color: Colors.red,
                                                            width:
                                                                MediaQuery.of(
                                                                      context,
                                                                    )
                                                                        .size
                                                                        .width *
                                                                    0.3,
                                                            child: CustomText(
                                                              (parameter?.value
                                                                      as List)
                                                                  .join(','),
                                                            ),
                                                          ),
                                                        } else ...[
                                                          if (parameter
                                                                  ?.typeOfParameter ==
                                                              'textarea') ...[
                                                            SizedBox(
                                                              width: MediaQuery
                                                                      .of(
                                                                    context,
                                                                  ).size.width *
                                                                  0.3,
                                                              child: CustomText(
                                                                '${parameter?.value}',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    context.font
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ] else ...[
                                                            ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth: MediaQuery
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .size
                                                                        .width *
                                                                    0.4,
                                                              ),
                                                              child: CustomText(
                                                                '${parameter?.value}',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    context.font
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      UiUtils.getDivider(),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      CustomText(
                                        UiUtils.translate(
                                          context,
                                          'aboutThisPropLbl',
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: context.font.large,
                                        color: context.color.textColorDark,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      ReadMoreText(
                                        text: property?.description ?? '',
                                        style: TextStyle(
                                          color: context.color.textColorDark
                                              .withValues(alpha: 0.7),
                                        ),
                                        readMoreButtonStyle: TextStyle(
                                          color: context.color.tertiaryColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // TODO(R): This is for banner ads
                                      if (_bannerAd != null &&
                                          Constant.isAdmobAdsEnabled)
                                        SizedBox(
                                          width:
                                              _bannerAd?.size.width.toDouble(),
                                          height:
                                              _bannerAd?.size.height.toDouble(),
                                          child: AdWidget(ad: _bannerAd!),
                                        ),

                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (widget
                                              .property
                                              ?.assignedOutdoorFacility
                                              ?.isNotEmpty ??
                                          false) ...[
                                        CustomText(
                                          UiUtils.translate(
                                            context,
                                            'outdoorFacilities',
                                          ),
                                          fontWeight: FontWeight.w600,
                                          fontSize: context.font.large,
                                          color: context.color.textColorDark,
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                      OutdoorFacilityListWidget(
                                        outdoorFacilityList: widget.property
                                                ?.assignedOutdoorFacility ??
                                            [],
                                      ),

                                      CustomText(
                                        UiUtils.translate(
                                          context,
                                          'listedBy',
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: context.font.large,
                                        color: context.color.textColorDark,
                                      ),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: AgentProfileWidget(
                                          hideDetails:
                                              shouldRestrictPropertyAccess(),
                                          widget: widget,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (gallary?.isNotEmpty ?? false) ...[
                                        CustomText(
                                          UiUtils.translate(
                                            context,
                                            'gallery',
                                          ),
                                          fontWeight: FontWeight.w600,
                                          color: context.color.textColorDark,
                                          fontSize: context.font.large,
                                        ),
                                        SizedBox(
                                          height: 10.rh(context),
                                        ),
                                      ],
                                      if (gallary?.isNotEmpty ?? false) ...[
                                        Row(
                                          children: List.generate(
                                            gallary?.length.clamp(0, 4) ?? 0,
                                            (index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    18,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (gallary?[index]
                                                                  .isVideo ??
                                                              false) {
                                                            return;
                                                          }
                                                          //google map doesn't allow blur so we hide it:)
                                                          showGoogleMap = false;
                                                          setState(() {});

                                                          final images = gallary
                                                              ?.map(
                                                                (e) =>
                                                                    e.imageUrl,
                                                              )
                                                              .toList();

                                                          UiUtils
                                                              .imageGallaryView(
                                                            context,
                                                            images: images!,
                                                            initalIndex: index,
                                                            then: () {
                                                              showGoogleMap =
                                                                  true;
                                                              setState(() {});
                                                            },
                                                          );
                                                        },
                                                        child: SizedBox(
                                                          width: 76.rw(context),
                                                          height:
                                                              76.rh(context),
                                                          child: gallary?[index]
                                                                      .isVideo ??
                                                                  false
                                                              ? Container(
                                                                  child: UiUtils
                                                                      .getImage(
                                                                    youtubeVideoThumbnail,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                )
                                                              : UiUtils
                                                                  .getImage(
                                                                  gallary?[index]
                                                                          .imageUrl ??
                                                                      '',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                        ),
                                                      ),
                                                      if (gallary?[index]
                                                              .isVideo ??
                                                          false)
                                                        Positioned.fill(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                                    return VideoViewScreen(
                                                                      videoUrl:
                                                                          gallary?[index].image ??
                                                                              '',
                                                                      flickManager:
                                                                          flickManager,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: ColoredBox(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                              child: FittedBox(
                                                                fit:
                                                                    BoxFit.none,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: context
                                                                        .color
                                                                        .tertiaryColor
                                                                        .withValues(
                                                                      alpha:
                                                                          0.8,
                                                                    ),
                                                                  ),
                                                                  width: 30,
                                                                  height: 30,
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .play_arrow,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (index == 3)
                                                        Positioned.fill(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                BlurredRouter(
                                                                  builder:
                                                                      (context) {
                                                                    return AllGallaryImages(
                                                                      youtubeThumbnail:
                                                                          youtubeVideoThumbnail,
                                                                      images:
                                                                          property?.gallery ??
                                                                              [],
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                  alpha: 0.3,
                                                                ),
                                                                child:
                                                                    CustomText(
                                                                  '+${(property?.gallery?.length ?? 0) - 3}',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      context
                                                                          .font
                                                                          .large,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      if (hasDocuments()) ...[
                                        CustomText(
                                          'Documents'.translate(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.font.large,
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final document = widget
                                                .property!.documents![index];
                                            return DownloadableDocuments(
                                              url: document.file!,
                                            );
                                          },
                                          itemCount: widget
                                              .property!.documents!.length,
                                        ),
                                      ],
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      CustomText(
                                        UiUtils.translate(
                                          context,
                                          'locationLbl',
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: context.font.large,
                                        color: context.color.textColorDark,
                                      ),
                                      SizedBox(
                                        height: 10.rh(context),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            "${UiUtils.translate(context, "addressLbl")} :",
                                            fontSize: context.font.normal,
                                            color: context.color.textColorDark,
                                          ),
                                          SizedBox(
                                            height: 5.rh(context),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              UiUtils.getSvg(
                                                AppIcons.location,
                                                color:
                                                    context.color.tertiaryColor,
                                              ),
                                              SizedBox(
                                                width: 5.rw(context),
                                              ),
                                              Expanded(
                                                child: HideDetailsBlur(
                                                  hide:
                                                      shouldRestrictPropertyAccess(),
                                                  child: CustomText(
                                                    property?.address ?? '',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.rh(context),
                                      ),
                                      SizedBox(
                                        height: 175,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.asset(
                                                'assets/map.png',
                                                fit: BoxFit.cover,
                                              ),
                                              BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 4,
                                                  sigmaY: 4,
                                                ),
                                                child: Center(
                                                  child: MaterialButton(
                                                    onPressed: () {
                                                      if (shouldRestrictPropertyAccess()) {
                                                        GuestChecker.check(
                                                          onNotGuest: () {
                                                            shouldShowSubscriptionOverlay
                                                                .value = true;
                                                            return;
                                                          },
                                                        );
                                                        return;
                                                      }
                                                      Navigator.push(
                                                        context,
                                                        BlurredRouter(
                                                          builder: (context) {
                                                            return Scaffold(
                                                              extendBodyBehindAppBar:
                                                                  true,
                                                              appBar: AppBar(
                                                                elevation: 0,
                                                                iconTheme:
                                                                    IconThemeData(
                                                                  color: context
                                                                      .color
                                                                      .tertiaryColor,
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                              ),
                                                              body:
                                                                  GoogleMapScreen(
                                                                latitude: double
                                                                    .parse(
                                                                  property?.latitude ??
                                                                      '0',
                                                                ),
                                                                longitude:
                                                                    double
                                                                        .parse(
                                                                  property?.longitude ??
                                                                      '0',
                                                                ),
                                                                kInitialPlace:
                                                                    _kInitialPlace,
                                                                controller:
                                                                    _controller,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        5,
                                                      ),
                                                    ),
                                                    color: context
                                                        .color.tertiaryColor,
                                                    elevation: 0,
                                                    child:
                                                        shouldRestrictPropertyAccess()
                                                            ? Icon(
                                                                Icons
                                                                    .lock_open_outlined,
                                                                color: context
                                                                    .color
                                                                    .secondaryColor
                                                                    .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                              )
                                                            : CustomText(
                                                                'viewMap'
                                                                    .translate(
                                                                  context,
                                                                ),
                                                                color: context
                                                                    .color
                                                                    .buttonColor,
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 18,
                                      ),
                                      if (!HiveUtils.isGuest()) ...[
                                        if (int.parse(
                                              HiveUtils.getUserId() ?? '0',
                                            ) !=
                                            property?.addedBy)
                                          Row(
                                            children: [
                                              // sendEnquiryButtonWithState(),
                                              setInterest(),
                                            ],
                                          ),
                                      ],
                                      const SizedBox(
                                        height: 18,
                                      ),
                                      if (!reportedProperties.contains(
                                            widget.property!.id,
                                          ) &&
                                          widget.property!.addedBy.toString() !=
                                              HiveUtils.getUserId() &&
                                          !isReported)
                                        ReportPropertyButton(
                                          propertyId: property!.id!,
                                          onSuccess: () {
                                            setState(
                                              () {},
                                            );
                                          },
                                        ),
                                      const SizedBox(height: 18),
                                    ],
                                  ),
                                //here
                                SizedBox(
                                  height: 20.rh(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMortgageCalculatorContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            context.color.tertiaryColor.withValues(alpha: 0.1),
            context.color.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: context.color.inverseSurface.withValues(alpha: 0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.color.tertiaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            width: 50,
            child: UiUtils.getSvg(
              AppIcons.calculator,
              color: Colors.white,
              width: 40,
              height: 40,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'calculateMortgage'.translate(context),
                  color: context.color.tertiaryColor,
                  fontSize: context.font.larger,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomText(
                  'tryMortgageCalculator'.translate(context),
                  color: context.color.inverseSurface.withValues(alpha: 0.6),
                  fontSize: context.font.small,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          UiUtils.buildButton(
            context,
            padding: const EdgeInsetsDirectional.only(end: 10, start: 10),
            outerPadding: const EdgeInsetsDirectional.only(start: 10, end: 10),
            height: 30,
            width: MediaQuery.of(context).size.width * 0.1,
            showElevation: false,
            buttonColor: Colors.transparent,
            border: BorderSide(
              color: context.color.tertiaryColor,
            ),
            onPressed: () async {
              await showModalBottomSheet(
                sheetAnimationStyle: AnimationStyle(
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 200),
                ),
                showDragHandle: true,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                context: context,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: MortgageCalculator(property: widget.property!),
                ),
              );
            },
            buttonTitle: 'tryNow'.translate(context),
            textColor: context.color.tertiaryColor,
            fontSize: 14,
            radius: 5,
          ),
        ],
      ),
    );
  }

  Widget advertisementLabel() {
    // if (property?.promoted == false || property?.promoted == null) {
    //   return const SizedBox.shrink();
    // }

    return PositionedDirectional(
      start: 20,
      top: 20,
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            if (property?.promoted == true && property?.promoted != null) ...[
              Container(
                width: 83,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomText(
                  UiUtils.translate(context, 'featured'),
                  fontSize: context.font.small,
                  color: context.color.buttonColor,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
            ],
            if (property != null &&
                property?.allPropData['is_premium'] == true) ...[
              Container(
                height: 32,
                width: 32,
                // margin: EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: SvgPicture.asset(AppIcons.promoted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget bottomNavBar() {
    /// IF property is added by current user then it will show promote button
    if (!HiveUtils.isGuest()) {
      if (int.parse(HiveUtils.getUserId() ?? '0') == property?.addedBy) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 65.rh(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:
                  BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
                builder: (context, state) {
                  PropertyModel? model;

                  if (state is FetchMyPropertiesSuccess) {
                    model = state.myProperty
                        .where((element) => element.id == property?.id)
                        .first;
                  }

                  model ??= widget.property;

                  final isFeatureAvailable = model?.isFeatureAvailable;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!HiveUtils.isGuest() &&
                          Constant.isDemoModeOn != true) ...[
                        if (isFeatureAvailable ?? false) ...[
                          BlocBuilder<GetSubsctiptionPackageLimitsCubit,
                              GetSubscriptionPackageLimitsState>(
                            builder: (context, state) {
                              bool isLoading = context
                                      .read<GetSubsctiptionPackageLimitsCubit>()
                                      .state
                                  is GetSubscriptionPackageLimitsInProgress;
                              return Expanded(
                                child: UiUtils.buildButton(
                                  context,
                                  disabled: property?.status.toString() == '0',
                                  // padding: const EdgeInsets.symmetric(horizontal: 1),
                                  outerPadding: const EdgeInsets.all(
                                    1,
                                  ),
                                  onPressed: () async {
                                    await context
                                        .read<
                                            GetSubsctiptionPackageLimitsCubit>()
                                        .getLimits(
                                          type: 'advertisement',
                                        );
                                    if (state
                                        is GetSubsctiptionPackageLimitsFailure) {
                                      await UiUtils.showBlurredDialoge(
                                        context,
                                        dialoge: BlurredDialogBox(
                                          title: state.errorMessage
                                              .firstUpperCase(),
                                          isAcceptContainesPush: true,
                                          onAccept: () async {
                                            await Navigator.popAndPushNamed(
                                              context,
                                              Routes
                                                  .subscriptionPackageListRoute,
                                              arguments: {
                                                'from': 'propertyDetails',
                                              },
                                            );
                                          },
                                          content: CustomText(
                                            'yourPackageLimitOver'
                                                .translate(context),
                                          ),
                                        ),
                                      );
                                    } else if (state
                                        is GetSubscriptionPackageLimitsSuccess) {
                                      if (state.error) {
                                        await UiUtils.showBlurredDialoge(
                                          context,
                                          dialoge: BlurredDialogBox(
                                            title:
                                                state.message.firstUpperCase(),
                                            isAcceptContainesPush: true,
                                            onAccept: () async {
                                              await Navigator.popAndPushNamed(
                                                context,
                                                Routes
                                                    .subscriptionPackageListRoute,
                                                arguments: {
                                                  'from': 'propertyDetails',
                                                },
                                              );
                                            },
                                            content: CustomText(
                                              'yourPackageLimitOver'
                                                  .translate(context),
                                            ),
                                          ),
                                        );
                                      } else {
                                        try {
                                          await Navigator.pushNamed(
                                            context,
                                            Routes.createAdvertismentPopupRoute,
                                            arguments: {
                                              'propertyData': property,
                                            },
                                          ).then(
                                            (value) {
                                              setState(() {});
                                            },
                                          );
                                        } catch (e) {
                                          await HelperUtils.showSnackBarMessage(
                                            context,
                                            e.toString(),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  prefixWidget: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: isLoading
                                        ? Center(
                                            child: UiUtils.progress(
                                              showWhite: true,
                                              height: 14,
                                            ),
                                          )
                                        : SvgPicture.asset(
                                            AppIcons.promoted,
                                            width: 14,
                                            height: 14,
                                          ),
                                  ),

                                  fontSize: context.font.normal,
                                  width: context.screenWidth / 3,
                                  buttonTitle: isLoading
                                      ? ''
                                      : UiUtils.translate(context, 'feature'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ],
                      Expanded(
                        child: UiUtils.buildButton(
                          context,
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          outerPadding: const EdgeInsets.all(1),
                          onPressed: () async {
                            try {
                              if (AppSettings.isVerificationRequired == true &&
                                  isProfileCompleted != true) {
                                await UiUtils.showBlurredDialoge(
                                  context,
                                  dialoge: BlurredDialogBox(
                                    title: 'completeProfile'.translate(context),
                                    isAcceptContainesPush: true,
                                    onAccept: () async {
                                      await Navigator.popAndPushNamed(
                                        context,
                                        Routes.completeProfile,
                                        arguments: {
                                          'from': 'home',
                                          'navigateToHome': true
                                        },
                                      );
                                    },
                                    content: CustomText(
                                      'completeProfileFirst'.translate(context),
                                    ),
                                  ),
                                );
                                return;
                              }
                              unawaited(Widgets.showLoader(context));
                              final systemRepository = SystemRepository();
                              final settings =
                                  await systemRepository.fetchSystemSettings(
                                isAnonymouse: false,
                              );
                              if (settings['data']['is_premium'] == true) {
                                final category = await context
                                    .read<FetchCategoryCubit>()
                                    .get(
                                      property!.category!.id!,
                                    );
                                final parameterIds = category.parameterTypes;
                                final mappedParameters =
                                    parameterIds?.map((dynamic id) {
                                  // Find index of parameter in property parameters list
                                  final index =
                                      property?.parameters?.indexWhere(
                                            (element) => element.id == id['id'],
                                          ) ??
                                          -1;

                                  // If parameter found, return it; otherwise, return the original value
                                  return index != -1
                                      ? property!.parameters![index]
                                      : id;
                                }).toList();
                                Constant.addProperty.addAll({
                                  'category': Category(
                                    category: property?.category!.category,
                                    id: property?.category?.id,
                                    image: property?.category?.image,
                                    parameterTypes: mappedParameters,
                                  ),
                                });
                                Widgets.hideLoder(context);
                                await Navigator.pushNamed(
                                  context,
                                  Routes.addPropertyDetailsScreen,
                                  arguments: {
                                    'properties': property?.toMap(),
                                    'details': {
                                      'id': property?.id,
                                      'catId': property?.category?.id,
                                      'propType': property?.properyType,
                                      'name': property?.title,
                                      'desc': property?.description,
                                      'city': property?.city,
                                      'state': property?.state,
                                      'country': property?.country,
                                      'latitude': property?.latitude,
                                      'longitude': property?.longitude,
                                      'address': property?.address,
                                      'client': property?.clientAddress,
                                      'price': property?.price,
                                      'parms': property?.parameters,
                                      'allPropData': property?.allPropData,
                                      'images': property?.gallery
                                          ?.map((e) => e.imageUrl)
                                          .toList(),
                                      'gallary_with_id': property?.gallery,
                                      'rentduration': property?.rentduration,
                                      'assign_facilities':
                                          property?.assignedOutdoorFacility,
                                      'titleImage': property?.titleImage,
                                      'slug_id': property?.slugId,
                                      'three_d_image': property?.threeDImage,
                                    },
                                  },
                                );
                              } else {
                                Widgets.hideLoder(context);
                                await UiUtils.showBlurredDialoge(
                                  context,
                                  dialoge: BlurredDialogBox(
                                    title: 'Subscription needed',
                                    isAcceptContainesPush: true,
                                    onAccept: () async {
                                      await Navigator.popAndPushNamed(
                                        context,
                                        Routes.subscriptionPackageListRoute,
                                        arguments: {'from': 'propertyDetails'},
                                      );
                                    },
                                    content: CustomText(
                                      'subscribeToUseThisFeature'
                                          .translate(context),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              Widgets.hideLoder(context);
                              await HelperUtils.showSnackBarMessage(
                                context,
                                'somethingWentWrng'.translate(context),
                              );
                            } finally {
                              Widgets.hideLoder(context);
                            }
                          },
                          fontSize: context.font.normal,
                          width: context.screenWidth / 3,
                          prefixWidget: Padding(
                            padding: const EdgeInsets.only(right: 6, left: 6),
                            child: SvgPicture.asset(AppIcons.edit),
                          ),
                          buttonTitle: UiUtils.translate(context, 'edit'),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: UiUtils.buildButton(
                          context,
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          outerPadding: const EdgeInsets.all(1),
                          prefixWidget: Padding(
                            padding: const EdgeInsets.only(right: 6, left: 6),
                            child: SvgPicture.asset(
                              AppIcons.delete,
                              colorFilter: ColorFilter.mode(
                                context.color.buttonColor,
                                BlendMode.srcIn,
                              ),
                              width: 14,
                              height: 14,
                            ),
                          ),
                          onPressed: () async {
                            // //THIS IS FOR DEMO MODE
                            final isPropertyActive =
                                property?.status.toString() == '1';

                            final isDemoNumber = HiveUtils.getUserDetails()
                                    .mobile ==
                                '${Constant.demoCountryCode}${Constant.demoMobileNumber}';

                            if (Constant.isDemoModeOn &&
                                isPropertyActive &&
                                isDemoNumber) {
                              await HelperUtils.showSnackBarMessage(
                                context,
                                'Active property cannot be deleted in demo app.',
                              );

                              return;
                            }

                            final delete = await UiUtils.showBlurredDialoge(
                              context,
                              dialoge: BlurredDialogBox(
                                title: UiUtils.translate(
                                  context,
                                  'deleteBtnLbl',
                                ),
                                content: CustomText(
                                  UiUtils.translate(
                                    context,
                                    'deletepropertywarning',
                                  ),
                                ),
                              ),
                            );
                            if (delete == true) {
                              Future.delayed(
                                Duration.zero,
                                () {
                                  context.read<DeletePropertyCubit>().delete(
                                        property!.id!,
                                      );
                                },
                              );
                            }
                          },
                          fontSize: context.font.normal,
                          width: context.screenWidth / 3.2,
                          buttonTitle:
                              UiUtils.translate(context, 'deleteBtnLbl'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 65.rh(context),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(child: callButton()),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: messageButton()),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: chatButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setInterest() {
    // check if list has this id or not
    final interestedProperty =
        Constant.interestedPropertyIds.contains(widget.property?.id);

    /// default icon
    dynamic icon = AppIcons.interested;

    /// first priority is Constant list .
    if (interestedProperty == true || widget.property?.isInterested == 1) {
      /// If list has id or our property is interested so we are gonna show icon of No Interest
      icon = Icons.not_interested_outlined;
    }

    return BlocConsumer<ChangeInterestInPropertyCubit,
        ChangeInterestInPropertyState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ChangeInterestInPropertySuccess) {
          if (state.interest == PropertyInterest.interested) {
            //If interested show no interested icon
            icon = Icons.not_interested_outlined;
          } else {
            icon = AppIcons.interested;
          }
        }

        return Expanded(
          child: UiUtils.buildButton(
            context,
            height: 48,
            outerPadding: const EdgeInsets.all(1),
            isInProgress: state is ChangeInterestInPropertyInProgress,
            onPressed: () {
              PropertyInterest interest;

              final contains =
                  Constant.interestedPropertyIds.contains(widget.property!.id);

              if (contains == true || widget.property!.isInterested == 1) {
                //change to not interested
                interest = PropertyInterest.notInterested;
              } else {
                //change to not unterested
                interest = PropertyInterest.interested;
              }
              context.read<ChangeInterestInPropertyCubit>().changeInterest(
                    propertyId: widget.property!.id!.toString(),
                    interest: interest,
                  );
            },
            buttonTitle: (icon == Icons.not_interested_outlined
                ? UiUtils.translate(context, 'interested')
                : UiUtils.translate(context, 'interest')),
            fontSize: context.font.large,
            prefixWidget: Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: (icon is String)
                  ? SvgPicture.asset(
                      icon,
                      width: 22,
                      height: 22,
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).colorScheme.buttonColor,
                      size: 22,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget callButton() {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.large,
      outerPadding: const EdgeInsets.all(1),
      buttonTitle: UiUtils.translate(context, 'call'),
      width: 35,
      onPressed: _onTapCall,
      prefixWidget: Container(
        margin: const EdgeInsets.only(right: 3, left: 3),
        child: SizedBox(
          width: 16,
          height: 16,
          child: UiUtils.getSvg(AppIcons.call, color: Colors.white),
        ),
      ),
    );
  }

  Widget messageButton() {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.large,
      outerPadding: const EdgeInsets.all(1),
      buttonTitle: UiUtils.translate(context, 'sms'),
      width: 35,
      onPressed: _onTapMessage,
      prefixWidget: SizedBox(
        width: 20,
        height: 20,
        child: Container(
          margin: const EdgeInsets.only(right: 3, left: 3),
          child: UiUtils.getSvg(
            AppIcons.message,
            color: context.color.buttonColor,
          ),
        ),
      ),
    );
  }

  Widget chatButton() {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.large,
      outerPadding: const EdgeInsets.all(1),
      buttonTitle: UiUtils.translate(context, 'chat'),
      width: 35,
      onPressed: _onTapChat,
      prefixWidget: SizedBox(
        width: 22,
        height: 22,
        child: Container(
          margin: const EdgeInsets.only(right: 3, left: 3),
          child:
              UiUtils.getSvg(AppIcons.chat, color: context.color.buttonColor),
        ),
      ),
    );
  }

  Future<void> _onTapCall() async {
    if (isPremiumProperty && !isPremiumUser) {
      GuestChecker.check(
        onNotGuest: () async {
          await UiUtils.showBlurredDialoge(
            context,
            dialoge: BlurredDialogBox(
              title: 'Subscription needed',
              isAcceptContainesPush: true,
              onAccept: () async {
                await Navigator.popAndPushNamed(
                  context,
                  Routes.subscriptionPackageListRoute,
                  arguments: {'from': 'propertyDetails'},
                );
              },
              content: CustomText(
                'subscribeToUseThisFeature'.translate(context),
              ),
            ),
          );
          return;
        },
      );
      return;
    }

    final contactNumber = widget.property?.customerNumber;

    final url = Uri.parse('tel: +$contactNumber'); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      log('Could not launch $url');
    }
  }

  Future<void> _onTapMessage() async {
    if (isPremiumProperty && !isPremiumUser) {
      GuestChecker.check(
        onNotGuest: () async {
          await UiUtils.showBlurredDialoge(
            context,
            dialoge: BlurredDialogBox(
              title: 'Subscription needed',
              isAcceptContainesPush: true,
              onAccept: () async {
                await Navigator.popAndPushNamed(
                  context,
                  Routes.subscriptionPackageListRoute,
                  arguments: {'from': 'propertyDetails'},
                );
              },
              content: CustomText(
                'subscribeToUseThisFeature'.translate(context),
              ),
            ),
          );
          return;
        },
      );
      return;
    }

    final contactNumber = widget.property?.customerNumber;

    final url = Uri.parse('sms: +$contactNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      log('Could not launch $url');
    }
  }

  void _onTapChat() {
    CheckInternet.check(
      onInternet: () {
        GuestChecker.check(
          onNotGuest: () async {
            if (isPremiumProperty && !isPremiumUser) {
              await UiUtils.showBlurredDialoge(
                context,
                dialoge: BlurredDialogBox(
                  title: 'Subscription needed',
                  isAcceptContainesPush: true,
                  onAccept: () async {
                    await Navigator.popAndPushNamed(
                      context,
                      Routes.subscriptionPackageListRoute,
                      arguments: {'from': 'propertyDetails'},
                    );
                  },
                  content: CustomText(
                    'subscribeToUseThisFeature'.translate(context),
                  ),
                ),
              );
              return;
            }
            final chatState = await context.read<GetChatListCubit>().state;
            if (chatState is GetChatListSuccess) {
              // if (chatState.chatedUserList.isEmpty) {
              //   return;
              // }
              await Navigator.push(
                context,
                BlurredRouter(
                  builder: (context) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => SendMessageCubit(),
                        ),
                        BlocProvider(
                          create: (context) => LoadChatMessagesCubit(),
                        ),
                        BlocProvider(
                          create: (context) => DeleteMessageCubit(),
                        ),
                      ],
                      child: ChatScreen(
                        profilePicture: property?.customerProfile ?? '',
                        userName: property?.customerName ?? '',
                        propertyImage: property?.titleImage ?? '',
                        proeprtyTitle: property?.title ?? '',
                        userId: (property?.addedBy).toString(),
                        from: 'property',
                        propertyId: (property?.id).toString(),
                        isBlockedByMe: property?.isBlockedByMe ?? true,
                        isBlockedByUser: property?.isBlockedByUser ?? true,
                      ),
                    );
                  },
                ),
              );
            }
            if (chatState is GetChatListFailed) {
              await HelperUtils.showSnackBarMessage(
                context,
                chatState.error.toString(),
              );
            }
          },
        );
      },
      onNoInternet: () {
        HelperUtils.showSnackBarMessage(
          context,
          'noInternet'.translate(context),
        );
      },
    );
  }
}

class InterestedUserListWidget extends StatefulWidget {
  const InterestedUserListWidget({
    required this.totalCount,
    required this.interestedUserCubitReference,
    super.key,
  });

  final String totalCount;
  final GetInterestedUserCubit interestedUserCubitReference;

  @override
  State<InterestedUserListWidget> createState() =>
      _InterestedUserListWidgetState();
}

class _InterestedUserListWidgetState extends State<InterestedUserListWidget> {
  final ScrollController _bottomSheetScrollController = ScrollController();

  @override
  void initState() {
    _bottomSheetScrollController.addListener(() {
      if (_bottomSheetScrollController.isEndReached()) {
        if (widget.interestedUserCubitReference.hasMoreData()) {
          widget.interestedUserCubitReference.fetchMore();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: _bottomSheetScrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: CustomText(
                'interestedUsers'.translate(context),
                fontWeight: FontWeight.bold,
                fontSize: context.font.larger,
              ),
            ),
            BlocBuilder<GetInterestedUserCubit, GetInterestedUserState>(
              bloc: widget.interestedUserCubitReference,
              builder: (context, state) {
                if (state is GetInterestedUserInProgress) {
                  return Center(child: UiUtils.progress());
                }

                if (state is GetInterestedUserSuccess) {
                  if (state.list.isEmpty) {
                    return Center(
                      child: CustomText('No data found'),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final interestedUser = state.list[index];

                      return InterestedUserCard(
                        interestedUser: interestedUser,
                      );
                    },
                    itemCount: state.list.length,
                    shrinkWrap: true,
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InterestedUserCard extends StatelessWidget {
  const InterestedUserCard({
    required this.interestedUser,
    super.key,
  });

  final InterestedUserModel interestedUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // CircleAvatar(radius: 25, backgroundImage: SvgPro),
          Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.red,
            ),
            child: UiUtils.getImage(interestedUser.image ?? ''),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 3,
            child: CustomText(interestedUser.name ?? ''),
          ),
          const SizedBox(
            width: 10,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse('mailto:${interestedUser.email}'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: Icon(
                  Icons.email,
                  color: context.color.tertiaryColor,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse('tel:${interestedUser.mobile}'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                color: context.color.tertiaryColor,
                icon: const Icon(Icons.call),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoogleMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const GoogleMapScreen({
    required this.latitude,
    required this.longitude,
    required CameraPosition kInitialPlace,
    required Completer<GoogleMapController> controller,
    super.key,
  })  : _kInitialPlace = kInitialPlace,
        _controller = controller;

  final CameraPosition _kInitialPlace;
  final Completer<GoogleMapController> _controller;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool isGoogleMapVisible = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      isGoogleMapVisible = true;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        isGoogleMapVisible = false;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
        Future.delayed(
          Duration.zero,
          () {
            Navigator.pop(context);
          },
        );
        return Future.value(false);
      },
      child: Builder(
        builder: (context) {
          if (!isGoogleMapVisible) {
            return Center(child: UiUtils.progress());
          }
          return GoogleMap(
            myLocationButtonEnabled: false,
            gestureRecognizers: const <f.Factory<OneSequenceGestureRecognizer>>{
              f.Factory<OneSequenceGestureRecognizer>(
                EagerGestureRecognizer.new,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('1'),
                position: LatLng(widget.latitude, widget.longitude),
              ),
            },
            initialCameraPosition: widget._kInitialPlace,
            onMapCreated: (GoogleMapController controller) {
              if (!widget._controller.isCompleted) {
                widget._controller.complete(controller);
              }
            },
          );
        },
      ),
    );
  }
}

class AgentProfileWidget extends StatelessWidget {
  final bool hideDetails;

  const AgentProfileWidget({
    required this.hideDetails,
    required this.widget,
    super.key,
  });

  final PropertyDetails widget;

  @override
  Widget build(BuildContext context) {
    return HideDetailsBlur(
      hide: hideDetails,
      sigmaX: 4,
      sigmaY: 4,
      child: GestureDetector(
        onTap: () async {
          GuestChecker.check(
            onNotGuest: () async {
              await context
                  .read<FetchAgentsPropertyCubit>()
                  .fetchAgentsProperty(
                      agentId: widget.property!.addedBy!,
                      forceRefresh: true,
                      isAdmin: widget.property!.addedBy!.toString() == '0');
              final state = context.read<FetchAgentsPropertyCubit>().state;
              final bool isPremium = context
                      .read<FetchSystemSettingsCubit>()
                      .getRawSettings()['is_premium'] ??
                  false;
              if (isPremium && state is FetchAgentsPropertySuccess) {
                Navigator.pushNamed(
                  context,
                  Routes.agentDetailsScreen,
                  arguments: {
                    'agent': state.agentsProperty.customerData,
                    'isAdmin': widget.property!.addedBy.toString() == '0',
                  },
                );
              } else {
                if ((widget.property!.addedBy.toString() ==
                        HiveUtils.getUserId()) &&
                    state is FetchAgentsPropertySuccess) {
                  Navigator.pushNamed(
                    context,
                    Routes.agentDetailsScreen,
                    arguments: {
                      'agent': state.agentsProperty.customerData,
                      'isAdmin': widget.property!.addedBy.toString() == '0',
                    },
                  );
                } else {
                  UiUtils.showBlurredDialoge(
                    context,
                    dialoge: BlurredDialogBox(
                      title: 'Subscription needed',
                      isAcceptContainesPush: true,
                      onAccept: () async {
                        await Navigator.popAndPushNamed(
                          context,
                          Routes.subscriptionPackageListRoute,
                          arguments: {'from': 'home'},
                        );
                      },
                      content: CustomText(
                        'subscribeToUseThisFeature'.translate(context),
                      ),
                    ),
                  );
                }
              }
            },
          );
        },
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: UiUtils.getImage(
                widget.property?.customerProfile ?? '',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: CustomText(
                          widget.property?.customerName ?? '',
                          fontWeight: FontWeight.bold,
                          fontSize: context.font.large,
                        ),
                      ),
                      if (widget.property?.isVerified ?? false)
                        FittedBox(
                          fit: BoxFit.none,
                          child: UiUtils.getSvg(
                            AppIcons.agentBadge,
                            height: 24,
                            width: 24,
                            color: context.color.tertiaryColor,
                          ),
                        ),
                    ],
                  ),
                  CustomText(widget.property?.customerEmail ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutdoorFacilityListWidget extends StatelessWidget {
  final List<AssignedOutdoorFacility> outdoorFacilityList;

  const OutdoorFacilityListWidget({
    required this.outdoorFacilityList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: outdoorFacilityList.length,
      itemBuilder: (context, index) {
        final facility = outdoorFacilityList[index];
        final distanceOption = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.distanceOption);
        return Column(
          //crossAxisAlignment: getCrossAxisAlignment(columnIndex),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: UiUtils.imageType(
                        facility.image ?? '',
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null,
                        // fit: BoxFit.cover,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomText(
                  facility.name ?? '',
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  fontSize: context.font.small,
                  color: context.color.textColorDark,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: CustomText(
                      '${facility.distance ?? ''}  ',
                      fontSize: context.font.small,
                      color: context.color.inverseSurface,
                      maxLines: 1,
                    )),
                    Flexible(
                      child: CustomText(
                        '$distanceOption'.firstUpperCase(),
                        fontSize: context.font.small,
                        color: context.color.inverseSurface,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class HideDetailsBlur extends StatelessWidget {
  final Widget child;
  final bool hide;
  final double? sigmaX;
  final double? sigmaY;

  const HideDetailsBlur({
    required this.child,
    required this.hide,
    super.key,
    this.sigmaX,
    this.sigmaY,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        // fit: StackFit.expand,
        children: [
          child,
          if (hide)
            BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaY: sigmaY ?? 3, sigmaX: sigmaX ?? 4),
              child: Container(),
            ),
        ],
      ),
    );
  }
}

class DownloadableDocuments extends StatefulWidget {
  const DownloadableDocuments({required this.url, super.key});
  final String url;

  @override
  State<DownloadableDocuments> createState() => _DownloadableDocumentsState();
}

class _DownloadableDocumentsState extends State<DownloadableDocuments> {
  bool downloaded = false;
  Dio dio = Dio();
  ValueNotifier<double> percentage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  Future<String?>? path() async {
    final downloadPath = await HelperUtils.getDownloadPath();
    return downloadPath;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.url.split('/').last;
    return ListTile(
      dense: true,
      title: CustomText(
        name,
        fontSize: context.font.large,
        color: context.color.textColorDark.withValues(alpha: 0.9),
      ),
      trailing: ValueListenableBuilder(
        valueListenable: percentage,
        builder: (context, value, child) {
          if (value != 0.0 && value != 1.0) {
            return SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                value: value,
                color: context.color.tertiaryColor,
              ),
            );
          }
          if (downloaded) {
            return IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              splashRadius: 1,
              icon: const Icon(Icons.file_open),
              onPressed: () async {
                final downloadPath = await path();

                await OpenFilex.open('$downloadPath/$name');
              },
            );
          }
          return IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            splashRadius: 1,
            icon: const Icon(Icons.download),
            onPressed: () async {
              final downloadPath = await path();
              final storagePermission =
                  await HelperUtils.hasStoragePermissionGiven();
              if (storagePermission) {
                await dio.download(
                  widget.url,
                  '$downloadPath/$name',
                  onReceiveProgress: (count, total) async {
                    percentage.value = count / total;
                    if (percentage.value == 1.0) {
                      downloaded = true;
                      setState(() {});
                      await OpenFilex.open('$downloadPath/$name');
                    }
                  },
                );
              } else {
                await HelperUtils.showSnackBarMessage(
                  context,
                  'Storage Permission denied!',
                );
              }
            },
          );
        },
      ),
    );
  }
}
