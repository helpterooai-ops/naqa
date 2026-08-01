import 'dart:io';
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
  static Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.photos,
        Permission.videos,
        Permission.manageExternalStorage,
      ].request();
    }
  }

  // دالة تحويل مساحة النظام إلى مساحة الهاردوير الحقيقية المعروفة
  static double _normalizeTotalSize(double rawTotalGB) {
    if (rawTotalGB <= 32) return 32.0;
    if (rawTotalGB <= 64) return 64.0;
    if (rawTotalGB <= 128) return 128.0;
    if (rawTotalGB <= 256) return 256.0;
    if (rawTotalGB <= 512) return 512.0;
    if (rawTotalGB <= 1024) return 1024.0;
    return rawTotalGB;
  }

  static Future<StorageInfoData> getRealStorageInfo() async {
    try {
      final diskSpace = DiskSpacePlus();
      double? freeMB = await diskSpace.getFreeDiskSpace;
      double? totalMB = await diskSpace.getTotalDiskSpace;

      if (totalMB != null && freeMB != null && totalMB > 0) {
        double rawTotalGB = totalMB / 1024;
        double rawFreeGB = freeMB / 1024;
        
        double hardwareTotalGB = _normalizeTotalSize(rawTotalGB);
        double actualUsedGB = (hardwareTotalGB - rawFreeGB).clamp(0.0, hardwareTotalGB);
        double percentage = (actualUsedGB / hardwareTotalGB).clamp(0.0, 1.0);

        return StorageInfoData(
          totalSpaceGB: double.parse(hardwareTotalGB.toStringAsFixed(1)),
          usedSpaceGB: double.parse(actualUsedGB.toStringAsFixed(1)),
          freeSpaceGB: double.parse(rawFreeGB.toStringAsFixed(1)),
          usagePercentage: percentage,
        );
      }
    } catch (_) {}

    return StorageInfoData(
      totalSpaceGB: 256.0,
      usedSpaceGB: 0.0,
      freeSpaceGB: 256.0,
      usagePercentage: 0.0,
    );
  }
}
