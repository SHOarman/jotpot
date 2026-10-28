import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../utils/app_theme.dart';

class HomeChatFab extends StatelessWidget {
  const HomeChatFab({super.key});

  Future<void> _callSupport(BuildContext context) async {
    final phone = Provider.of<DriverProvider>(context, listen: false)
        .globalSettings
        .contactPhone;
    final targetPhone = phone.isNotEmpty ? phone : '01677234252';
    final uri = Uri(scheme: 'tel', path: targetPhone);

    try {
      if (kIsWeb) {
        await launchUrl(uri, webOnlyWindowName: '_self');
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryOrange,
      shape: const CircleBorder(),
      elevation: 4,
      onPressed: () => _callSupport(context),
      child: const Icon(
        Icons.chat_bubble_outline_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
