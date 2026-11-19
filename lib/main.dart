import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cloud_config.dart';
import 'pages/device_demo_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Registrasi eksplisit untuk platform Windows Desktop
  // mencegah MissingPluginException pada getApplicationDocumentsDirectory & SharedPreferences
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    PathProviderWindows.registerWith();
    SharedPreferencesWindows.registerWith();
  }

  // Mode lokal dapat berjalan tanpa project / akun Supabase.
  if (CloudConfig.enabled) {
    await Supabase.initialize(
      url: CloudConfig.url,
      publishableKey: CloudConfig.publishableKey,
    );
  }

  runApp(const KosFinderDeviceApp());
}

class KosFinderDeviceApp extends StatelessWidget {
  const KosFinderDeviceApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KosFinder - Device Demo',
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const DeviceDemoPage(),
      );
}
