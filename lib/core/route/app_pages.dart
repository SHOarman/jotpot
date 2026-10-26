import 'package:get/get.dart';
import '../../presention/splash/splash_screen.dart';
import '../../presention/home/home_screen.dart';
import '../../presention/driver/register_driver_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.registerDriver,
      page: () => const RegisterDriverScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
