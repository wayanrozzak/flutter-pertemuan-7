
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_summary_card.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

class CourseHomePage extends StatelessWidget {
  const CourseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    final courses = courseProvider.courses;
    final favorites = courseProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Tambah Course',
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CourseFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<CourseProvider>().loadCourses(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Flutter UI Fundamentals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Wayan Muizul Rozzak'),
            const Text('NIM: 2415051111'),
            const SizedBox(height: 8),
            const Text(
              'Tahap 12: Refactoring Struktur Folder',
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Ringkasan mata kuliah dan favorit.
            Row(
              children: [
                Expanded(
                  child: CourseSummaryCard(
                    title: 'Total Mata Kuliah',
                    value: '${courses.length}',
                    icon: Icons.school,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CourseSummaryCard(
                    title: 'Mata Kuliah Favorit',
                    value: '${favorites.length}',
                    icon: Icons.favorite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Loading state.
            if (courseProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            // Error state dan tombol retry.
            else if (courseProvider.error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gagal memuat data mata kuliah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(courseProvider.error!),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<CourseProvider>()
                              .loadCourses();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )

            // Empty state.
            else if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Belum ada data mata kuliah.',
                  ),
                ),
              )

            // Daftar mata kuliah.
            else ...[
              Text(
                'Daftar Mata Kuliah (${courses.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...courses.map(
                (course) => _buildCourseCard(
                  context,
                  course,
                  courseProvider,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Course course,
    CourseProvider provider,
  ) {
    // Gunakan kode course secara konsisten untuk favorit.
    final isFavorite = provider.isFavorite(course.code);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(course.code),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Kode: ${course.code}\n'
          'SKS: ${course.credits} • Status: ${course.status}',
        ),
        isThreeLine: true,

        // Klik kartu untuk membuka halaman detail.
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

        // Tombol favorit tetap terpisah dari navigasi detail.
        trailing: IconButton(
          tooltip: isFavorite
              ? 'Hapus dari favorit'
              : 'Tambahkan ke favorit',
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
      ),
    );
  }
}
