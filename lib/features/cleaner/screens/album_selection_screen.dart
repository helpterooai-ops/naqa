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

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    List<MediaAlbum> fetched = await MediaService.fetchComprehensiveAlbums();
    if (mounted) setState(() { _albums = fetched; _isLoading = false; });
  }

  IconData _getCategoryIcon(String iconType) {
    if (iconType == 'video') return Icons.video_library_rounded;
    if (iconType == 'doc') return Icons.insert_drive_file_rounded;
    if (iconType == 'audio') return Icons.library_music_rounded;
    return Icons.folder_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.accent), onPressed: () => Navigator.pop(context)),
        title: const Text('الملفات والمستندات', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 19, color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                if (album.id == 'photos') return const SizedBox.shrink(); // تم نقل الصور للشاشة الرئيسية
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SmartCleanerScreen(album: album))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(album.iconType), color: AppColors.accent, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(album.title, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 16, color: Colors.white)),
                                Text('${album.itemCount} عنصر • ${album.totalSizeMB} ميجابايت', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
