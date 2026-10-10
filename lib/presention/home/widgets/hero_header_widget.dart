import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class HeroHeaderWidget extends StatelessWidget {
  const HeroHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ঝটপট',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            height: 1.1,
          ),
        ),
        SizedBox(height: 2),
        Text(
          '- ভাড়ায় চালিত গাড়ির ডিরেক্টরি',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'আপনার এলাকার বিশ্বস্ত ড্রাইভার খুঁজে পেতে নিচের ফিল্টারগুলো ব্যবহার করুন।',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBody,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
