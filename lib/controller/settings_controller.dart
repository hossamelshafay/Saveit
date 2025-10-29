import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  var isArabic = false.obs;
  var notificationsEnabled = true.obs;
  var monthlyBudget = 1000.0.obs;

  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Load stored values
    isArabic.value = _storage.read('isArabic') ?? false;
    notificationsEnabled.value = _storage.read('notifications') ?? true;
  }

  // No dark mode functionality
}
