
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/course_detail_page.dart';
import 'screens/favorites_page.dart';
import 'services/course_service.dart';

const String studentName = 'Wayan Muizul Rozzak';
const String studentId = '2415051111';

// Menguji pemetaan respons REST API menjadi List<Course>.
Future<void> testFetchCourses() async {
  try {
    final List<Course> courses =
        await CourseService().loadCourses();

    debugPrint(
      'REST API berhasil: ${courses.length} course ditemukan.',
    );

    for (final course in courses.take(3)) {
      debugPrint(
        'Kode: ${course.code} | '
        'Judul: ${course.title} | '
        'Status: ${course.status}',
      );
    }
  } catch (error) {
    debugPrint('Pengujian REST API gagal: $error');
  }
}

void main() {
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
            tooltip: 'Muat Ulang Data',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CourseProvider>().loadCourses();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('NIM: $studentId'),
                    const SizedBox(height: 12),
                    const Text('Tahap 3: Model dan JSON Mapping'),
                  ],
                ),
              ),
            ),
          ),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Mata Kuliah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildCourseList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(
    BuildContext context,
    CourseProvider state,
  ) {
    if (state.isLoading && state.courses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat mata kuliah:\n${state.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
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

    if (state.courses.isEmpty) {
      return const Center(
        child: Text('Belum ada mata kuliah.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: state.courses.length,
      itemBuilder: (context, index) {
        final course = state.courses[index];
        final isFavorite = state.isFavorite(course.code);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.school),
            ),
            title: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${course.code} • ${course.credits} SKS\n'
              'Status: ${course.status}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: isFavorite
                  ? 'Hapus dari Favorit'
                  : 'Tambahkan ke Favorit',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                context
                    .read<CourseProvider>()
                    .toggleFavorite(course.code);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailPage(course: course),
                ),
              );
            },
          ),
        );
      },
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge,
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
