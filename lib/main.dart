import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:get_storage/get_storage.dart';
import 'package:saveit/view/Splash_screen/splash_screen.dart';
import 'package:saveit/view/Settings_screen/widgets/translations.dart';
import 'package:saveit/view/Settings_screen/settings_screen.dart';
import 'package:saveit/view/Profile_screen/Profile_screen.dart';
import 'package:saveit/services/savings_task_manager.dart';

import 'firebase_options.dart';
import 'controller/settings_controller.dart';
import 'controller/logout_controller.dart';
import 'core/provider/firestore_service.dart';
import 'core/provider/currency_provider.dart';
import 'core/provider/user_provider.dart';
import 'view/Home_screen/Home_screen.dart';
import 'view/Log_in_screen/Log_in_screen.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize GetStorage
    await GetStorage.init();

    // Initialize task manager for daily savings calculation
    SavingsTaskManager.initialize();

    // Initialize services and controllers
    Get.put(AuthService());
    Get.put(SettingsController(), permanent: true);
    Get.put(LogoutController(), permanent: true);

    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<CurrencyProvider>(
          create: (_) => CurrencyProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: Get.find<SettingsController>().isArabic.value
            ? const Locale('ar', 'SA')
            : const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        defaultTransition: Transition.fade,
        title: 'SaveIt',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            elevation: 8.0,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const SplashScreen(),
        getPages: [
          GetPage(
            name: '/splash',
            page: () => const SplashScreen(),
            transition: Transition.fade,
          ),
          GetPage(
            name: '/login',
            page: () => LoginPage(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/home',
            page: () => const HomeScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/profile',
            page: () => const ProfilePage(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/settings',
            page: () => const SettingsScreen(),
            transition: Transition.fadeIn,
          ),
        ],
      ),
    );
  }
}
