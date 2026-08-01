import 'package:flutter/material.dart';
import 'package:aether_file/core/constants/app_colors.dart';
import 'package:aether_file/core/widgets/glass_container.dart';

class JunkScannerScreen extends StatefulWidget {
  const JunkScannerScreen({super.key});

  @override
  State<JunkScannerScreen> createState() => _JunkScannerScreenState();
}

class _JunkScannerScreenState extends State<JunkScannerScreen> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isScanning = false);
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
        title: const Text('تنظيف مخلفات النظام', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 18, color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: _isScanning
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 20),
                  Text('جاري فحص الملفات المؤقتة...', style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white70)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cleaning_services_rounded, color: AppColors.accent, size: 64),
                      const SizedBox(height: 20),
                      const Text('تم العثور على ملفات مؤقتة', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 10),
                      const Text('450 MB', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.rubyDelete)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('تنظيف الآن', style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
