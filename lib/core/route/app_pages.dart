import 'package:get/get.dart';
import '../../presention/splash/splash_screen.dart';
import '../../presention/home/home_screen.dart';
import '../../presention/driver/register_driver_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.REGISTER_DRIVER,
      page: () => const RegisterDriverScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
