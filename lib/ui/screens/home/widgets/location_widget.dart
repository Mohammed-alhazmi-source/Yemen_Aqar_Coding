import 'package:ebroker/data/cubits/auth/auth_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_nearby_property_cubit.dart';
import 'package:ebroker/data/model/google_place_model.dart';
import 'package:ebroker/ui/screens/widgets/bottom_sheets/choose_location_bottomsheet.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String city = '';
  String state = '';
  String country = '';
  late Box userDetailsBox;
  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    userDetailsBox = Hive.box(HiveKeys.userDetailsBox);
    listener = () {
      if (mounted) {
        setState(() {
          city = HiveUtils.getCityName().toString().trim();
          state = HiveUtils.getStateName().toString().trim();
          country = HiveUtils.getCountryName().toString().trim();
        });
      }
    };
    userDetailsBox
        .listenable(keys: ['city', 'state', 'country']).addListener(listener);
  }

  @override
  void dispose() {
    userDetailsBox.listenable(
      keys: ['city', 'state', 'country'],
    ).removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    city = HiveUtils.getCityName().toString().trim();
    state = HiveUtils.getStateName().toString().trim();
    country = HiveUtils.getCountryName().toString().trim();

    final locationList = <String>[city, state, country]..removeWhere((element) {
        return element.isEmpty;
      });
    final joinedLocation = locationList.join(', ');

    return FittedBox(
      fit: BoxFit.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.rw(context),
          ),
          GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                context: context,
                builder: (context) {
                  return const ChooseLocatonBottomSheet();
                },
              );
              if (result != null) {
                final place = result as GooglePlaceModel;
                await HiveUtils.setLocation(
                  city: place.city,
                  state: place.state,
                  latitude: double.parse(place.latitude),
                  longitude: double.parse(place.longitude),
                  country: place.country,
                  placeId: place.placeId,
                );
                await context.read<AuthCubit>().updateUserData(
                      context,
                      phone: HiveUtils.getUserDetails().mobile,
                      name: HiveUtils.getUserDetails().name,
                      email: HiveUtils.getUserDetails().email,
                      address: HiveUtils.getUserDetails().address,
                      fcmToken: HiveUtils.getUserDetails().fcmId,
                      city: place.city,
                      state: place.state,
                      country: place.country,
                      latitude: double.parse(place.latitude),
                      longitude: double.parse(place.longitude),
                    );
                Future.delayed(
                  Duration.zero,
                  () {
                    context.read<FetchNearbyPropertiesCubit>().fetch(
                          forceRefresh: true,
                        );
                  },
                );
              }
            },
            child: Container(
              width: 40.rw(context),
              height: 40.rh(context),
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: UiUtils.getSvg(
                AppIcons.location,
                fit: BoxFit.none,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 10.rw(context),
          ),
          ValueListenableBuilder(
            valueListenable: userDetailsBox.listenable(),
            builder: (context, value, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    UiUtils.translate(context, 'locationLbl'),
                    fontSize: context.font.small,
                    color: context.color.textColorDark,
                  ),
                  SizedBox(
                    width: 150,
                    child: CustomText(
                      joinedLocation,
                      maxLines: 1,
                      fontWeight: FontWeight.w600,
                      fontSize: context.font.small,
                      color: context.color.textColorDark,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
