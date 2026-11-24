import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:saveit/app/localization/app_translations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:saveit/features/profile/presentation/screens/profile_screen.dart';
import 'package:saveit/features/chat/presentation/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.createChatCubit});

  final ChatCubit Function() createChatCubit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const DashboardContent(),
    BlocProvider(
      create: (_) => widget.createChatCubit()..load(),
      child: const SaveitChatScreen(),
    ),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌟 الخلفية بالجرادينت والدواير زي النسخة الطويلة القديمة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Color(0xFFF6FBF6),
                  Color(0xFFE8F6E8),
                  Color(0xFFECF8EE),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.green.withAlpha(31),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withAlpha(15),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  right: -100,
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF81C784).withAlpha(26),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF81C784).withAlpha(15),
                          blurRadius: 80,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "home".tr(context),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "saveit_chat".tr(context),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "profile".tr(context),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
