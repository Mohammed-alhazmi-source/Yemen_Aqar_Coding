// ignore_for_file: file_names

import 'package:app_links/app_links.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:flutter/material.dart';

class DeepLinkManager {
  static final AppLinks _appLinks = AppLinks();

  static Future<void> initDeepLinks(BuildContext context) async {
    final initialLink = await _appLinks.getInitialLink();

    Future.delayed(Duration.zero, () {
      _handleDeepLinks(context, initialLink);
    });

    _appLinks.uriLinkStream.listen((Uri? uri) {
      _handleDeepLinks(context, uri);
    });
  }

  static Future<void> _handleDeepLinks(BuildContext context, Uri? uri) async {
    if (uri == null) {
      return;
    }

    final propertyId = uri.queryParameters['property_id'];
    if (propertyId != null) {
      final dataOutput = await PropertyRepository().fetchPropertyFromPropertyId(
        id: int.parse(propertyId),
        isMyProperty: uri.queryParameters['is_my_property'] == 'true',
      );

      await Navigator.pushNamed(
        Constant.navigatorKey.currentContext!,
        Routes.propertyDetails,
        arguments: {
          'propertyData': dataOutput,
        },
      );
    }
  }

  static String buildAppLink(int propertyId) {
    final uri = Uri(
      scheme: 'http',
      host: AppSettings.deepLinkName,
      queryParameters: {
        'property_id': propertyId.toString(),
      },
    );

    return uri.toString();
  }
}
