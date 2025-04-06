import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ChatListScreen();
      },
    );
  }

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    chatScreenController.addListener(() {
      if (chatScreenController.isEndReached()) {
        if (context.read<GetChatListCubit>().hasMoreData()) {
          context.read<GetChatListCubit>().loadMore();
        }
      }
    });
    if (context.read<GetChatListCubit>().state is! GetChatListSuccess) {
      context.read<GetChatListCubit>().fetch();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'message'),
      ),
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context.read<GetChatListCubit>().fetch();
        },
        child: BlocBuilder<GetChatListCubit, GetChatListState>(
          builder: (context, state) {
            if (state is GetChatListFailed) {
              if (state.error is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    context.read<GetChatListCubit>().fetch();
                  },
                );
              } else {
                return ScrollConfiguration(
                  behavior: RemoveGlow(),
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: SomethingWentWrong())),
                );
              }
            }
            if (state is GetChatListInProgress) {
              return buildChatListLoadingShimmer();
            }
            if (state is GetChatListSuccess) {
              if (state.chatedUserList.isEmpty) {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppIcons.no_chat_found),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomText(UiUtils.translate(context, 'noChats'),
                            fontWeight: FontWeight.w600,
                            fontSize: context.font.extraLarge,
                            color: context.color.tertiaryColor),
                        const SizedBox(
                          height: 14,
                        ),
                        CustomText(
                          'startConversation'.translate(context),
                          textAlign: TextAlign.center,
                          fontSize: context.font.large,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                shrinkWrap: false,
                controller: chatScreenController,
                itemCount: state.chatedUserList.length,
                padding: const EdgeInsetsDirectional.all(16),
                itemBuilder: (
                  context,
                  index,
                ) {
                  final chatedUser = state.chatedUserList[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: ChatTile(
                      id: chatedUser.userId.toString(),
                      propertyId: chatedUser.propertyId.toString(),
                      profilePicture: chatedUser.profile ?? '',
                      userName: chatedUser.name ?? '',
                      propertyPicture: chatedUser.titleImage ?? '',
                      propertyName: chatedUser.title ?? '',
                      pendingMessageCount: '5',
                      isBlockedByMe: chatedUser.isBlockedByMe ?? false,
                      isBlockedByUser: chatedUser.isBlockedByUser ?? false,
                    ),
                  );
                },
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget buildChatListLoadingShimmer() {
    return ListView.builder(
      itemCount: 10,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 9),
          child: SizedBox(
            height: 74,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
                    highlightColor:
                        Theme.of(context).colorScheme.shimmerHighlightColor,
                    child: Stack(
                      children: [
                        const SizedBox(
                          width: 58,
                          height: 58,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 42,
                            height: 42,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              border: Border.all(
                                width: 1.5,
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          end: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: context.color.tertiaryColor,
                                // backgroundImage: NetworkImage(profilePicture),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomShimmer(
                        height: 10,
                        borderRadius: 5,
                        width: context.screenWidth * 0.53,
                      ),
                      CustomShimmer(
                        height: 10,
                        borderRadius: 5,
                        width: context.screenWidth * 0.3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => false;
}

class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.profilePicture,
    required this.userName,
    required this.propertyPicture,
    required this.propertyName,
    required this.pendingMessageCount,
    required this.id,
    required this.propertyId,
    required this.isBlockedByMe,
    required this.isBlockedByUser,
    super.key,
  });

  final String profilePicture;
  final String userName;
  final String propertyPicture;
  final String propertyName;
  final String propertyId;
  final String pendingMessageCount;
  final String id;
  final bool isBlockedByMe;
  final bool isBlockedByUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          BlurredRouter(
            builder: (context) {
              currentlyChatingWith = id;
              currentlyChatPropertyId = propertyId;
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => LoadChatMessagesCubit(),
                  ),
                  BlocProvider(
                    create: (context) => DeleteMessageCubit(),
                  ),
                ],
                child: Builder(
                  builder: (context) {
                    return ChatScreen(
                      profilePicture: profilePicture,
                      proeprtyTitle: propertyName,
                      userId: id,
                      propertyImage: propertyPicture,
                      userName: userName,
                      propertyId: propertyId,
                      isBlockedByMe: isBlockedByMe,
                      isBlockedByUser: isBlockedByUser,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      child: AbsorbPointer(
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.color.borderColor,
              width: 1.5,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    const SizedBox(
                      width: 58,
                      height: 58,
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: propertyPicture,
                        fit: BoxFit.cover,
                      ),
                    ),
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.color.secondaryColor,
                            width: 2,
                          ),
                        ),
                        child: profilePicture == ''
                            ? CircleAvatar(
                                radius: 15,
                                backgroundColor: context.color.tertiaryColor,
                                child: UiUtils.getImage(
                                  appSettings.placeholderLogo!,
                                ),
                              )
                            : CircleAvatar(
                                radius: 15,
                                backgroundColor: context.color.tertiaryColor,
                                backgroundImage: NetworkImage(profilePicture),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        userName,
                        fontWeight: FontWeight.bold,
                        color: context.color.textColorDark,
                      ),
                      Expanded(
                        child: CustomText(
                          propertyName,
                          maxLines: 1,
                          color: context.color.textColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
