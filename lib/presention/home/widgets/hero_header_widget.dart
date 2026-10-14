import 'package:flutter/material.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class HeroHeaderWidget extends StatelessWidget {
  const HeroHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.appTitle,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            height: 1.1,
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
