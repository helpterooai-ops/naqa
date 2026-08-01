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
    setState(() => _isLoading = true);
    List<MediaAlbum> fetched = await MediaService.fetchRealAlbums();
    if (mounted) {
      setState(() {
        _albums = fetched;
        _isLoading = false;
      });
    }
  }

  IconData _getAlbumIcon(String id) {
    switch (id) {
      case 'screenshots':
        return Icons.screenshot_monitor_rounded;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'whatsapp':
        return Icons.chat_bubble_outline_rounded;
      case 'downloads':
        return Icons.download_for_offline_outlined;
      case 'large':
        return Icons.folder_special_outlined;
      default:
        return Icons.photo_library_outlined;
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
          'ألبومات الملفات',
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 20,
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
            : _albums.isEmpty
                ? const Center(
                    child: Text(
                      'لم يتم العثور على ألبومات في ذاكرة الهاتف',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        color: Colors.white54,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _albums.length,
                    itemBuilder: (context, index) {
                      final album = _albums[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SmartCleanerScreen(
                                album: album,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            borderRadius: 22,
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.accent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    _getAlbumIcon(album.id),
                                    color: AppColors.accent,
                                    size: 26,
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
                                      const SizedBox(height: 4),
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
      ),
    );
  }
}
