import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:saveit/core/errors/failures.dart';
import 'package:saveit/core/widgets/app_message.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lottie/lottie.dart';

/// كلاس لقص الخلفية بحيث يبقى فيه حواف
class TopSideCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(0, size.height - 40, 40, size.height - 40);
    path.lineTo(size.width - 40, size.height - 40);
    path.quadraticBezierTo(
      size.width,
      size.height - 40,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(Future<Failure?> Function() authenticate) async {
    final failure = await authenticate();
    if (!mounted) return;
    if (failure == null) {
      context.go(RouteNames.home);
    } else {
      showAppMessage(
        context,
        title: failure.title ?? 'Error',
        message: failure.message,
        color: failure.warning ? Colors.orange : Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AuthFormCubit>();
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // الجزء العلوي فيه الخلفية واللوجو
              SizedBox(
                height: height * 0.3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipPath(
                      clipper: TopSideCurveClipper(),
                      child: Image.asset(
                        "assets/images/background.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 170,
                        width: 170,
                      ),
                    ),
                  ],
                ),
              ),
              // الجزء السفلي فيه الـ Form
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Sign in to enjoy the best experience",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 30),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password
                          BlocBuilder<AuthFormCubit, AuthFormState>(
                            builder: (context, state) => TextFormField(
                              controller: _passwordController,
                              obscureText: state.passwordHidden,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.passwordHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.push(RouteNames.forgotPassword);
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _submit(
                                  () => controller.login(
                                    _emailController.text,
                                    _passwordController.text,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "- Or sign in with -",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 15),

                          // Social Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                onPressed: () => _submit(controller.google),
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                                onPressed: () => _submit(
                                  () =>
                                      controller.anonymous(registering: false),
                                ),
                                tooltip: "Guest",
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: () {
                              context.push(RouteNames.register);
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: "Sign up",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Loading Overlay
          BlocBuilder<AuthFormCubit, AuthFormState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/loading.json',
                          width: 200,
                          height: 200,
                          repeat: true,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Please wait...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
