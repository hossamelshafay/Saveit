// Refactored lib/view/Settings_screen/Settings_screen.dart - No Dark Mode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/settings_controller.dart';
import '../../controller/logout_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings".tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "general".tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text("language".tr),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settingsController.isArabic.value
                        ? "arabic".tr
                        : "english".tr,
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () => _chooseLanguage(context, settingsController),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: Text("notifications".tr),
                value: settingsController.notificationsEnabled.value,
                onChanged: (val) =>
                    settingsController.notificationsEnabled.value = val,
                activeThumbColor: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "more".tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text("help_support".tr),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.to(() => const HelpSupportPage()),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text("about".tr),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.to(() => const AboutPage()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "account".tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 200, // Fixed width for the container
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () async {
                  final confirm = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text('logout'.tr),
                      content: Text('Are you sure you want to logout?'.tr),
                      actions: [
                        TextButton(
                          child: Text('cancel'.tr),
                          onPressed: () => Get.back(result: false),
                        ),
                        TextButton(
                          child: Text('logout'.tr),
                          onPressed: () => Get.back(result: true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final logoutController = Get.find<LogoutController>();
                    await logoutController.logout();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      "logout".tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _chooseLanguage(BuildContext context, SettingsController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("english".tr),
            onTap: () {
              controller.isArabic.value = false;
              Get.updateLocale(const Locale('en', 'US'));
              Get.back();
            },
          ),
          ListTile(
            title: Text("arabic".tr),
            onTap: () {
              controller.isArabic.value = true;
              Get.updateLocale(const Locale('ar', 'SA'));
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("help_support".tr),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "If you face any issues, please contact us at:\n\nsupport@saveit.com\n\nWe are happy to help you anytime!"
              .tr,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("about".tr), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "SaveIt App\n\nThis application helps you track expenses and manage your budget.\n\nVersion: 1.0.0"
              .tr,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
