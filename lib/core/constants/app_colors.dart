mkdir -p lib/core/constants && cat << 'EOF' > lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // خلفيات داكنة زجاجية
  static const Color backgroundDark = Color(0xFF090B0E);
  static const Color backgroundCard = Color(0xFF13171F);

  // التأثيرات الزجاجية
  static final Color glassBorder = Colors.white.withOpacity(0.08);
  static final Color glassFill = Colors.white.withOpacity(0.04);

  // التدرج الذهبي الملكي (مخصص لشعار نَقا)
  static const List<Color> goldGradient = [
    Color(0xFFF7D070),
    Color(0xFFC59A3F),
    Color(0xFFE2B755),
    Color(0xFFFFF1BD),
    Color(0xFFC59A3F),
  ];

  static const Color textPrimary = Color(0xFFF5F6F8);
  static const Color textSecondary = Color(0xFF8E99A8);
}
EOF
