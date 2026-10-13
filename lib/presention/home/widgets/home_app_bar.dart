import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../utils/app_theme.dart';
import 'register_driver_dialog.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderLight,
          height: 1,
        ),
      ),
      titleSpacing: 16,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'JOT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: 'POT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryOrange,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      actions: [

        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.3),
              builder: (context) => const RegisterDriverDialog(),
            );
          },
          child: const Text(
            'ড্রাইভার হিসেবে নিবন্ধন করুন',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Language Selector Button [🌐 EN]
        Consumer<DriverProvider>(
          builder: (context, provider, _) => InkWell(
            onTap: () => provider.toggleLanguage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    size: 14,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isBengali ? 'EN' : 'বাংলা',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(width: 14),
      ],
    );
  }
}
