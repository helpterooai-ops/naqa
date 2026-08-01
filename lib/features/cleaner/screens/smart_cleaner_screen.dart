import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aether_file/core/constants/app_colors.dart';
import 'package:aether_file/core/services/media_service.dart';
import 'package:aether_file/core/widgets/glass_container.dart';

class SmartCleanerScreen extends StatefulWidget {
  final MediaAlbum album;
  const SmartCleanerScreen({super.key, required this.album});

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

  Future<bool> _onWillPop() async {
    if (_markedForDeletion.isEmpty) return true;
    bool shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('تنبيه', style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white)),
        content: const Text('لديك ملفات في سلة المهملات لم يتم حذفها نهائياً. هل تريد الخروج وإلغاء العملية؟', style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('البقاء', style: TextStyle(color: AppColors.accent))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('الخروج', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
    return shouldPop;
  }

  void _showFileInfo(LocalMediaFile media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(media.name, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 16, color: Colors.white)),
            const SizedBox(height: 16),
            Text('الحجم: ${media.sizeMB} ميجابايت', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white70)),
            Text('المسار: ${media.path}', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white70)),
            Text('تاريخ التعديل: ${media.modifiedDate.toString().split('.')[0]}', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isImageMode = widget.album.iconType == 'photo';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        bool shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.accent), onPressed: () async {
            if (await _onWillPop()) Navigator.pop(context);
          }),
          title: Text(widget.album.title, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 18, color: Colors.white)),
        ),
        body: Column(
          children: [
            Expanded(
              child: _mediaList.isEmpty
                  ? const Center(child: Text('لا توجد ملفات إضافية', style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white)))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: isImageMode ? _buildPhotoSwipeCard(_mediaList.last) : _buildListItemsView(),
                    ),
            ),
            if (_markedForDeletion.isNotEmpty) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSwipeCard(LocalMediaFile media) {
    return Dismissible(
      key: Key(media.path),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) _onSwipeLeft(media);
        else _onSwipeRight(media);
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                // تم التعديل إلى contain للحفاظ على جودة وأبعاد الصورة بالكامل
                child: Image.file(File(media.path), fit: BoxFit.contain, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${media.sizeMB} ميجابايت', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.accent)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListItemsView() {
    return ListView.builder(
      itemCount: _mediaList.length,
      itemBuilder: (context, index) {
        final media = _mediaList[index];
        return Dismissible(
          key: Key(media.path),
          direction: DismissDirection.endToStart, // المستندات تُسحب لليسار فقط للحذف
          onDismissed: (direction) => _onSwipeLeft(media),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.redAccent.withOpacity(0.2),
            child: const Icon(Icons.delete, color: Colors.redAccent),
          ),
          child: GestureDetector(
            onTap: () => _showFileInfo(media), // ضغطة واحدة تظهر التفاصيل السفلية
            child: GlassContainer(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(media.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white)),
                        Text('${media.sizeMB} ميجابايت', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.cardDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('للحذف: ${_markedForDeletion.length} ملفات', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              for (var item in _markedForDeletion) {
                await MediaService.deleteRealFile(item.path);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف النهائي')));
                setState(() => _markedForDeletion.clear());
              }
            },
            child: const Text('حذف نهائي', style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
