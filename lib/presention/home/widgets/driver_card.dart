import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class DriverCard extends StatelessWidget {
  final DriverModel driver;

  const DriverCard({super.key, required this.driver});

  Future<void> _makeCall(BuildContext context) async {
    // 1. Track call in Firestore Analytics
    FirebaseService.trackCallClick(
      driver.id,
      driver.name,
      driver.vehicleType,
    );

    // 2. Direct call link using tel: scheme (no message, directly open dialer)
    final cleanPhone = driver.phone.trim().replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );

    try {
      if (kIsWeb) {
        await launchUrl(launchUri, webOnlyWindowName: '_self');
      } else {
        final launched = await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          await launchUrl(launchUri);
        }
      }
    } catch (_) {
      try {
        await launchUrl(launchUri);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    final locUpazila = strings.translateUpazila(driver.upazila);
    final locDistrict = strings.translateDistrict(driver.district);
    final fallbackLoc = (locUpazila.isNotEmpty && locDistrict.isNotEmpty)
        ? '$locUpazila, $locDistrict'
        : (locDistrict.isNotEmpty ? locDistrict : locUpazila);

    final locationText =
        driver.address.isNotEmpty ? driver.address : fallbackLoc;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFC)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Row: Driver/Vehicle Name & Vehicle Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Vehicle Type Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.renewBg, // Deeper warm peach
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  strings.vehicleCategoryName(driver.vehicleType),
                  style: const TextStyle(
                    color: AppColors.renewText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // 2. Subtitle / Details (e.g. ijwirw, allion 2004)
          if (driver.details.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              driver.details,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textMuted,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 3. Location Row with Red Pin Icon
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.locationRed,
                size: 17,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),

          // 4. Seat Count Row (if present, e.g. আসন সংখ্যা: 25)
          if (driver.seatCount != null && driver.seatCount! > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.infoTeal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${strings.seatingCountPrefix}${driver.seatCount}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textBody,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // 5. Full-Width Vibrant Orange Call Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _makeCall(context),
              icon: const Icon(
                Icons.phone_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                strings.callNow,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

