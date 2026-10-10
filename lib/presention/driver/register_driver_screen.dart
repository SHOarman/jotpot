import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../home/widgets/home_chat_fab.dart';
import '../home/widgets/register_driver_dialog.dart';

class RegisterDriverScreen extends StatelessWidget {
  const RegisterDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: const HomeChatFab(),
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: RegisterDriverDialog(),
          ),
        ),
      ),
    );
  }
}
