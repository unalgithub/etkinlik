import 'package:flutter/material.dart';

class ScreenAnimationProvider extends ChangeNotifier {
  AnimationStatus? _status;

  AnimationStatus? get status => _status;

  void setStatus(AnimationStatus status) {
    _status = status;
    notifyListeners();
  }
}