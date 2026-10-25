
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/course_home_page.dart';
import 'services/course_api_service.dart';

const String apiBaseUrl =
    'https://course-api-pearl.vercel.app';

const String supabaseUrl =
    'https://ftbpxopkphlgbbtomxz.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_jhq_TcHdcM7lgrXcqSxvTA_F9G-ZKxZ';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  final dataSource = CourseApiService(apiBaseUrl);
  final repository = CourseRepository(dataSource);

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
      home: const CourseHomePage(),
    );
  }
}
