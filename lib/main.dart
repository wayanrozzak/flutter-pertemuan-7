import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/course_home_page.dart';
import 'services/course_supabase_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';

const String apiBaseUrl =
    'https://course-api-pearl.vercel.app';

const String supabaseUrl =
    'https://trhebmvxbwyjacyokpvx.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_4_e54sjoju6DoqZr49NPhA_JzKtBdO-';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 2. Inisialisasi Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  // 3. Inisialisasi Repository dan Provider
  final dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  // 4. Menjalankan aplikasi
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(repository)..loadCourses(),
      child: const CourseExplorerApp(),
    ),
  );
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        final session = snapshot.hasData
            ? snapshot.data!.session
            : Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const CourseHomePage();
        }

        return const LoginPage();
      },
    );
  }
}
