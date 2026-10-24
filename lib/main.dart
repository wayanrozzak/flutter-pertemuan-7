
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/course_detail_page.dart';
import 'screens/favorites_page.dart';
import 'services/course_api_service.dart';
import 'widgets/error_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(
        CourseRepository(
          CourseApiService(
            'https://course-api-pearl.vercel.app',
          ),
        ),
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

class CourseHomePage extends StatelessWidget {
  const CourseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer'),
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
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CourseProvider provider,
  ) {
    // Loading state
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: provider.loadCourses,
      );
    }

    // Empty state
    if (provider.courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Data course belum tersedia',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Success state
    return RefreshIndicator(
      onRefresh: provider.loadCourses,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Daftar Mata Kuliah',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.courses.length} mata kuliah tersedia',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...provider.courses.map((course) {
            final isFavorite =
                provider.isFavorite(course.code);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: const Icon(Icons.menu_book),
                ),
                title: Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text('Kode: ${course.code}'),
                      Text('SKS: ${course.credits}'),
                      Text('Status: ${course.status}'),
                    ],
                  ),
                ),
                trailing: IconButton(
                  tooltip: isFavorite
                      ? 'Hapus dari favorit'
                      : 'Tambah ke favorit',
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    provider.toggleFavorite(course.code);
                  },
                ),
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
          }),
        ],
      ),
    );
  }
}
