import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/media_service.dart';
import '../../../core/widgets/glass_container.dart';

class SmartCleanerScreen extends StatefulWidget {
  final MediaAlbum album;

  const SmartCleanerScreen({
    super.key,
    required this.album,
  });

  @override
  State<SmartCleanerScreen> createState() => _SmartCleanerScreenState();
}

class _SmartCleanerScreenState extends State<SmartCleanerScreen> {
  late List<LocalMediaFile> _mediaList;
  final List<LocalMediaFile> _markedForDeletion = [];

  @override
  void initState() {
    super.initState();
    _mediaList = List.from(widget.album.files);
  }

  void _onSwipeLeft(LocalMediaFile file) {
    setState(() {
      _markedForDeletion.add(file);
      _mediaList.removeWhere((item) => item.path == file.path);
    });
  }

  void _onSwipeRight(LocalMediaFile file) {
    setState(() {
      _mediaList.removeWhere((item) => item.path == file.path);
    });
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
        title: Text(
          widget.album.title,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.close_rounded, color: Colors.redAccent, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'سحب لليسار: حذف',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        'سحب لليمين: إبقاء',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check_rounded, color: AppColors.accent, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: _mediaList.isEmpty
                  ? _buildEmptyState()
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Dismissible(
                          key: Key(_mediaList.last.path),
                          onDismissed: (direction) {
                            final item = _mediaList.last;
                            if (direction == DismissDirection.endToStart) {
                              _onSwipeLeft(item);
                            } else {
                              _onSwipeRight(item);
                            }
                          },
                          background: _buildSwipeIndicator(
                            alignment: Alignment.centerLeft,
                            icon: Icons.check_circle_outline_rounded,
                            color: Colors.tealAccent,
                            label: 'إبقــاء',
                          ),
                          secondaryBackground: _buildSwipeIndicator(
                            alignment: Alignment.centerRight,
                            icon: Icons.highlight_off_rounded,
                            color: Colors.redAccent,
                            label: 'حــذف',
                          ),
                          child: _buildFloatingPhotoCard(_mediaList.last),
                        ),
                      ),
                    ),
            ),

            if (_markedForDeletion.isNotEmpty) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingPhotoCard(LocalMediaFile media) {
    return GlassContainer(
      borderRadius: 28,
      blur: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: Image.file(
                File(media.path),
                fit: BoxFit.cover,
                cacheWidth: 600,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3B36),
                  child: const Icon(Icons.broken_image_outlined,
                      color: Colors.white38, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  media.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${media.sizeMB} MB',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicator({
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.accent, size: 64),
          SizedBox(height: 16),
          Text(
            'اكتمال فرز جميع الصور في هذا الألبوم!',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: GlassContainer(
        borderRadius: 20,
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المحدد للحذف: ${_markedForDeletion.length} عناصر',
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: _showConfirmationDialog,
              child: const Text(
                'متابعة الحذف',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3B36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تأكيد الحذف النهائي',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'سيتم حذف (${_markedForDeletion.length}) ملفات نهائياً من ذاكرة جوالك. هل أنت متاكد؟',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic', color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              int deletedCount = 0;
              for (var item in _markedForDeletion) {
                bool success = await MediaService.deleteRealFile(item.path);
                if (success) deletedCount++;
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('تم حذف $deletedCount ملفات بنجاح من جهازك')),
                );
                setState(() => _markedForDeletion.clear());
              }
            },
            child: const Text('حذف الآن',
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
