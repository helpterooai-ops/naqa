import 'package:flutter/material.dart';
import 'package:aether_file/core/constants/app_colors.dart';
import 'package:aether_file/core/services/storage_service.dart';
import 'package:aether_file/core/widgets/glass_container.dart';
import 'package:aether_file/features/cleaner/screens/album_selection_screen.dart';
import 'package:aether_file/features/cleaner/screens/junk_scanner_screen.dart';
import 'package:aether_file/core/services/media_service.dart';
import 'package:aether_file/features/cleaner/screens/smart_cleaner_screen.dart';

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

  void _navigateToPhotosOnly() async {
    var albums = await MediaService.fetchComprehensiveAlbums();
    var photoAlbum = albums.firstWhere((a) => a.id == 'photos', orElse: () => MediaAlbum(id: 'photos', title: 'الصور', iconType: 'photo', itemCount: 0, totalSizeMB: 0, files: []));
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SmartCleanerScreen(album: photoAlbum)));
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
          child: Text('نَقـــا', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.accent)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRealStorageSummaryCard(),
            const SizedBox(height: 28),
            const Text('استوديو التنظيف والفرز الذكي', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.18,
              children: [
                GestureDetector(
                  onTap: _navigateToPhotosOnly,
                  child: _buildCategoryCard('الصور والألبومات', 'تنظيف عبر السحب', Icons.photo_library_rounded, AppColors.cardDark, isAccent: true),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AlbumSelectionScreen())),
                  child: _buildCategoryCard('التنظيف المتخصص', 'باقي الملفات', Icons.folder_copy_rounded, AppColors.cardDark),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JunkScannerScreen())),
                  child: _buildCategoryCard('تنظيف المخلفات', 'ملفات النظام المؤقتة', Icons.cleaning_services_rounded, AppColors.cardDark),
                ),
                _buildCategoryCard('الخزنة المشفرة', 'قريباً', Icons.lock_outline_rounded, AppColors.cardDarkSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealStorageSummaryCard() {
    final usagePercent = _storageData?.usagePercentage ?? 0.0;
    return GlassContainer(
      borderRadius: 26,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('سعة ذاكرة النظام الحقيقية', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 12),
          _isLoading
              ? const CircularProgressIndicator(color: AppColors.accent)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${_storageData?.usedSpaceGB ?? 0} GB', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(' / ${_storageData?.totalSpaceGB ?? 0} GB', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, color: Colors.white54)),
                  ],
                ),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: usagePercent, minHeight: 8, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color color, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22), border: Border.all(color: isAccent ? AppColors.accent : Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: isAccent ? AppColors.accent : Colors.white70),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: isAccent ? AppColors.accent : Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}
