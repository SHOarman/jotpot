import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class HeroHeaderWidget extends StatelessWidget {
  const HeroHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final strings = AppStrings.of(context);
    final isBn = strings.isBn;
    final brandTitle = isBn ? 'ঝটপট' : 'Jotpot';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: isBn ? 'ডাটা রিফ্রেশ করতে চাপুন' : 'Tap to refresh data',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              provider.resetToHomeAndRefresh();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                brandTitle,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          strings.appSubtitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.heroDescription,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textBody,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
