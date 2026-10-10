import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_theme.dart';

class RenewLicenseButton extends StatelessWidget {
  const RenewLicenseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE0C4), // Deeper, warmer peach color
        borderRadius: BorderRadius.circular(12),
        // No side border as requested
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.snackbar(
              'লাইসেন্স নবায়ন',
              'আপনার লাইসেন্স নবায়ন পোর্টালে পুনঃনির্দেশ করা হচ্ছে...',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.renewText,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: AppColors.renewText,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Renew License',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.renewText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
