import 'package:deneme/screens/login_screen/components/login_content.dart';
import 'package:flutter/material.dart';

class ScreenProvider extends ChangeNotifier {
  Screens _currentScreen = Screens.signIn; // Set your initial screen here

  Screens get currentScreen => _currentScreen;

  void updateScreen(Screens screen) {
    if (_currentScreen != screen) {
      _currentScreen = screen;
      notifyListeners();
    }
  }
}
