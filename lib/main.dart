import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tododo/services/notification_service.dart';
import 'auth/auth_service.dart';
import 'auth/auth_page.dart';
import 'pages/dashboard_pages.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://vurrrsixronhxfwewoxc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1cnJyc2l4cm9uaHhmd2V3b3hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgxMjI0NjgsImV4cCI6MjA1MzY5ODQ2OH0.dw3w7DC8npfyZA_JnFIKO1srbxDwiWGQXviGWACYAas',
  );

  await NotificationService.init();
  // Inisialisasi Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(
      'Asia/Jakarta')); // Sesuaikan dengan timezone yang diperlukan

  final supabase = Supabase.instance.client;
  final authService = AuthService(supabase: supabase);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TodoDo',
      theme: ThemeData(
        primarySwatch:
            Colors.blueGrey, // Bisa diganti jika masih ada warna ungu
        colorScheme: ColorScheme.light(
          primary: Color(0xFF5FB2FF), // Warna utama untuk tombol
          background: Color(0xFFBDE0FE), // Warna background utama
          surface: Color(0xFFA2D2FF), // Warna untuk card atau pop-up
          onPrimary: Colors.white, // Warna teks di atas warna utama
          onBackground: Colors.black, // Warna teks utama agar tidak ungu
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF5FB2FF), // Warna app bar
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // Warna teks app bar
          ),
        ),
      ),
      home: AuthStateHandler(authService: authService),
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  final AuthService authService;

  const AuthStateHandler({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final supabase = Supabase.instance.client;
    return session != null
        ? DashboardPage(authService: authService, supabase: supabase)
        : AuthPage(authService: authService);
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
