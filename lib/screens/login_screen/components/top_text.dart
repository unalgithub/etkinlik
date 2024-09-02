import 'package:deneme/providers/top_text_provider.dart';
import 'package:deneme/screens/login_screen/animations/change_screen_animation.dart';
import 'package:deneme/screens/login_screen/components/login_content.dart';
import 'package:deneme/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopText extends StatelessWidget {
  const TopText({super.key});

  @override
  Widget build(BuildContext context) {
    final screenProvider = context.watch<ScreenProvider>();

    return HelperFunctions.wrapWithAnimatedBuilder(
      animation: ChangeScreenAnimation.topTextAnimation,
      child: Text(
        screenProvider.currentScreen == Screens.signUp
            ? 'Hesap\nOluştur'
            : 'Tekrar\nHoşgeldin',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
