import 'package:ebroker/data/cubits/Utility/like_properties.dart';
import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/guestChecker.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//This like button is used in app for favorite feature, it is used in all propery so it is very important
class LikeButtonWidget extends StatefulWidget {
  const LikeButtonWidget({
    required this.propertyId,
    required this.isFavourite,
    super.key,
    this.onStateChange,
    this.onLikeChanged,
    this.color,
    this.enableLike = true,
  });
  final int propertyId;
  final int isFavourite;
  final Function(FavoriteType type)? onLikeChanged;
  final Function(AddToFavoriteCubitState state)? onStateChange;
  final Color? color;
  final bool enableLike;

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {
  @override
  void initState() {
    //checking is property is already favorite , it will come in api
    if (GuestChecker.value != true) {
      if (widget.isFavourite == 1 &&
          context
                  .read<LikedPropertiesCubit>()
                  .state
                  .liked
                  .contains(widget.propertyId) ==
              false) {
        if (!context
            .read<LikedPropertiesCubit>()
            .getRemovedLikes()!
            .contains(widget.propertyId)) {
          context.read<LikedPropertiesCubit>().add(widget.propertyId);
        }
      }
    }

    super.initState();
  }

//this is main like button method
  Widget setFavorite(int propertyId, int isFavourite, BuildContext context) {
    return BlocConsumer<AddToFavoriteCubitCubit, AddToFavoriteCubitState>(
      listener: (BuildContext context, AddToFavoriteCubitState state) {
        widget.onStateChange?.call(state);
        if (state is AddToFavoriteCubitFailure) {}
        if (state is AddToFavoriteCubitSuccess) {
          //callback
          widget.enableLike ? widget.onLikeChanged?.call(state.favorite) : '';

          /// if it is already added then we'll add remove , other wise we'll add it into local list
          context.read<LikedPropertiesCubit>().changeLike(state.id);
        }
      },
      builder: (BuildContext context, AddToFavoriteCubitState addState) {
        return GestureDetector(
          onTap: () {
            GuestChecker.check(
              onNotGuest: () {
                ///checking if added then remove or else add it
                FavoriteType favoriteType;

                final contains = context
                    .read<LikedPropertiesCubit>()
                    .state
                    .liked
                    .contains(propertyId);

                if (contains == true || isFavourite == 1) {
                  favoriteType = FavoriteType.remove;
                } else {
                  favoriteType = FavoriteType.add;
                }
                context.read<AddToFavoriteCubitCubit>().setFavroite(
                      propertyId: propertyId,
                      type: favoriteType,
                    );
              },
            );
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.color ?? context.color.primaryColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(33, 0, 0, 0),
                  offset: Offset(0, 2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: BlocBuilder<LikedPropertiesCubit, LikedPropertiesState>(
              builder: (context, state) {
                return Center(
                  child: (addState is AddToFavoriteCubitInProgress)
                      ? UiUtils.progress(width: 20, height: 20)
                      : state.liked.contains(widget.propertyId)
                          ? UiUtils.getSvg(
                              AppIcons.like_fill,
                              color: context.color.tertiaryColor,
                            )
                          : UiUtils.getSvg(
                              AppIcons.like,
                              color: context.color.tertiaryColor,
                            ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return setFavorite(widget.propertyId, widget.isFavourite, context);
  }
}
