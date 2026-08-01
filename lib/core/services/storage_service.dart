import 'package:permission_handler/permission_handler.dart';
import 'package:storage_space/storage_space.dart';

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
  // طلب تصاريح الوصول للتخزين من المستخدم
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

  // قراءة سعة التخزين الحقيقية للهاتف
  static Future<StorageInfoData> getRealStorageInfo() async {
    try {
      StorageSpace space = await getStorageSpace(
        lowScanSpace: 1024 * 1024 * 1024, // 1GB
        optimalScanSpace: 2 * 1024 * 1024 * 1024,
      );

      double totalGB = space.total / (1024 * 1024 * 1024);
      double freeGB = space.free / (1024 * 1024 * 1024);
      double usedGB = totalGB - freeGB;
      double percentage = totalGB > 0 ? (usedGB / totalGB) : 0.0;

      return StorageInfoData(
        totalSpaceGB: double.parse(totalGB.toStringAsFixed(1)),
        usedSpaceGB: double.parse(usedGB.toStringAsFixed(1)),
        freeSpaceGB: double.parse(freeGB.toStringAsFixed(1)),
        usagePercentage: percentage,
      );
    } catch (e) {
      // إرجاع قيم افتراضية في حالة عدم توفر الصلاحية بعد
      return StorageInfoData(
        totalSpaceGB: 0,
        usedSpaceGB: 0,
        freeSpaceGB: 0,
        usagePercentage: 0,
      );
    }
  }
}
