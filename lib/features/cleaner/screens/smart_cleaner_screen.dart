import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aether_file/core/constants/app_colors.dart';
import 'package:aether_file/core/services/media_service.dart';
import 'package:aether_file/core/widgets/glass_container.dart';

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

  void _toggleLockStatus(LocalMediaFile file) {
    setState(() {
      file.isLocked = !file.isLocked;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: file.isLocked ? AppColors.emeraldLocked : AppColors.cardDark,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              file.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              file.isLocked
                  ? 'تم تثبيت العنصر باللون الأخضر (محمي من الحذف)'
                  : 'تم إزالة التثبيت (يمكنك فرزه الآن)',
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSwipeLeft(LocalMediaFile file) {
    if (file.isLocked) return;
    setState(() {
      _markedForDeletion.add(file);
      _mediaList.removeWhere((item) => item.path == file.path);
    });
  }

  void _onSwipeRight(LocalMediaFile file) {
    if (file.isLocked) return;
    setState(() {
      _mediaList.removeWhere((item) => item.path == file.path);
    });
  }

  void _showVideoInfoDialog(LocalMediaFile media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 28,
        color: AppColors.backgroundDark.withOpacity(0.92),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.video_collection_rounded, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'المصدر: ${media.sourceApp}',
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.sd_card_outlined, 'الحجم الحقيقي', '${media.sizeMB} MB'),
            _buildDetailRow(Icons.calendar_today_outlined, 'تاريخ التعديل', media.modifiedDate.toString().split('.')[0]),
            _buildDetailRow(Icons.folder_open_outlined, 'مسار الملف', media.path),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: media.isLocked ? Colors.grey : AppColors.rubyDelete,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: media.isLocked
                        ? null
                        : () {
                            Navigator.pop(context);
                            _onSwipeLeft(media);
                          },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    label: const Text(
                      'نقل لسلة الحذف',
                      style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: media.isLocked ? AppColors.emeraldLocked : AppColors.cardDark,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.accent, width: 1),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _toggleLockStatus(media);
                  },
                  icon: Icon(
                    media.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    media.isLocked ? 'مُثبّت' : 'تثبيت باللون الأخضر',
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: Colors.white54),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '← سحب لليسار: حذف',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.rubyDelete),
                  ),
                  Text(
                    'ضغط مطول: تثبيت بالأخضر 🔒',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.emeraldLocked),
                  ),
                  Text(
                    'سحب لليمين: إبقاء →',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _mediaList.isEmpty
                  ? _buildEmptyState()
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _mediaList.last.category == 'image' || _mediaList.last.category == 'video'
                            ? _buildSwipeableCard(_mediaList.last)
                            : _buildListItemsView(),
                      ),
                    ),
            ),

            if (_markedForDeletion.isNotEmpty) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableCard(LocalMediaFile media) {
    bool isLocked = media.isLocked;

    return GestureDetector(
      onLongPress: () => _toggleLockStatus(media),
      onTap: () {
        if (media.category == 'video') {
          _showVideoInfoDialog(media);
        }
      },
      child: Dismissible(
        key: Key(media.path),
        confirmDismiss: (direction) async {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('هذا العنصر مُثبّت ومحمي باللون الأخضر. اضغط مطولاً لفك التثبيت.'),
              ),
            );
            return false;
          }
          return true;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            _onSwipeLeft(media);
          } else {
            _onSwipeRight(media);
          }
        },
        background: _buildSwipeGlowHalo(
          color: AppColors.accent.withOpacity(0.25),
          icon: Icons.shield_outlined,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _buildSwipeGlowHalo(
          color: AppColors.rubyDelete.withOpacity(0.25),
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerRight,
        ),
        child: GlassContainer(
          borderRadius: 28,
          blur: 24,
          borderColor: isLocked
              ? AppColors.emeraldLocked
              : AppColors.accent.withOpacity(0.25),
          color: isLocked
              ? AppColors.emeraldLocked.withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 0.85,
                      child: media.category == 'image'
                          ? Image.file(
                              File(media.path),
                              fit: BoxFit.cover,
                              cacheWidth: 600,
                              errorBuilder: (c, e, s) => Container(
                                color: AppColors.cardDark,
                                child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 48),
                              ),
                            )
                          : Container(
                              color: AppColors.cardDark,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 64),
                                  SizedBox(height: 8),
                                  Text(
                                    'انقر لمعاينة الفيديو والتفاصيل',
                                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  if (isLocked)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldLocked,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'مُثبّت ومحمي',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                        Text(
                          'المصدر: ${media.sourceApp}',
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${media.sizeMB} MB',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItemsView() {
    return ListView.builder(
      itemCount: _mediaList.length,
      itemBuilder: (context, index) {
        final media = _mediaList[index];
        bool isLocked = media.isLocked;

        return GestureDetector(
          onLongPress: () => _toggleLockStatus(media),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              borderRadius: 18,
              borderColor: isLocked ? AppColors.emeraldLocked : null,
              color: isLocked ? AppColors.emeraldLocked.withOpacity(0.08) : null,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    media.category == 'document' ? Icons.article_rounded : Icons.audiotrack_rounded,
                    color: isLocked ? AppColors.emeraldLocked : AppColors.accent,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                        Text(
                          '${media.sourceApp} • ${media.sizeMB} MB',
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isLocked ? Icons.lock_rounded : Icons.delete_outline_rounded,
                      color: isLocked ? AppColors.emeraldLocked : AppColors.rubyDelete,
                    ),
                    onPressed: () {
                      if (!isLocked) {
                        _onSwipeLeft(media);
                      } else {
                        _toggleLockStatus(media);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeGlowHalo({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(icon, color: Colors.white, size: 48),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.task_alt_rounded, color: AppColors.accent, size: 64),
          SizedBox(height: 16),
          Text(
            'اكتمال فرز وتنظيف هذا القسم بنجاح!',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    double totalSelectedMB = _markedForDeletion.fold(0, (sum, item) => sum + item.sizeMB);

    return Container(
      padding: const EdgeInsets.all(18),
      child: GlassContainer(
        borderRadius: 22,
        color: Colors.black.withOpacity(0.65),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المحدد للحذف: ${_markedForDeletion.length} عناصر',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'سيتم توفير: ${totalSelectedMB.toStringAsFixed(1)} MB',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rubyDelete,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _showConfirmationDialog,
              child: const Text(
                'تأكيد الحذف',
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
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'تأكيد الحذف النهائي من الذاكرة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'سيتم حذف (${_markedForDeletion.length}) ملفات نهائياً من ذاكرة جوالك. هل أنت متأكد؟',
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
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rubyDelete),
            onPressed: () async {
              Navigator.pop(context);
              int deletedCount = 0;
              for (var item in _markedForDeletion) {
                bool success = await MediaService.deleteRealFile(item.path);
                if (success) deletedCount++;
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف $deletedCount ملفات بنجاح من جهازك')),
                );
                setState(() => _markedForDeletion.clear());
              }
            },
            child: const Text('حذف الآن',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
