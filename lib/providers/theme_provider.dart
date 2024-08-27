import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;
 ThemeData _theme = ThemeData.dark();
 ThemeData get theme => _theme;



 void toogleTheme(){
final isDark = _theme == ThemeData.dark();
if (isDark){
  _theme = ThemeData.light();
 }
 else{
  _theme = ThemeData.dark();
 }
notifyListeners();

 }
}