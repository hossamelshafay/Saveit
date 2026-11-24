import 'package:saveit/app/localization/app_translations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// lib/view/Profile_screen/widgets/personal_info.dart
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/profile/presentation/cubit/profile_cubit.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  String? name;
  String? location;
  String? bio;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final cubit = context.read<ProfileCubit>();
    final userData = cubit.state.user;
    if (userData != null) {
      setState(() {
        name = userData.username;
        // Add these fields to UserModel if needed
        // location = userData.location;
        // bio = userData.bio;
      });
    }
  }

  Future<void> _editField(String field, String? currentValue) async {
    final cubit = context.read<ProfileCubit>();

    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field".tr(context)),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("cancel".tr(context)),
          ),
          TextButton(
            onPressed: () async {
              try {
                final fieldKey = field == "Name"
                    ? "username"
                    : field.toLowerCase();

                await cubit.updateField(fieldKey, controller.text.trim());

                if (mounted) {
                  setState(() {
                    switch (field) {
                      case "Name":
                        name = controller.text.trim();
                        break;
                      case "Location":
                        location = controller.text.trim();
                        break;
                      case "Bio":
                        bio = controller.text.trim();
                        break;
                    }
                  });
                }
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
                }
              }
            },
            child: Text("save".tr(context)),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("personal_info".tr(context)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text("${'Name'.tr(context)}: ${name ?? ""}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField("Name", name),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text("${'City'.tr(context)}: ${location ?? ""}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField("Location", location),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text("${'bio'.tr(context)}: ${bio ?? ""}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField("Bio", bio),
            ),
          ),
        ],
      ),
    );
  }
}
