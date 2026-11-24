import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    primarySwatch: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.text),
      titleTextStyle: AppTextStyles.appBarTitle,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.inactive,
      elevation: AppDimensions.bottomNavigationElevation,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
