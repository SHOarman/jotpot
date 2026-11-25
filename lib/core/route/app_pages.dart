import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../presention/splash/splash_screen.dart';
import '../../presention/home/home_screen.dart';
import '../../presention/driver/register_driver_screen.dart';
import '../../presention/policy/policy_content.dart';
import '../../presention/policy/policy_screen.dart';
import 'app_routes.dart';

class AppPages {
  static String get initial => kIsWeb ? AppRoutes.home : AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => kIsWeb ? const HomeScreen() : const SplashScreen(),
      transition: kIsWeb ? Transition.noTransition : Transition.fade,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.registerDriver,
      page: () => const RegisterDriverScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PolicyScreen(type: PolicyType.privacyPolicy),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const PolicyScreen(type: PolicyType.termsAndConditions),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const PolicyScreen(type: PolicyType.aboutUs),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
