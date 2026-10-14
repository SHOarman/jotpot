import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/route/app_routes.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class HomeFooterWidget extends StatelessWidget {
  const HomeFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 768;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40 : 20,
            vertical: 36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeb)
                // Web: 3-column horizontal row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1: Logo & description
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'JOT',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'POT',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryOrange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.footerAboutText,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),

                    // Col 2: Contact Us
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.footerHelplineTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Phone: 01677234252',
                            style: TextStyle(
                                color: AppColors.textBody, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Email: support@jotpot.com',
                            style: TextStyle(
                                color: AppColors.textBody, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Address: Tangail / Dhaka, Bangladesh',
                            style: TextStyle(
                                color: AppColors.textBody, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),

                    // Col 3: Quick Links
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.footerQuickLinks,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () =>
                                Get.toNamed(AppRoutes.REGISTER_DRIVER),
                            child: Text(
                              strings.registerAsDriver,
                              style: const TextStyle(
                                  color: AppColors.textBody, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.footerRenew,
                            style: const TextStyle(
                                color: AppColors.textBody, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Privacy Policy',
                            style: TextStyle(
                                color: AppColors.textBody, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                // Mobile: Vertical stacked
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'JOT',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'POT',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.footerAboutText,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.footerHelplineTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Phone: 01677234252',
                  style: TextStyle(color: AppColors.textBody, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Email: support@jotpot.com',
                  style: TextStyle(color: AppColors.textBody, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Address: Tangail / Dhaka, Bangladesh',
                  style: TextStyle(color: AppColors.textBody, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.footerQuickLinks,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.REGISTER_DRIVER),
                  child: Text(
                    strings.registerAsDriver,
                    style:
                        const TextStyle(color: AppColors.textBody, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.footerRenew,
                  style: const TextStyle(color: AppColors.textBody, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Privacy Policy',
                  style: TextStyle(color: AppColors.textBody, fontSize: 14),
                ),
              ],

              const SizedBox(height: 36),

              // Copyright (always centered)
              Center(
                child: Text(
                  strings.footerCopyright,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
