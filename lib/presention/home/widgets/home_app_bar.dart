import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../core/route/app_routes.dart';
import '../../../utils/app_strings.dart';
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
        child: Container(color: AppColors.borderLight, height: 1),
      ),
      titleSpacing: 16,
      title: Consumer<DriverProvider>(
        builder: (context, provider, _) {
          final isBn = provider.isBengali;

          return Tooltip(
            message: isBn ? 'হোম পেজে যান ও রিফ্রেশ করুন' : 'Go Home & Refresh',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                provider.resetToHomeAndRefresh();
                if (Get.currentRoute != AppRoutes.home) {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'JOT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'POT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryOrange,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (provider.isRefreshing) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        Consumer<DriverProvider>(
          builder: (context, provider, _) {
            final strings = AppStrings(provider.isBengali);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
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
                  child: Text(
                    strings.registerAsDriver,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Language Selector Button [🌐 EN / বাংলা]
                InkWell(
                  onTap: () => provider.toggleLanguage(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: provider.isBengali
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFEFF6FF),
                      border: Border.all(
                        color: provider.isBengali
                            ? AppColors.border
                            : const Color(0xFF3B82F6),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 15,
                          color: provider.isBengali
                              ? AppColors.textDark
                              : const Color(0xFF1D4ED8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.isBengali ? 'English' : 'বাংলা',
                          style: TextStyle(
                            color: provider.isBengali
                                ? AppColors.textDark
                                : const Color(0xFF1D4ED8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        const SizedBox(width: 14),
      ],
    );
  }
}
