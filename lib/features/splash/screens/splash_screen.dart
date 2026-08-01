import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد حركة التلاشي والامتداد الفاخرة
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // بدء الحركة ثم الانتقال بالتلاشي
    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // انتقال سينمائي بتلاشي سلس جداً إلى الشاشة الرئيسية
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // اللون الزمردي الداكن الفاخر
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الشعار الأيقوني المذهب
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.08),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.folder_special_rounded,
                        size: 72,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // النص العربي الذهبي الفاخر مع التدرج اللوني (Golden Metallic Effect)
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFF1B0), // ذهبي فاتح براق
                          Color(0xFFD4AF37), // ذهبي فاخر متوسط
                          Color(0xFFAA7C11), // ذهبي داكن عميق
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Text(
                        'نقـــــاء',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // مطلوب لعمل الـ ShaderMask
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // الوصف الفرعي اللاتيني
                    const Text(
                      'LUXURY SMART FILE ORGANIZER',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
