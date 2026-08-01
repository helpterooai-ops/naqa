import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../cleaner/screens/smart_cleaner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StorageInfoData? _storageData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDeviceData();
  }

  Future<void> _initDeviceData() async {
    await StorageService.requestStoragePermission();
    StorageInfoData data = await StorageService.getRealStorageInfo();
    if (mounted) {
      setState(() {
        _storageData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 2.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            onPressed: () {
              setState(() => _isLoading = true);
              _initDeviceData();
            },
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
            // بطاقة التخزين الزجاجية الفاخرة
            _buildRealStorageSummaryCard(),

            const SizedBox(height: 28),

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

            // شبكة التصنيف الذكي المربوطة بالشاشات الحقيقية
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SmartCleanerScreen()),
                    );
                  },
                  child: _buildCategoryCard(
                    title: 'الصور والفيديو',
                    subtitle: 'معرض الجوال الحقيقي',
                    icon: Icons.photo_library_outlined,
                    color: const Color(0xFF1B3B36),
                  ),
                ),
                _buildCategoryCard(
                  title: 'الخزنة المشفرة',
                  subtitle: 'حماية بالبصمة',
                  icon: Icons.lock_outline_rounded,
                  color: const Color(0xFF23322E),
                  isAccent: true,
                ),
                _buildCategoryCard(
                  title: 'المستندات',
                  subtitle: 'الملفات المحلية',
                  icon: Icons.insert_drive_file_outlined,
                  color: const Color(0xFF1B3B36),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SmartCleanerScreen()),
                    );
                  },
                  child: _buildCategoryCard(
                    title: 'التنظيف الذكي',
                    subtitle: 'تفريغ المساحة بالسحب',
                    icon: Icons.cleaning_services_outlined,
                    color: const Color(0xFF1B3B36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealStorageSummaryCard() {
    return GlassContainer(
      borderRadius: 24,
      blur: 15,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'ذاكرة الهاتف الفعليه',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Icon(Icons.sd_storage_rounded, color: AppColors.accent, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : Text(
                  '${_storageData?.usedSpaceGB ?? 0} GB / ${_storageData?.totalSpaceGB ?? 0} GB',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _storageData?.usagePercentage ?? 0.0,
              minHeight: 8,
              backgroundColor: Colors.black26,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

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
              : const Color(0xFFD4AF37).withOpacity(0.15),
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
}
