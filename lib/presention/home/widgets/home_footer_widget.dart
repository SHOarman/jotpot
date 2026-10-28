import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../core/route/app_routes.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';
import '../../policy/policy_content.dart';
import '../../policy/widgets/policy_dialog.dart';
import 'renew_license_dialog.dart';

class HomeFooterWidget extends StatelessWidget {
  const HomeFooterWidget({super.key});

  void _openPolicy(BuildContext context, PolicyType type) {
    PolicyDialog.show(context, type);
  }

  void _openRenewLicense(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => const RenewLicenseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final strings = AppStrings.of(context);
    final settings = provider.globalSettings;
    final phone = settings.contactPhone;
    final email = settings.contactEmail;
    final address = settings.contactAddress;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 800;

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
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeb)
                // Web: 4-column balanced horizontal row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1: Brand Logo & Description
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
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_outlined,
                                  size: 14,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  strings.isBn
                                      ? 'উন্মুক্ত রেন্ট-এ-কার ডিরেক্টরি'
                                      : 'Open Vehicle Rental Directory',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36),

                    // Col 2: Help & Contact
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
                          const SizedBox(height: 14),
                          _buildContactRow(
                            icon: Icons.phone_in_talk_outlined,
                            text: 'Phone: $phone',
                          ),
                          const SizedBox(height: 10),
                          _buildContactRow(
                            icon: Icons.mail_outline_rounded,
                            text: 'Email: $email',
                          ),
                          const SizedBox(height: 10),
                          _buildContactRow(
                            icon: Icons.location_on_outlined,
                            text: 'Address: $address',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36),

                    // Col 3: Quick Links
                    Expanded(
                      flex: 2,
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
                          const SizedBox(height: 14),
                          _FooterInteractiveLink(
                            text: strings.registerAsDriver,
                            onTap: () =>
                                Get.toNamed(AppRoutes.registerDriver),
                          ),
                          const SizedBox(height: 10),
                          _FooterInteractiveLink(
                            text: strings.footerRenew,
                            onTap: () => _openRenewLicense(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36),

                    // Col 4: Policies & Info (Privacy Policy, About Us, Terms & Conditions)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.footerLegalTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FooterInteractiveLink(
                            text: strings.footerPrivacyPolicy,
                            isUnderlined: true,
                            onTap: () => _openPolicy(
                                context, PolicyType.privacyPolicy),
                          ),
                          const SizedBox(height: 10),
                          _FooterInteractiveLink(
                            text: strings.footerAboutUs,
                            isUnderlined: true,
                            onTap: () =>
                                _openPolicy(context, PolicyType.aboutUs),
                          ),
                          const SizedBox(height: 10),
                          _FooterInteractiveLink(
                            text: strings.footerTermsConditions,
                            isUnderlined: true,
                            onTap: () => _openPolicy(
                                context, PolicyType.termsAndConditions),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                // Mobile: Stacked Vertical View
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
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Helpline Section
                Text(
                  strings.footerHelplineTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactRow(
                  icon: Icons.phone_in_talk_outlined,
                  text: 'Phone: $phone',
                ),
                const SizedBox(height: 8),
                _buildContactRow(
                  icon: Icons.mail_outline_rounded,
                  text: 'Email: $email',
                ),
                const SizedBox(height: 8),
                _buildContactRow(
                  icon: Icons.location_on_outlined,
                  text: 'Address: $address',
                ),
                const SizedBox(height: 24),

                // Quick Links
                Text(
                  strings.footerQuickLinks,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _FooterInteractiveLink(
                  text: strings.registerAsDriver,
                  onTap: () => Get.toNamed(AppRoutes.registerDriver),
                ),
                const SizedBox(height: 8),
                _FooterInteractiveLink(
                  text: strings.footerRenew,
                  onTap: () => _openRenewLicense(context),
                ),
                const SizedBox(height: 24),

                // Policies & Terms Section
                Text(
                  strings.footerLegalTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _FooterInteractiveLink(
                  text: strings.footerPrivacyPolicy,
                  isUnderlined: true,
                  onTap: () =>
                      _openPolicy(context, PolicyType.privacyPolicy),
                ),
                const SizedBox(height: 8),
                _FooterInteractiveLink(
                  text: strings.footerAboutUs,
                  isUnderlined: true,
                  onTap: () => _openPolicy(context, PolicyType.aboutUs),
                ),
                const SizedBox(height: 8),
                _FooterInteractiveLink(
                  text: strings.footerTermsConditions,
                  isUnderlined: true,
                  onTap: () =>
                      _openPolicy(context, PolicyType.termsAndConditions),
                ),
              ],

              const SizedBox(height: 36),

              // Divider before copyright
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 20),

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

  static Widget _buildContactRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryOrange),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textBody,
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterInteractiveLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isUnderlined;

  const _FooterInteractiveLink({
    required this.text,
    required this.onTap,
    this.isUnderlined = false,
  });

  @override
  State<_FooterInteractiveLink> createState() => _FooterInteractiveLinkState();
}

class _FooterInteractiveLinkState extends State<_FooterInteractiveLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        _isHovered ? AppColors.primaryOrange : AppColors.textBody;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 14,
            color: activeColor,
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
            decoration: (widget.isUnderlined || _isHovered)
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: activeColor,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
