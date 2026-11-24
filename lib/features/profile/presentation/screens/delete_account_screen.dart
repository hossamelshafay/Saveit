import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/auth/presentation/cubit/account_cubit.dart';
import 'package:saveit/core/widgets/app_message.dart';
import 'package:material_ui/material_ui.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final failure = await context.read<AccountCubit>().deleteAccount(
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (failure == null) {
      context.go(RouteNames.login);
    } else {
      final message = failure.code == 'wrong-password'
          ? 'The password you entered is incorrect.'
          : failure.message;
      showAppMessage(
        context,
        title: 'Error',
        message: message,
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccountCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Account"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "⚠️ Enter your password to confirm deleting your account.\nThis will erase all your data permanently!",
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _deleteAccount,
                    child: const Text(
                      "Yes, Delete My Account",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
