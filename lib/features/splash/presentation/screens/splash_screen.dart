import 'package:material_ui/material_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final void Function(BuildContext) onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _disappearController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _disappearAnimation;

  bool _isDisappearing = false;

  @override
  void initState() {
    super.initState();

    // Start animations and check auth after delay
    _initializeAnimations();
    _checkAuthAfterDelay();
  }

  Future<void> _checkAuthAfterDelay() async {
    try {
      await Future.wait([
        Future<void>.delayed(const Duration(seconds: 2)),
        _fadeController.forward().orCancel,
        _scaleController.forward().orCancel,
        _slideController.forward().orCancel,
      ]);
      if (!mounted) return;
      setState(() => _isDisappearing = true);
      await _disappearController.forward().orCancel;
      if (mounted) widget.onFinished(context);
    } on TickerCanceled {
      // Leaving the splash route cancels its running animations.
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _disappearController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _disappearAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _disappearController,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();

    _disappearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withAlpha(77)),
          ),
          Align(
            alignment: const Alignment(0, -0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _isDisappearing
                      ? _disappearAnimation
                      : _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isDisappearing
                          ? _disappearAnimation.value
                          : _scaleAnimation.value,
                      child: Opacity(
                        opacity: _isDisappearing
                            ? _disappearAnimation.value
                            : 1.0,
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _isDisappearing
                        ? _disappearAnimation
                        : _fadeAnimation,
                    child: const Column(
                      children: [
                        Text(
                          'Track your spending.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Save smarter.',
                          style: TextStyle(
                            color: Color.fromARGB(255, 28, 75, 30),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: FadeTransition(
                opacity: _isDisappearing ? _disappearAnimation : _fadeAnimation,
                child: const Text(
                  'B Y   V E R T E X',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.3);

    var firstControlPoint = Offset(size.width / 4, size.height * 0.1);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.3);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.5);
    var secondEndPoint = Offset(size.width, size.height * 0.3);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
