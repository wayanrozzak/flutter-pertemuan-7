
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import 'course_edit_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  Future<void> _deleteCourse(BuildContext context) async {
    // Pastikan course memiliki ID untuk dihapus.
    final id = course.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course tidak memiliki ID yang valid.'),
        ),
      );
      return;
    }

    // Meminta konfirmasi sebelum menghapus.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Course?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus '
            '"${course.title}"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Periksa apakah halaman masih aktif setelah dialog ditutup.
    if (!context.mounted || confirmed != true) {
      return;
    }

    try {
      // Menghapus course melalui provider.
      await context.read<CourseProvider>().deleteCourse(
            id,
            course.code,
          );

      // Periksa kembali setelah operasi asynchronous selesai.
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course "${course.title}" berhasil dihapus.',
          ),
        ),
      );

      // Kembali ke halaman sebelumnya setelah berhasil.
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus course: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final isFavorite = provider.isFavorite(course.code);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mata Kuliah'),
        actions: [
          IconButton(
            tooltip: 'Edit Course',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseEditPage(
                    course: course,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Icon(
                  Icons.school,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              course.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _detailRow('Kode', course.code),
            _detailRow('SKS', '${course.credits} SKS'),
            _detailRow('Status', course.status),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                title: Text(
                  isFavorite
                      ? 'Sudah ditambahkan ke favorit'
                      : 'Belum menjadi favorit',
                ),
                trailing: Switch(
                  value: isFavorite,
                  onChanged: (_) {
                    context
                        .read<CourseProvider>()
                        .toggleFavorite(course.code);
                  },
                ),
                onTap: () {
                  context
                      .read<CourseProvider>()
                      .toggleFavorite(course.code);
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isSaving
                    ? null
                    : () => _deleteCourse(context),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus Course'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
