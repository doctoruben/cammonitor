import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:convert';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'models/camera_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const CamMonitorApp());
}

class CamMonitorApp extends StatelessWidget {
  const CamMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamMonitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E5FF),
          secondary: const Color(0xFF00B4CC),
          surface: const Color(0xFF0D1318),
          background: const Color(0xFF080C10),
        ),
        scaffoldBackgroundColor: const Color(0xFF080C10),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1017),
          foregroundColor: Color(0xFF00E5FF),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CameraModel> cameras = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadCameras();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _loadCameras() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cameras');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        cameras = list.map((e) => CameraModel.fromJson(e)).toList();
      });
    } else {
      // Default cameras with real IPs
      setState(() {
        cameras = [
          CameraModel(name: 'ENTRADA', url: 'rtsp://admin:123456@192.168.68.114:554/live/ch00_0'),
          CameraModel(name: 'SALON',   url: 'rtsp://admin:123456@192.168.68.117:554/live/ch00_0'),
          CameraModel(name: 'GARAJE',  url: 'rtsp://admin:123456@192.168.68.100:554/live/ch00_0'),
          CameraModel(name: 'JARDIN',  url: 'rtsp://admin:123456@192.168.68.112:554/live/ch00_0'),
        ];
      });
      _saveCameras();
    }
  }

  Future<void> _saveCameras() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cameras', jsonEncode(cameras.map((c) => c.toJson()).toList()));
  }

  void _onCamerasChanged(List<CameraModel> updated) {
    setState(() => cameras = updated);
    _saveCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(cameras: cameras),
          SettingsScreen(cameras: cameras, onChanged: _onCamerasChanged),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1A2A35))),
          color: Color(0xFF0A1017),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: const Color(0xFF4A6572),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam),
              label: 'Cámaras',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configurar',
            ),
          ],
        ),
      ),
    );
  }
}
