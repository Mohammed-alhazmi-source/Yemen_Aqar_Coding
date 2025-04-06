import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class LanguagesListScreen extends StatelessWidget {
  const LanguagesListScreen({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => const LanguagesListScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context
            .watch<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.languageType) ==
        null) {
      return Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: UiUtils.translate(context, 'chooseLanguage'),
        ),
        body: Center(child: UiUtils.progress()),
      );
    }

    final setting = context
        .watch<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.languageType) as List;

    final language = context.watch<LanguageCubit>().state;
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'chooseLanguage'),
      ),
      body: BlocListener<FetchLanguageCubit, FetchLanguageState>(
        listener: (context, state) {
          if (state is FetchLanguageInProgress) {
            Widgets.showLoader(context);
          }
          if (state is FetchLanguageFailure) {
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(context, state.errorMessage);
          }
          if (state is FetchLanguageSuccess) {
            Widgets.hideLoder(context);
            final map = state.toMap();
            final data = map['file_name'];
            map['data'] = data;

            map.remove('file_name');
            HiveUtils.storeLanguage(map);
            context
                .read<LanguageCubit>()
                .emitLanguageLoader(code: state.code, isRtl: state.isRTL);
          }
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: setting.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            final color = (language as LanguageLoader).languageCode ==
                    setting[index]['code']
                ? context.color.tertiaryColor
                : context.color.textLightColor.withValues(alpha: 0.03);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    onTap: () {
                      context.read<FetchLanguageCubit>().getLanguage(
                            setting[index]['code'],
                          );
                    },
                    title: CustomText(
                      setting[index]['name'],
                      fontWeight: FontWeight.bold,
                      color: language.languageCode == setting[index]['code']
                          ? context.color.buttonColor
                          : context.color.textColorDark,
                    )),
              ),
            );
          },
        ),
      ),
    );
  }
}
