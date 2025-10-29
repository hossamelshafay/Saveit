import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'widgets/personal_info.dart';
import 'widgets/delete_account_page.dart';
import 'widgets/change_password_page.dart';
import '../../core/provider/user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final storageRef = FirebaseStorage.instance.ref().child(
        'users/${user.uid}/profile.jpg',
      );
      await storageRef.putFile(imageFile);

      String downloadUrl = await storageRef.getDownloadURL();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserData({'photoUrl': downloadUrl});
    }
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String titleKey,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).iconTheme.color,
        ),
        title: Text(
          titleKey.tr,
          style: TextStyle(
            fontSize: 16,
            color: iconColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  @override
  void initState() {
    super.initState();
    // Force refresh user data when profile page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).loadUserData(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "profile".tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = userProvider.currentUser;
            if (userData == null) {
              return const Center(child: Text("No user data found"));
            }

            String name = userData.username;
            String email = userData.email;
            String? photoUrl = userData.photoUrl;

            String initials = (name.isNotEmpty)
                ? name.split(" ").map((e) => e[0]).take(2).join()
                : "U";

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green[200],
                        backgroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildProfileOption(
                    icon: Icons.person_outlined,
                    titleKey: "personal_info",
                    onTap: () => Get.to(() => const PersonalInfoPage()),
                  ),

                  _buildProfileOption(
                    icon: Icons.lock_outline,
                    titleKey: "Change Password",
                    onTap: () => Get.to(() => const ChangePasswordPage()),
                  ),

                  _buildProfileOption(
                    icon: Icons.delete_outline,
                    titleKey: "delete",
                    iconColor: Colors.red,
                    onTap: () => Get.to(() => const DeleteAccountPage()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
