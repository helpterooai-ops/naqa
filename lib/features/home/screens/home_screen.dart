import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // خلفية الزمرد الداكن الليلي
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'نَقـــا',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.accent, // لمسة ذهبية
              letterSpacing: 2.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.accent),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة ملخص الذاكرة الفاخرة (Dark Card)
            _buildStorageSummaryCard(),

            const SizedBox(height: 28),

            // عنوان أقسام التنظيم
            const Text(
              'التصنيف الذكي',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // شبكة الأقسام الرئيسية (صور، مستندات، خزنة، الخ)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                _buildCategoryCard(
                  title: 'الصور الفاخرة',
                  subtitle: '1,240 ملف',
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFF1B3B36),
                ),
                _buildCategoryCard(
                  title: 'الخزنة المشفرة',
                  subtitle: 'محمي بالبصمة',
                  icon: Icons.lock_outline_rounded,
                  color: const Color(0xFF23322E),
                  isAccent: true,
                ),
                _buildCategoryCard(
                  title: 'المستندات',
                  subtitle: '85 ملف',
                  icon: Icons.insert_drive_file_outlined,
                  color: const Color(0xFF1B3B36),
                ),
                _buildCategoryCard(
                  title: 'التنظيف الذكي',
                  subtitle: 'تفريغ المساحة',
                  icon: Icons.cleaning_services_outlined,
                  color: const Color(0xFF1B3B36),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // أحدث الملفات المنظمة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'أحدث الأصول',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildRecentFileTile(
              title: 'دعوة_زفاف_فاخرة.pdf',
              date: 'اليوم، 02:30 م',
              size: '4.2 MB',
              icon: Icons.picture_as_pdf_outlined,
            ),
            _buildRecentFileTile(
              title: 'جلسة_تصوير_شخصية.raw',
              date: 'أمس',
              size: '18.5 MB',
              icon: Icons.image_outlined,
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة ملخص السعة بالوضع الليلي
  Widget _buildStorageSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3B36), // زمردي فاخر
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'مساحة التخزين المحلية',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Icon(Icons.offline_bolt_outlined, color: AppColors.accent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '42.8 GB / 128 GB',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          // شريط التقدم الفاخر
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.35,
              minHeight: 8,
              backgroundColor: Colors.black26,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  // بطاقات التصنيفات
  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isAccent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAccent
              ? AppColors.accent.withOpacity(0.6)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 28,
            color: isAccent ? AppColors.accent : Colors.white70,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 11,
                  color: isAccent ? AppColors.accent : Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // عنصر القائمة للملفات الحديثة
  Widget _buildRecentFileTile({
    required String title,
    required String date,
    required String size,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162B27),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '$date • $size',
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 12,
            color: Colors.white38,
          ),
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.white38),
      ),
    );
  }
}
