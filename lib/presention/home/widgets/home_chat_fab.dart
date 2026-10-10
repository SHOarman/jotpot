import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_theme.dart';

class HomeChatFab extends StatelessWidget {
  const HomeChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryOrange,
      shape: const CircleBorder(),
      elevation: 4,
      onPressed: () {
        Get.snackbar(
          'সাপোর্ট ও সহায়তা',
          'সহায়তার জন্য কল করুন: 01677234297',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryOrange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      },
      child: const Icon(
        Icons.chat_bubble_outline_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
