import 'dart:async';

import 'package:ebroker/data/cubits/Utility/google_place_autocomplate_cubit.dart';
import 'package:ebroker/data/repositories/location_repository.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///This will show when you will need to fill your location,
///
class ChooseLocatonBottomSheet extends StatefulWidget {
  const ChooseLocatonBottomSheet({super.key});

  @override
  State<ChooseLocatonBottomSheet> createState() =>
      ChooseLocatonBottomSheetState();
}

class ChooseLocatonBottomSheetState extends State<ChooseLocatonBottomSheet> {
  final TextEditingController _searchLocation = TextEditingController();
  Timer? delayTimer;
  dynamic cubitReferance;
  int previouseLength = 0;

  @override
  void initState() {
    super.initState();

    ///This will create listener which will listen to out text change in text field
    _searchLocation.addListener(() {
      ///If there is no text in text field so we don't need to call an API.
      ///Therefor we are cancel this timer
      ///
      if (_searchLocation.text.isEmpty) {
        delayTimer?.cancel();
      }

      if (delayTimer?.isActive ?? false) delayTimer?.cancel();

      ///Create new timer after cancel previous one
      delayTimer = Timer(const Duration(milliseconds: 500), () {
        ///Search only if text field is not empty otherwise it will call when we tap on search field,
        if (_searchLocation.text.isNotEmpty) {
          ///Only call when our text doesn't match with our previous text,
          ///When we search `Hello` then it will call API and search city named hello, when we write again hello so it will call again, So why do we need to call it when we have it's data already available?
          if (_searchLocation.text.length != previouseLength) {
            context.read<GooglePlaceAutocompleteCubit>().getLocationFromText(
                  text: _searchLocation.text,
                );

            ///set previous text length
            previouseLength = _searchLocation.text.length;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _searchLocation.dispose();
    delayTimer?.cancel();
    cubitReferance.clearCubit();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    cubitReferance = context.read<GooglePlaceAutocompleteCubit>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomText(
                UiUtils.translate(
                  context,
                  'selectLocation',
                ),
                fontSize: context.font.larger),
            const SizedBox(height: 20),
            TextField(
              controller: _searchLocation,
              onChanged: (e) {},
              cursorColor: context.color.tertiaryColor,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.color.tertiaryColor),
                ),
                fillColor: context.color.tertiaryColor.withValues(alpha: 0.01),
                filled: true,
                prefixIcon: Icon(
                  Icons.search,
                  color: context.color.tertiaryColor,
                ),
                hintText: UiUtils.translate(context, 'enterLocation'),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
              ),
            ),
            BlocBuilder<GooglePlaceAutocompleteCubit,
                GooglePlaceAutocompleteState>(
              builder:
                  (context, GooglePlaceAutocompleteState googlePlaceState) {
                if (googlePlaceState is GooglePlaceAutocompleteSuccess) {
                  if (googlePlaceState.autocompleteResult.isNotEmpty) {
                    return ListView.builder(
                      itemCount: googlePlaceState.autocompleteResult.length,
                      shrinkWrap: true,
                      itemBuilder: (context, int i) {
                        return ListTile(
                          onTap: () async {
                            ///This will fetch place details from given PlaceId
                            final cordinates = await GooglePlaceRepository()
                                .getPlaceDetailsFromPlaceId(
                              googlePlaceState.autocompleteResult[i].placeId,
                            );

                            var placeModel =
                                googlePlaceState.autocompleteResult[i];

                            ///Now we have place Model
                            placeModel = placeModel.copyWith(
                              latitude: cordinates['lat'].toString(),
                              longitude: cordinates['lng'].toString(),
                            );

                            Future.delayed(
                              Duration.zero,
                              () {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  Navigator.pop(
                                    context,
                                    placeModel,
                                  );
                                });
                              },
                            );
                          },
                          leading: const Icon(Icons.location_city),
                          title: CustomText(
                            googlePlaceState.autocompleteResult[i].description,
                          ),
                        );
                      },
                    );
                  }
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8),
                    child: Center(
                      child:
                          CustomText(UiUtils.translate(context, 'nodatafound')),
                    ),
                  );
                }

                ///Show progress when loading
                if (googlePlaceState is GooglePlaceAutocompleteInProgress) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8),
                    child: Center(
                      child: UiUtils.progress(
                        normalProgressColor: context.color.tertiaryColor,
                      ),
                    ),
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
