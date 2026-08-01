import 'dart:io';

class LocalMediaFile {
  final String path;
  final String name;
  final double sizeMB;
  final bool isVideo;
  final DateTime modifiedDate;

  LocalMediaFile({
    required this.path,
    required this.name,
    required this.sizeMB,
    required this.isVideo,
    required this.modifiedDate,
  });
}

class MediaService {
  // مسارات المجلدات الرئيسية في نظام أندرويد
  static final List<String> _targetDirectories = [
    '/storage/emulated/0/DCIM/Camera',
    '/storage/emulated/0/Pictures',
    '/storage/emulated/0/Pictures/Screenshots',
    '/storage/emulated/0/Download',
  ];

  // جلب كافة الصور والفيديوهات الحقيقية من الجوال
  static Future<List<LocalMediaFile>> fetchRealMediaFiles({String filter = 'الكل'}) async {
    List<LocalMediaFile> mediaList = [];

    for (String dirPath in _targetDirectories) {
      Directory dir = Directory(dirPath);
      if (await dir.exists()) {
        try {
          List<FileSystemEntity> entities = dir.listSync(recursive: true);
          for (var entity in entities) {
            if (entity is File) {
              String path = entity.path;
              String lowerPath = path.toLowerCase();

              bool isImage = lowerPath.endsWith('.jpg') ||
                  lowerPath.endsWith('.jpeg') ||
                  lowerPath.endsWith('.png') ||
                  lowerPath.endsWith('.webp');

              bool isVideo = lowerPath.endsWith('.mp4') ||
                  lowerPath.endsWith('.mkv') ||
                  lowerPath.endsWith('.mov');

              bool isScreenshot = lowerPath.contains('screenshot') ||
                  lowerPath.contains('screen_shot') ||
                  path.contains('Screenshots');

              // تطبيق الفلترة حسب الخيار المحدد
              if (filter == 'لقطات الشاشة' && !isScreenshot) continue;
              if (filter == 'الصور' && !isImage) continue;
              if (filter == 'الفيديو' && !isVideo) continue;

              if (isImage || isVideo) {
                int bytes = await entity.length();
                double sizeMB = bytes / (1024 * 1024);

                if (filter == 'الحجم الكبـير' && sizeMB < 5.0) continue;

                mediaList.add(
                  LocalMediaFile(
                    path: entity.path,
                    name: entity.path.split('/').last,
                    sizeMB: double.parse(sizeMB.toStringAsFixed(1)),
                    isVideo: isVideo,
                    modifiedDate: entity.lastModifiedSync(),
                  ),
                );
              }
            }
          }
        } catch (_) {
          // في حال عدم وجود تصريح لمجلد معين يتخطاه بسلاسة
        }
      }
    }

    // ترتيب الملفات من الأحدث إلى الأقدم
    mediaList.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
    return mediaList;
  }

  // حذف ملف حقيقي من ذاكرة الجهاز
  static Future<bool> deleteRealFile(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
