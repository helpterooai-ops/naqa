import 'dart:io';

class LocalMediaFile {
  final String path;
  final String name;
  final double sizeMB;
  final String category;
  final DateTime modifiedDate;

  LocalMediaFile({
    required this.path,
    required this.name,
    required this.sizeMB,
    required this.category,
    required this.modifiedDate,
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
  static final List<String> _searchPaths = [
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0/Pictures',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Documents',
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
    '/storage/emulated/0/Telegram',
  ];

  static Future<List<MediaAlbum>> fetchComprehensiveAlbums() async {
    List<LocalMediaFile> allPhotos = [];
    List<LocalMediaFile> allVideos = [];
    List<LocalMediaFile> allDocs = [];
    List<LocalMediaFile> allAudio = [];

    for (String path in _searchPaths) {
      await _scanDirectory(Directory(path), allPhotos, allVideos, allDocs, allAudio, 0);
    }

    List<MediaAlbum> result = [];

    if (allPhotos.isNotEmpty) {
      double size = allPhotos.fold(0, (sum, item) => sum + item.sizeMB);
      result.add(MediaAlbum(id: 'photos', title: 'جميع الصور', iconType: 'photo', itemCount: allPhotos.length, totalSizeMB: double.parse(size.toStringAsFixed(1)), files: allPhotos));
    }
    if (allVideos.isNotEmpty) {
      double size = allVideos.fold(0, (sum, item) => sum + item.sizeMB);
      result.add(MediaAlbum(id: 'videos', title: 'مقاطع الفيديو', iconType: 'video', itemCount: allVideos.length, totalSizeMB: double.parse(size.toStringAsFixed(1)), files: allVideos));
    }
    if (allDocs.isNotEmpty) {
      double size = allDocs.fold(0, (sum, item) => sum + item.sizeMB);
      result.add(MediaAlbum(id: 'docs', title: 'المستندات والملفات', iconType: 'doc', itemCount: allDocs.length, totalSizeMB: double.parse(size.toStringAsFixed(1)), files: allDocs));
    }
    if (allAudio.isNotEmpty) {
      double size = allAudio.fold(0, (sum, item) => sum + item.sizeMB);
      result.add(MediaAlbum(id: 'audio', title: 'الصوتيات', iconType: 'audio', itemCount: allAudio.length, totalSizeMB: double.parse(size.toStringAsFixed(1)), files: allAudio));
    }

    return result;
  }

  static Future<void> _scanDirectory(Directory dir, List<LocalMediaFile> photos, List<LocalMediaFile> videos, List<LocalMediaFile> docs, List<LocalMediaFile> audio, int depth) async {
    if (depth > 3) return;
    try {
      if (await dir.exists()) {
        List<FileSystemEntity> entities = dir.listSync(recursive: false, followLinks: false);
        for (var entity in entities) {
          if (entity is Directory) {
            String dirName = entity.path.split('/').last.toLowerCase();
            if (!dirName.startsWith('.')) {
              await _scanDirectory(entity, photos, videos, docs, audio, depth + 1);
            }
          } else if (entity is File) {
            _categorizeFile(entity, photos, videos, docs, audio);
          }
        }
      }
    } catch (_) {}
  }

  static void _categorizeFile(File file, List<LocalMediaFile> photos, List<LocalMediaFile> videos, List<LocalMediaFile> docs, List<LocalMediaFile> audio) {
    String path = file.path;
    String lower = path.toLowerCase();
    
    try {
      int len = file.lengthSync();
      if (len == 0) return;
      double mb = len / (1024 * 1024);
      DateTime date = file.lastModifiedSync();
      String name = path.split('/').last;

      if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp')) {
        photos.add(LocalMediaFile(path: path, name: name, sizeMB: double.parse(mb.toStringAsFixed(1)), category: 'image', modifiedDate: date));
      } else if (lower.endsWith('.mp4') || lower.endsWith('.mkv') || lower.endsWith('.mov')) {
        videos.add(LocalMediaFile(path: path, name: name, sizeMB: double.parse(mb.toStringAsFixed(1)), category: 'video', modifiedDate: date));
      } else if (lower.endsWith('.pdf') || lower.endsWith('.doc') || lower.endsWith('.docx') || lower.endsWith('.apk') || lower.endsWith('.zip')) {
        docs.add(LocalMediaFile(path: path, name: name, sizeMB: double.parse(mb.toStringAsFixed(1)), category: 'document', modifiedDate: date));
      } else if (lower.endsWith('.mp3') || lower.endsWith('.m4a') || lower.endsWith('.wav') || lower.endsWith('.opus')) {
        audio.add(LocalMediaFile(path: path, name: name, sizeMB: double.parse(mb.toStringAsFixed(1)), category: 'audio', modifiedDate: date));
      }
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
