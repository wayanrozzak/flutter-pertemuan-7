
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'screens/course_detail_page.dart';
import 'screens/favorites_page.dart';

const String studentName = 'Wayan Muizul Rozzak';
const String studentId = '2415051111';

// Endpoint REST API untuk praktikum Tahap 2.
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';
// Fungsi HTTP GET sementara untuk Tahap 2.
// Pada Tahap 4, fungsi ini akan dipindahkan ke service.
Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  debugPrint('HTTP GET URL: $apiUrl');
  debugPrint('HTTP status code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final courses = jsonDecode(response.body) as List<dynamic>;
    debugPrint('Jumlah course dari HTTP GET: ${courses.length}');
    return courses;
  }

  throw Exception('HTTP ${response.statusCode}');
}

// Menguji HTTP GET dan menampilkan hasilnya di Debug Console.
Future<void> testFetchCourses() async {
  try {
    final courses = await fetchCourses();
    debugPrint('HTTP GET berhasil: ${courses.length} course ditemukan.');
  } catch (error) {
    debugPrint('HTTP GET gagal: $error');
  }
}

void main() {
  // Pemanggilan sementara untuk bukti praktikum Tahap 2.
  testFetchCourses();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(
        CourseRepository(CourseService()),
      )..loadCourses(),
      child: const CourseExplorerApp(),
    ),
  );
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Fundamentals',
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

class CourseHomePage extends StatelessWidget {
  const CourseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Fundamentals'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mata Kuliah Favorit',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: state.isLoading
                ? null
                : () {
                    context.read<CourseProvider>().loadCourses();
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Identitas mahasiswa dan informasi tahap.
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('NIM: $studentId'),
                  SizedBox(height: 12),
                  Text(
                    'Tahap 2: HTTP GET dari Flutter',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Ringkasan jumlah mata kuliah dan favorit.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.menu_book,
                      title: 'Mata Kuliah',
                      value: state.courses.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.favorite,
                      title: 'Favorit',
                      value: state.favorites.length.toString(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Daftar Mata Kuliah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _buildCourseContent(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent(
    BuildContext context,
    CourseProvider state,
  ) {
    // Kondisi loading.
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data mata kuliah...'),
          ],
        ),
      );
    }

    // Kondisi error.
    if (state.error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<CourseProvider>().loadCourses();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Kondisi data kosong.
    if (state.courses.isEmpty) {
      return const Center(
        child: Text('Belum ada data mata kuliah.'),
      );
    }

    // Daftar mata kuliah.
    return RefreshIndicator(
      onRefresh: () {
        return context.read<CourseProvider>().loadCourses();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          final isFavorite = state.isFavorite(course.code);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.school),
              ),
              title: Text(
                course.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${course.code} • ${course.credits} SKS'
                  '\nStatus: ${course.status}',
                ),
              ),
              isThreeLine: true,

              // Toggle favorit menggunakan course.code.
              trailing: IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambahkan ke favorit',
                onPressed: () {
                  context
                      .read<CourseProvider>()
                      .toggleFavorite(course.code);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),

              // Buka halaman detail.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailPage(
                      course: course,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
