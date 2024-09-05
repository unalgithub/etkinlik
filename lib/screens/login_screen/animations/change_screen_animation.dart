  import 'package:flutter/material.dart';
  import '../components/login_content.dart';

  class ChangeScreenAnimation {
  static AnimationController? topTextController;
  static late Animation<Offset> topTextAnimation;

  static AnimationController? bottomTextController;
  static late Animation<Offset> bottomTextAnimation;

  static final List<AnimationController> createAccountControllers = [];
  static final List<Animation<Offset>> createAccountAnimations = [];

  static final List<AnimationController> loginControllers = [];
  static final List<Animation<Offset>> loginAnimations = [];

  static var isPlaying = false;
  static var currentScreen = Screens.signUp;

  static Animation<Offset> _createAnimation({
    required Offset begin,
    required Offset end,
    required AnimationController parent,
  }) {
    return Tween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: parent,
        curve: Curves.easeInOut,
      ),
    );
  }

  static void initialize({
    required TickerProvider vsync,
    required int createAccountItems,
    required int loginItems,
  }) {
    // Eğer topTextController daha önce başlatılmamışsa initialize edin
    if (topTextController == null) {
      topTextController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );

      topTextAnimation = _createAnimation(
        begin: Offset.zero,
        end: const Offset(-1.2, 0),
        parent: topTextController!,
      );
    }

    // Aynı kontrolü bottomTextController için de yapıyoruz
    if (bottomTextController == null) {
      bottomTextController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );

      bottomTextAnimation = _createAnimation(
        begin: Offset.zero,
        end: const Offset(0, 1.7),
        parent: bottomTextController!,
      );
    }

    for (var i = 0; i < createAccountItems; i++) {
      createAccountControllers.add(
        AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 200),
        ),
      );

      createAccountAnimations.add(
        _createAnimation(
          begin: Offset.zero,
          end: const Offset(-1, 0),
          parent: createAccountControllers[i],
        ),
      );
    }

    for (var i = 0; i < loginItems; i++) {
      loginControllers.add(
        AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 200),
        ),
      );

      loginAnimations.add(
        _createAnimation(
          begin: const Offset(1, 0),
          end: Offset.zero,
          parent: loginControllers[i],
        ),
      );
    }
  }

  static void dispose() {
    for (final controller in [
      topTextController,
      bottomTextController,
      ...createAccountControllers,
      ...loginControllers,
    ]) {
      controller?.dispose();  // Kontroller null olabilir, bu yüzden '?' ekliyoruz
    }
  }

  static Future<void> forward() async {
    isPlaying = true;

    topTextController?.forward();
    await bottomTextController?.forward();

    for (final controller in [
      ...createAccountControllers,
      ...loginControllers,
    ]) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    bottomTextController?.reverse();
    await topTextController?.reverse();

    isPlaying = false;
  }

  static Future<void> reverse() async {
    isPlaying = true;

    topTextController?.forward();
    await bottomTextController?.forward();

    for (final controller in [
      ...loginControllers.reversed,
      ...createAccountControllers.reversed,
    ]) {
      controller.reverse();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    bottomTextController?.reverse();
    await topTextController?.reverse();

    isPlaying = false;
  }
}
