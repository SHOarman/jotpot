import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/route/app_routes.dart';
import '../../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Get.offNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Sleek Brand Car Pin Logo
            Image.asset(
              'assets/images/splash_logo.png',
              width: 150,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // 2. JOT (Black) & POT (Orange) Logo
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'JOT',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF000000),
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'POT',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryOrange,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. Subtitle
            const Text(
              'ভাড়ায় চালিত গাড়ির ডিরেক্টরি',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBody,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 48),

            // 4. Bold Brand Orange Loading Spinner
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
                backgroundColor: Color(0xFFFFF2E8),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
