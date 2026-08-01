import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// سنضيف لاحقاً استيراد firebase_options.dart بعد التأكد من وجوده

void main() async {
  // تأكد من تهيئة Flutter قبل تشغيل Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase (حالياً بدون خيارات منصة)
  await Firebase.initializeApp();

  runApp(const AldarNetApp());
}

class AldarNetApp extends StatelessWidget {
  const AldarNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الدار نت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'IBMPlexSansArabic',
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Firebase متصل ✅',
            style: TextStyle(fontSize: 24, color: Colors.green),
          ),
        ),
      ),
    );
  }
}