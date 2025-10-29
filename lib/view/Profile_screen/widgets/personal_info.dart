// lib/view/Profile_screen/widgets/personal_info.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/provider/user_provider.dart';
import '../../../core/services/user_service.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.currentUser;
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field".tr),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)),
          TextButton(
            onPressed: () async {
              try {
                final fieldKey = field == "Name"
                    ? "username"
                    : field.toLowerCase();

                // Update in UserProvider
                await userProvider.updateUserData({
                  fieldKey: controller.text.trim(),
                });

                // Also ensure it's properly stored in Firestore
                final userService = UserService();
                if (field == "Name") {
                  await userService.createOrUpdateUser(controller.text.trim());
                }

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
                Get.back();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
                }
              }
            },
            child: Text("save".tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("personal_info".tr), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text("${'Name'.tr}: ${name ?? ""}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField("Name", name),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text("${'City'.tr}: ${location ?? ""}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField("Location", location),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text("${'bio'.tr}: ${bio ?? ""}"),
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
