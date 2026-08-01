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

class MediaAlbum {
  final String id;
  final String title;
  final String path;
  final int itemCount;
  final double totalSizeMB;
  final List<LocalMediaFile> files;

  MediaAlbum({
    required this.id,
    required this.title,
    required this.path,
    required this.itemCount,
    required this.totalSizeMB,
    required this.files,
  });
}

class MediaService {
  static final Map<String, List<String>> _albumFolderPaths = {
    'screenshots': [
      '/storage/emulated/0/Pictures/Screenshots',
      '/storage/emulated/0/DCIM/Screenshots',
    ],
    'camera': [
      '/storage/emulated/0/DCIM/Camera',
    ],
    'whatsapp': [
      '/storage/emulated/0/Pictures/WhatsApp',
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images',
    ],
    'downloads': [
      '/storage/emulated/0/Download',
    ],
    'pictures': [
      '/storage/emulated/0/Pictures',
    ],
  };

  static Future<List<MediaAlbum>> fetchRealAlbums() async {
    List<MediaAlbum> albums = [];

    var screenshots = await _scanFolders('screenshots', 'لقطات الشاشة', _albumFolderPaths['screenshots']!);
    if (screenshots.files.isNotEmpty) albums.add(screenshots);

    var camera = await _scanFolders('camera', 'صور الكاميرا', _albumFolderPaths['camera']!);
    if (camera.files.isNotEmpty) albums.add(camera);

    var whatsapp = await _scanFolders('whatsapp', 'صور الواتساب', _albumFolderPaths['whatsapp']!);
    if (whatsapp.files.isNotEmpty) albums.add(whatsapp);

    var downloads = await _scanFolders('downloads', 'التحميلات', _albumFolderPaths['downloads']!);
    if (downloads.files.isNotEmpty) albums.add(downloads);

    var pictures = await _scanFolders('pictures', 'جميع الصور', _albumFolderPaths['pictures']!);
    if (pictures.files.isNotEmpty) albums.add(pictures);

    List<LocalMediaFile> largeFiles = [];
    double largeTotalMB = 0;
    for (var album in albums) {
      for (var file in album.files) {
        if (file.sizeMB >= 10.0) {
          largeFiles.add(file);
          largeTotalMB += file.sizeMB;
        }
      }
    }
    if (largeFiles.isNotEmpty) {
      albums.insert(
        0,
        MediaAlbum(
          id: 'large',
          title: 'الملفات الكبيرة (+10MB)',
          path: 'large_files',
          itemCount: largeFiles.length,
          totalSizeMB: double.parse(largeTotalMB.toStringAsFixed(1)),
          files: largeFiles,
        ),
      );
    }

    return albums;
  }

  static Future<MediaAlbum> _scanFolders(String id, String title, List<String> paths) async {
    List<LocalMediaFile> files = [];
    double totalMB = 0;

    for (String path in paths) {
      Directory dir = Directory(path);
      if (await dir.exists()) {
        try {
          await for (FileSystemEntity entity in dir.list(recursive: false, followLinks: false)) {
            if (entity is File) {
              String filePath = entity.path;
              String lower = filePath.toLowerCase();

              bool isImage = lower.endsWith('.jpg') ||
                  lower.endsWith('.jpeg') ||
                  lower.endsWith('.png') ||
                  lower.endsWith('.webp');

              bool isVideo = lower.endsWith('.mp4') ||
                  lower.endsWith('.mkv') ||
                  lower.endsWith('.mov');

              if (isImage || isVideo) {
                try {
                  int bytes = entity.lengthSync();
                  double size = bytes / (1024 * 1024);
                  totalMB += size;

                  files.add(LocalMediaFile(
                    path: filePath,
                    name: filePath.split('/').last,
                    sizeMB: double.parse(size.toStringAsFixed(1)),
                    isVideo: isVideo,
                    modifiedDate: entity.lastModifiedSync(),
                  ));
                } catch (_) {}
              }
            }
            if (files.length >= 150) break;
          }
        } catch (_) {}
      }
    }

    files.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

    return MediaAlbum(
      id: id,
      title: title,
      path: paths.first,
      itemCount: files.length,
      totalSizeMB: double.parse(totalMB.toStringAsFixed(1)),
      files: files,
    );
  }

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
