import 'package:saveit/app/localization/app_translations.dart';
import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveit/features/profile/presentation/cubit/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) return;
      final cubit = context.read<ProfileCubit>();
      try {
        await cubit.updatePhoto(await pickedFile.readAsBytes());
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error updating: $error')));
        }
      }
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
            color: Colors.grey.withAlpha(38),
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
          titleKey.tr(context),
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
  void initState() {
    super.initState();
    // Force refresh user data when profile page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileCubit>().loadUserData(forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "profile".tr(context),
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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = state.user;
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
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
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
                  onTap: () => context.push(RouteNames.personalInfo),
                ),

                _buildProfileOption(
                  icon: Icons.lock_outline,
                  titleKey: "Change Password",
                  onTap: () => context.push(RouteNames.changePassword),
                ),

                _buildProfileOption(
                  icon: Icons.delete_outline,
                  titleKey: "delete",
                  iconColor: Colors.red,
                  onTap: () => context.push(RouteNames.deleteAccount),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
