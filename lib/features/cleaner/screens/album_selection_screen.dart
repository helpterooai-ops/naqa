import 'package:flutter/material.dart';
import 'package:aether_file/core/constants/app_colors.dart';
import 'package:aether_file/core/services/media_service.dart';
import 'package:aether_file/core/widgets/glass_container.dart';
import 'package:aether_file/features/cleaner/screens/smart_cleaner_screen.dart';

class AlbumSelectionScreen extends StatefulWidget {
  const AlbumSelectionScreen({super.key});

  @override
  State<AlbumSelectionScreen> createState() => _AlbumSelectionScreenState();
}

class _AlbumSelectionScreenState extends State<AlbumSelectionScreen> {
  List<MediaAlbum> _albums = [];
  bool _isLoading = true;
  String _selectedGoal = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);
    List<MediaAlbum> fetched = await MediaService.fetchComprehensiveAlbums();
    if (mounted) {
      setState(() {
        _albums = fetched;
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String iconType) {
    switch (iconType) {
      case 'photo':
        return Icons.photo_library_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'doc':
        return Icons.description_rounded;
      case 'audio':
        return Icons.graphic_eq_rounded;
      case 'large':
        return Icons.folder_special_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'أقسام التنظيف المتخصصة',
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalSelectionHeader(),
                    const SizedBox(height: 24),
                    const Text(
                      'اختر القسم للفرز والحذف الذكي',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _albums.length,
                      itemBuilder: (context, index) {
                        final album = _albums[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SmartCleanerScreen(album: album),
                                ),
                              );
                            },
                            child: GlassContainer(
                              borderRadius: 24,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppColors.accent.withOpacity(0.35),
                                      ),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(album.iconType),
                                      color: AppColors.accent,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.title,
                                          style: const TextStyle(
                                            fontFamily: 'IBMPlexSansArabic',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${album.itemCount} عنصر • ${album.totalSizeMB} MB',
                                          style: const TextStyle(
                                            fontFamily: 'IBMPlexSansArabic',
                                            fontSize: 12,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.accent,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGoalSelectionHeader() {
    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.flag_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'تحديد هدف المساحة المطلوب توفيرها (اختياري)',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['1 GB', '2 GB', '5 GB', 'الكل'].map((goal) {
              bool isSelected = _selectedGoal == goal;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.white12,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
