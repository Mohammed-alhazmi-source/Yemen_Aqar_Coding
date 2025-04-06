import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:flutter/material.dart';

enum SubscriptionStaus { success, failed }

class SubscriptionStatusScreen extends StatelessWidget {
  const SubscriptionStatusScreen({required this.status, super.key});
  final SubscriptionStaus status;

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: CustomText('Success'),
        ),
      );
}
