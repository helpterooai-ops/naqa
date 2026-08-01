import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// قائمة لتخزين سجلات النظام (الكونسول المدمج)
final List<String> appLogs = [];

void addLog(String message) {
  final time = DateTime.now().toIso8601String().substring(11, 19);
  appLogs.add("[$time] $message");
  debugPrint("[$time] $message"); 
}

void main() async {
  // 1. التهيئة الأساسية لفلاتر
  WidgetsFlutterBinding.ensureInitialized();

  // 2. حماية التطبيق من الانهيار والشاشة السوداء
  try {
    addLog("جاري محاولة الاتصال بخوادم Firebase...");
    await Firebase.initializeApp();
    addLog("تم الاتصال بـ Firebase بنجاح! ✅");
  } catch (e) {
    addLog("خطأ فادح في تهيئة Firebase: $e ❌");
    addLog("تأكد من وجود ملف google-services.json في مجلد android/app وتطابق applicationId");
  }

  // 3. تشغيل التطبيق دائماً لرؤية الكونسول
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدار نت'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'الكونسول',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppConsoleScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'تم تجاوز الشاشة السوداء 🎉',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppConsoleScreen()),
                );
              },
              icon: const Icon(Icons.developer_board),
              label: const Text('افتح الكونسول لمعرفة حالة Firebase'),
            )
          ],
        ),
      ),
    );
  }
}

class AppConsoleScreen extends StatelessWidget {
  const AppConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل النظام (Console)'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: appLogs.isEmpty
          ? const Center(child: Text("لا توجد سجلات حالياً"))
          : ListView.builder(
              itemCount: appLogs.length,
              itemBuilder: (context, index) {
                final log = appLogs[index];
                final isError = log.contains("خطأ") || log.contains("❌");
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    log,
                    style: TextStyle(
                      color: isError ? Colors.redAccent : Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                );
              },
            ),
    );
  }
}
