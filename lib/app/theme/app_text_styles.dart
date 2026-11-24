import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

abstract final class AppTextStyles {
  static const appBarTitle = TextStyle(
    color: AppColors.text,
    fontSize: AppDimensions.appBarTitleSize,
    fontWeight: FontWeight.bold,
  );
}
