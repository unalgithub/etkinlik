import 'package:deneme/screens/login_screen/services/auth_service.dart';
import 'package:deneme/screens/login_screen/services/provider/auth_provider.dart';
import 'package:get_it/get_it.dart';


final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<AuthProvider>(AuthProvider());
  locator.registerSingleton<AuthService>(AuthService());
}