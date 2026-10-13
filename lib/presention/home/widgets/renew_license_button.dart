import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'renew_license_dialog.dart';

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
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.3),
              builder: (context) => const RenewLicenseDialog(),
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
