import 'package:saveit/app/localization/app_translations.dart';
import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/auth/presentation/cubit/account_cubit.dart';
import 'package:saveit/core/widgets/app_message.dart';
// Refactored lib/view/Settings_screen/Settings_screen.dart - No Dark Mode
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/settings/presentation/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              "settings".tr(context),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "general".tr(context),
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
                  title: Text("language".tr(context)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.state.isArabic
                            ? "arabic".tr(context)
                            : "english".tr(context),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () => _chooseLanguage(context, settings),
                ),
              ),

              Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: Text("notifications".tr(context)),
                  value: settings.state.notificationsEnabled,
                  onChanged: settings.setNotifications,
                  activeThumbColor: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "more".tr(context),
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
                  title: Text("help_support".tr(context)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.help),
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
                  title: Text("about".tr(context)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.about),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "account".tr(context),
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
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text('logout'.tr(context)),
                          content: Text(
                            'Are you sure you want to logout?'.tr(context),
                          ),
                          actions: [
                            TextButton(
                              child: Text('cancel'.tr(context)),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                            ),
                            TextButton(
                              child: Text('logout'.tr(context)),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        final failure = await context
                            .read<AccountCubit>()
                            .logout();
                        if (!context.mounted) return;
                        if (failure == null) {
                          context.go(RouteNames.login);
                        } else {
                          showAppMessage(
                            context,
                            title: 'Error',
                            message: 'Failed to logout: ${failure.message}',
                            color: Colors.red,
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          "logout".tr(context),
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
        ),
        if (context.watch<AccountCubit>().state) ...[
          const ModalBarrier(dismissible: false, color: Colors.black54),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  void _chooseLanguage(BuildContext context, SettingsCubit controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("english".tr(context)),
            onTap: () {
              controller.setLanguage(isArabic: false);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text("arabic".tr(context)),
            onTap: () {
              controller.setLanguage(isArabic: true);
              Navigator.of(context).pop();
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
        title: Text("help_support".tr(context)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "If you face any issues, please contact us at:\n\nsupport@saveit.com\n\nWe are happy to help you anytime!"
              .tr(context),
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
      appBar: AppBar(
        title: Text("about".tr(context)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "SaveIt App\n\nThis application helps you track expenses and manage your budget.\n\nVersion: 1.0.0"
              .tr(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
