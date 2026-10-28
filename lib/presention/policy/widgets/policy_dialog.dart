import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../core/route/app_routes.dart';
import '../../../utils/app_theme.dart';
import '../policy_content.dart';

class PolicyDialog extends StatefulWidget {
  final PolicyType policyType;

  const PolicyDialog({
    super.key,
    required this.policyType,
  });

  static Future<void> show(BuildContext context, PolicyType type) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => PolicyDialog(policyType: type),
    );
  }

  @override
  State<PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<PolicyDialog> {
  bool? _overrideBengali;

  String _getRouteForType(PolicyType type) {
    switch (type) {
      case PolicyType.privacyPolicy:
        return AppRoutes.privacyPolicy;
      case PolicyType.termsAndConditions:
        return AppRoutes.termsAndConditions;
      case PolicyType.aboutUs:
        return AppRoutes.aboutUs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final isBn = _overrideBengali ?? driverProvider.isBengali;
    final policy = PolicyData.getByType(widget.policyType);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 16,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: mediaQuery.size.height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Dialog Header
              _buildHeader(context, policy, isBn, isMobile),

              const Divider(height: 1, color: AppColors.border),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 28,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Last Updated & Summary
                      _buildSummaryCard(policy, isBn),
                      const SizedBox(height: 20),

                      // Sections (Custom from Admin if present, else default structured sections)
                      if (policy
                          .getCustomContent(
                            settings: driverProvider.globalSettings,
                            isBn: isBn,
                          )
                          ?.isNotEmpty ==
                          true) ...[
                        _buildCustomContentCard(
                          policy.getCustomContent(
                            settings: driverProvider.globalSettings,
                            isBn: isBn,
                          )!,
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        ...policy.sections.map(
                          (sec) => _buildSectionItem(sec, isBn),
                        ),
                      ],

                      // Footer Helpline Box
                      const SizedBox(height: 12),
                      _buildSupportBox(
                        isBn,
                        driverProvider.globalSettings.contactPhone,
                        driverProvider.globalSettings.contactEmail,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // 3. Bottom Actions
              _buildBottomActions(context, isBn),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PolicyData policy,
    bool isBn,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 24,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              policy.icon,
              color: AppColors.primaryOrange,
              size: isMobile ? 22 : 26,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? policy.titleBn : policy.titleEn,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isBn ? 'ঝটপট ডিরেক্টরি' : 'Jotpot Directory',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Language Switcher Toggle Pill
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _overrideBengali = !isBn;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.translate_rounded,
                      size: 14,
                      color: AppColors.textDark,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isBn ? 'EN' : 'বাংলা',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Close icon button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PolicyData policy, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Warm light orange
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBn ? policy.lastUpdatedBn : policy.lastUpdatedEn,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Official Document',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isBn ? policy.summaryBn : policy.summaryEn,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF431407),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionItem(PolicySection section, bool isBn) {
    final bulletPoints = isBn ? section.bulletPointsBn : section.bulletPointsEn;
    final note = isBn ? section.noteBn : section.noteEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  section.icon,
                  size: 18,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBn ? section.titleBn : section.titleEn,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bullet Points
          ...bulletPoints.map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Optional Note
          if (note != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Soft blue note
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1E3A8A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomContentCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF334155),
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildSupportBox(bool isBn, String phone, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.headset_mic_outlined,
            color: AppColors.primaryOrange,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'প্রয়োজনে সহায়তা ও যোগাযোগ' : 'Need Help or Have Questions?',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn
                      ? 'হটলাইন: $phone | ইমেইল: $email'
                      : 'Hotline: $phone | Email: $email',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isBn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Open in full page button
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Get.toNamed(_getRouteForType(widget.policyType));
            },
            icon: const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
            label: Text(
              isBn ? 'পূর্ণ স্ক্রিনে দেখুন' : 'Open Full Page',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),

          // Close Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isBn ? 'ঠিক আছে / বন্ধ করুন' : 'Close',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
