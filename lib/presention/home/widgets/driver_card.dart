import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/driver_model.dart';
import '../../../utils/app_theme.dart';

class DriverCard extends StatelessWidget {
  final DriverModel driver;

  const DriverCard({super.key, required this.driver});

  void _makeCall(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone, color: AppColors.primaryOrange),
            const SizedBox(width: 8),
            Text(driver.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'গাড়ির ধরন: ${driver.vehicleType}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'মোবাইল: ${driver.phone}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text('ঠিকানা: ${driver.address.isNotEmpty ? driver.address : "${driver.upazila}, ${driver.district}"}'),
            if (driver.seatCount != null && driver.seatCount! > 0) ...[
              const SizedBox(height: 6),
              Text('আসন সংখ্যা: ${driver.seatCount}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('বন্ধ করুন', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.call, size: 18),
            label: const Text('কল করুন'),
            onPressed: () {
              Get.back();
              Get.snackbar(
                'কল করা হচ্ছে',
                'ডায়াল করা হচ্ছে: ${driver.phone}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryOrange,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationText = driver.address.isNotEmpty
        ? driver.address
        : '${driver.upazila}, ${driver.district}';

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
                  driver.vehicleType,
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
                Text(
                  'আসন সংখ্যা: ${driver.seatCount}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textBody,
                    fontWeight: FontWeight.w500,
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
              label: const Text(
                'কল করুন',
                style: TextStyle(
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

