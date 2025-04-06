import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key, this.title, this.param});
  final String? title;
  final String? param;

  @override
  ProfileSettingsState createState() => ProfileSettingsState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => ProfileSettings(
        title: arguments?['title'] as String,
        param: arguments?['param'] as String,
      ),
    );
  }
}

class ProfileSettingsState extends State<ProfileSettings> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            widget.param!,
            forceRefresh: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.title,
        showBackButton: true,
      ),
      body: BlocBuilder<ProfileSettingCubit, ProfileSettingState>(
        builder: (context, state) {
          if (state is ProfileSettingFetchProgress) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          } else if (state is ProfileSettingFetchSuccess) {
            return contentWidget(state, context);
          } else if (state is ProfileSettingFetchFailure) {
            if (state.errmsg is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context.read<ProfileSettingCubit>().fetchProfileSetting(
                        context,
                        widget.param!,
                        forceRefresh: true,
                      );
                },
              );
            }

            return Widgets.noDataFound(state.errmsg);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

Widget contentWidget(ProfileSettingFetchSuccess state, BuildContext context) {
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Html(
      data: state.data,
      onAnchorTap: (
        url,
        context,
        attributes,
      ) {
        launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
      },
      style: {
        'table': Style(
          backgroundColor: Colors.grey[50],
        ),
        'p': Style(color: context.color.textColorDark),
        'p strong': Style(
          color: context.color.tertiaryColor,
          fontSize: FontSize.larger,
        ),
        'tr': Style(
            // border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
        'th': Style(
          backgroundColor: Colors.grey,
          border: const Border(bottom: BorderSide()),
        ),
        'td': Style(border: Border.all(color: Colors.grey, width: 0.5)),
        'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
      },
    ),
  );
}
