import 'package:deneme/locator.dart';
import 'package:deneme/providers/bottom_text_provider.dart';
import 'package:deneme/providers/event_detail_provider.dart';
import 'package:deneme/providers/event_form_provider.dart';
import 'package:deneme/providers/event_provider.dart';
import 'package:deneme/providers/theme_provider.dart';
import 'package:deneme/providers/top_text_provider.dart';
import 'package:deneme/screens/anasayfa.dart';
import 'package:deneme/screens/login_screen/login_screen.dart';
import 'package:deneme/screens/login_screen/services/provider/auth_provider.dart';
import 'package:deneme/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:deneme/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized(); 
  setupLocator();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScreenProvider()),
          ChangeNotifierProvider(create: (_) => EventFormProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => locator.get<AuthProvider>()),
          ChangeNotifierProvider(create: (_) => EventDetailProvider()),
          ChangeNotifierProvider(create: (_) => ScreenAnimationProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()), 
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, child) {
        final provider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          theme: provider.theme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          initialRoute: '/',  // Başlangıç rotası
          routes: {
            '/': (context) => const SplashScreen(), // SplashScreen başlangıç ekranı oldu
            '/login': (context) => const LoginScreen(),
            '/eventPage': (context) => const EventPage(),  // EventPage rotası eklendi
          },
        );
      },
    );
  }
}
