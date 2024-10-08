import 'package:deneme/providers/bottom_text_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_content.dart';
import 'package:deneme/screens/login_screen/animations/change_screen_animation.dart';
import 'package:deneme/utils/helper_functions.dart';
import 'package:deneme/utils/constants.dart';

class BottomText extends StatelessWidget {
  const BottomText({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScreenAnimationProvider(),
      child: Consumer<ScreenAnimationProvider>(
        builder: (context, screenAnimationProvider, child) {
          ChangeScreenAnimation.bottomTextAnimation.addStatusListener((status) {
            if (screenAnimationProvider.status != status) {
              screenAnimationProvider.setStatus(status);
            }
          });

          return HelperFunctions.wrapWithAnimatedBuilder(
            animation: ChangeScreenAnimation.bottomTextAnimation,
            child: GestureDetector(
              onTap: () {
                if (!ChangeScreenAnimation.isPlaying) {
                  ChangeScreenAnimation.currentScreen == Screens.signUp
                      ? ChangeScreenAnimation.forward()
                      : ChangeScreenAnimation.reverse();

                  ChangeScreenAnimation.currentScreen = Screens
                      .values[1 - ChangeScreenAnimation.currentScreen.index];
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                    children: [
                      TextSpan(
                        text: ChangeScreenAnimation.currentScreen ==
                                Screens.signUp
                            ? 'Bir hesabın var mı? '
                            : 'Hesabın yok mu? ',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ChangeScreenAnimation.currentScreen ==
                                Screens.signUp
                            ? 'Giriş Yap'
                            : 'Kayıt Ol',
                        style: const TextStyle(
                          color: kSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
