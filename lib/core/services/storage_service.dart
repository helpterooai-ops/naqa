import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageInfoData {
  final double totalSpaceGB;
  final double usedSpaceGB;
  final double freeSpaceGB;
  final double usagePercentage;

  StorageInfoData({
    required this.totalSpaceGB,
    required this.usedSpaceGB,
    required this.freeSpaceGB,
    required this.usagePercentage,
  });
}

class StorageService {
  // إنشاء كائن المكتبة للاستخدام
  static final DiskSpacePlus _diskSpacePlus = DiskSpacePlus();

  // طلب تصاريح الوصول للتخزين والصور من أندرويد
  static Future<bool> requestStoragePermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
      Permission.manageExternalStorage,
    ].request();

    return statuses[Permission.storage]?.isGranted == true ||
        statuses[Permission.photos]?.isGranted == true ||
        statuses[Permission.manageExternalStorage]?.isGranted == true;
  }

  // قراءة ذاكرة الهاتف الحقيقية وتحويلها إلى جيجابايت
  static Future<StorageInfoData> getRealStorageInfo() async {
    try {
      // استدعاء الدوال من كائن المكتبة
      double? freeMB = await _diskSpacePlus.getFreeDiskSpace();
      double? totalMB = await _diskSpacePlus.getTotalDiskSpace();

      if (totalMB != null && freeMB != null && totalMB > 0) {
        double totalGB = totalMB / 1024.0;
        double freeGB = freeMB / 1024.0;
        double usedGB = totalGB - freeGB;
        double percentage = usedGB / totalGB;

        return StorageInfoData(
          totalSpaceGB: double.parse(totalGB.toStringAsFixed(1)),
          usedSpaceGB: double.parse(usedGB.toStringAsFixed(1)),
          freeSpaceGB: double.parse(freeGB.toStringAsFixed(1)),
          usagePercentage: percentage.clamp(0.0, 1.0),
        );
      }
    } catch (_) {}

    return StorageInfoData(
      totalSpaceGB: 0,
      usedSpaceGB: 0,
      freeSpaceGB: 0,
      usagePercentage: 0,
    );
  }
}
