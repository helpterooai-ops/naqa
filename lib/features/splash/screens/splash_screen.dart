import 'dart:ui';
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
  late Animation<double> _stretchAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد زمن وتدفق الحركة ليكون مثل تطبيق "مَدّ"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // منحنى حركة المَدّ الانسيابي التدريجي
    _stretchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.75, curve: Curves.easeInOutCubicEmphasized),
      ),
    );

    // حركة الظهور الناعم
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // حركة التكبير الذهبي الهادئ
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // التوهج الذهبي النيون للحدود
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // الانتقال التلقائي السلس إلى الشاشة الرئيسية
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 900),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // بناء النص الممتد بحساب دقيق للكشيدات الذهبية
  String _buildStretchedText(double progress) {
    int kashidaCount = (progress * 5).round();
    String kashida = 'ـ' * kashidaCount;
    return 'نَـقَ${kashida}ا';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // خلفية زجاجية مضببة مع هالة ذهبية دائرية متوهجة في المنتصف
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withOpacity(0.18 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                      radius: 0.85,
                    ),
                  ),
                ),
              );
            },
          ),

          // محتوى النص والتأثيرات الزجاجية
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // البطاقة الزجاجية الفاخرة التي تحمل الكلمة الممتدة
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 28,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(
                                    0.2 + (0.4 * _glowAnimation.value),
                                  ),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(
                                      0.12 * _glowAnimation.value,
                                    ),
                                    blurRadius: 35,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: Text(
                                _buildStretchedText(_stretchAnimation.value),
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                  letterSpacing: 2.0 * _stretchAnimation.value,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.accent.withOpacity(0.5),
                                      blurRadius: 15 * _glowAnimation.value,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // الشعار الفرعي الناعم
                        Opacity(
                          opacity: (_controller.value > 0.6)
                              ? ((_controller.value - 0.6) / 0.4).clamp(0.0, 1.0)
                              : 0.0,
                          child: const Text(
                            'منظم الملفات والصور الذكي',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 13,
                              color: Colors.white54,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
