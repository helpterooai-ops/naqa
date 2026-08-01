import 'dart:io';

class LocalMediaFile {
  final String path;
  final String name;
  final double sizeMB;
  final String category; // 'image', 'video', 'document', 'audio', 'apk'
  final DateTime modifiedDate;
  final String sourceApp;
  bool isLocked; // التثبيت بالحفل الأخضر

  LocalMediaFile({
    required this.path,
    required this.name,
    required this.sizeMB,
    required this.category,
    required this.modifiedDate,
    required this.sourceApp,
    this.isLocked = false,
  });
}

class MediaAlbum {
  final String id;
  final String title;
  final String iconType;
  final int itemCount;
  final double totalSizeMB;
  final List<LocalMediaFile> files;

  MediaAlbum({
    required this.id,
    required this.title,
    required this.iconType,
    required this.itemCount,
    required this.totalSizeMB,
    required this.files,
  });
}

class MediaService {
  static final Map<String, List<Map<String, String>>> _folderConfigs = {
    'photos': [
      {'path': '/storage/emulated/0/Pictures/Screenshots', 'app': 'لقطات الشاشة'},
      {'path': '/storage/emulated/0/DCIM/Screenshots', 'app': 'لقطات الشاشة'},
      {'path': '/storage/emulated/0/DCIM/Camera', 'app': 'الكاميرا'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images', 'app': 'واتساب الرسمي'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/WhatsApp Images', 'app': 'واتساب الأعمال'},
      {'path': '/storage/emulated/0/Telegram/Telegram Images', 'app': 'تيليجرام'},
      {'path': '/storage/emulated/0/Pictures/Instagram', 'app': 'إنستغرام'},
      {'path': '/storage/emulated/0/Download', 'app': 'التحميلات'},
      {'path': '/storage/emulated/0/Pictures', 'app': 'صور متنوعة'},
    ],
    'videos': [
      {'path': '/storage/emulated/0/DCIM/Camera', 'app': 'الكاميرا'},
      {'path': '/storage/emulated/0/DCIM/ScreenRecorder', 'app': 'تسجيل الشاشة'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video', 'app': 'فيديو واتساب'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/WhatsApp Video', 'app': 'فيديو واتساب الأعمال'},
      {'path': '/storage/emulated/0/Telegram/Telegram Video', 'app': 'فيديو تيليجرام'},
      {'path': '/storage/emulated/0/Download', 'app': 'التحميلات'},
    ],
    'docs': [
      {'path': '/storage/emulated/0/Download', 'app': 'المستندات المحملة'},
      {'path': '/storage/emulated/0/Documents', 'app': 'المستندات المحفوظة'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents', 'app': 'مستندات واتساب'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/WhatsApp Documents', 'app': 'مستندات واتساب الأعمال'},
    ],
    'audio': [
      {'path': '/storage/emulated/0/Music', 'app': 'الموسيقى'},
      {'path': '/storage/emulated/0/Download', 'app': 'صوتيات التحميل'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes', 'app': 'بصمات واتساب'},
      {'path': '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio', 'app': 'صوتيات واتساب'},
    ],
  };

  static Future<List<MediaAlbum>> fetchComprehensiveAlbums() async {
    List<MediaAlbum> result = [];

    var photoAlbum = await _scanCategory('photos', 'الصور والألبومات', 'photo');
    if (photoAlbum.files.isNotEmpty) result.add(photoAlbum);

    var videoAlbum = await _scanCategory('videos', 'مقاطع الفيديو', 'video');
    if (videoAlbum.files.isNotEmpty) result.add(videoAlbum);

    var docsAlbum = await _scanCategory('docs', 'المستندات و PDF', 'doc');
    if (docsAlbum.files.isNotEmpty) result.add(docsAlbum);

    var audioAlbum = await _scanCategory('audio', 'الصوتيات والبصمات', 'audio');
    if (audioAlbum.files.isNotEmpty) result.add(audioAlbum);

    List<LocalMediaFile> allLarge = [];
    double largeMB = 0;
    for (var alb in result) {
      for (var f in alb.files) {
        if (f.sizeMB >= 10.0) {
          allLarge.add(f);
          largeMB += f.sizeMB;
        }
      }
    }
    if (allLarge.isNotEmpty) {
      result.insert(
        0,
        MediaAlbum(
          id: 'large_files',
          title: 'الملفات الكبيرة وتراكمات الذاكرة (+10MB)',
          iconType: 'large',
          itemCount: allLarge.length,
          totalSizeMB: double.parse(largeMB.toStringAsFixed(1)),
          files: allLarge,
        ),
      );
    }

    return result;
  }

  static Future<MediaAlbum> _scanCategory(String categoryKey, String title, String iconType) async {
    List<LocalMediaFile> files = [];
    double totalMB = 0;
    var configList = _folderConfigs[categoryKey] ?? [];

    for (var config in configList) {
      String folderPath = config['path']!;
      String appSource = config['app']!;
      Directory dir = Directory(folderPath);

      if (await dir.exists()) {
        try {
          await for (FileSystemEntity entity in dir.list(recursive: false, followLinks: false)) {
            if (entity is File) {
              String path = entity.path;
              String lower = path.toLowerCase();

              bool isImg = lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp');
              bool isVid = lower.endsWith('.mp4') || lower.endsWith('.mkv') || lower.endsWith('.mov') || lower.endsWith('.3gp');
              bool isDoc = lower.endsWith('.pdf') || lower.endsWith('.doc') || lower.endsWith('.docx') || lower.endsWith('.txt') || lower.endsWith('.xlsx');
              bool isAud = lower.endsWith('.mp3') || lower.endsWith('.m4a') || lower.endsWith('.ogg') || lower.endsWith('.opus') || lower.endsWith('.wav');
              bool isApk = lower.endsWith('.apk') || lower.endsWith('.zip') || lower.endsWith('.rar');

              String detectedCategory = 'other';
              if (isImg) detectedCategory = 'image';
              else if (isVid) detectedCategory = 'video';
              else if (isDoc) detectedCategory = 'document';
              else if (isAud) detectedCategory = 'audio';
              else if (isApk) detectedCategory = 'apk';

              if (categoryKey == 'photos' && isImg) {
                _addFileToList(entity, path, detectedCategory, appSource, files, (sz) => totalMB += sz);
              } else if (categoryKey == 'videos' && isVid) {
                _addFileToList(entity, path, detectedCategory, appSource, files, (sz) => totalMB += sz);
              } else if (categoryKey == 'docs' && (isDoc || isApk)) {
                _addFileToList(entity, path, detectedCategory, appSource, files, (sz) => totalMB += sz);
              } else if (categoryKey == 'audio' && isAud) {
                _addFileToList(entity, path, detectedCategory, appSource, files, (sz) => totalMB += sz);
              }
            }
            if (files.length >= 250) break;
          }
        } catch (_) {}
      }
    }

    files.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

    return MediaAlbum(
      id: categoryKey,
      title: title,
      iconType: iconType,
      itemCount: files.length,
      totalSizeMB: double.parse(totalMB.toStringAsFixed(1)),
      files: files,
    );
  }

  static void _addFileToList(
    File entity,
    String path,
    String category,
    String sourceApp,
    List<LocalMediaFile> list,
    Function(double) onSize,
  ) {
    try {
      int len = entity.lengthSync();
      double mb = len / (1024 * 1024);
      onSize(mb);
      list.add(LocalMediaFile(
        path: path,
        name: path.split('/').last,
        sizeMB: double.parse(mb.toStringAsFixed(1)),
        category: category,
        modifiedDate: entity.lastModifiedSync(),
        sourceApp: sourceApp,
        isLocked: false,
      ));
    } catch (_) {}
  }

  static Future<bool> deleteRealFile(String filePath) async {
    try {
      File f = File(filePath);
      if (await f.exists()) {
        await f.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
