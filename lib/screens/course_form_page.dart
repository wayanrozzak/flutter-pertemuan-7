
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();

  String _status = 'planned';

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final course = Course(
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    final provider = context.read<CourseProvider>();

    try {
      await provider.createCourse(course);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil ditambahkan.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan course: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Flutter UI Fundamentals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Wayan Muizul Rozzak'),
            const Text('NIM: 2415051111'),
            const SizedBox(height: 24),

            // Input kode course.
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Course',
                hintText: 'Contoh: IF101',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kode course wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Input judul course.
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Course',
                hintText: 'Contoh: Pemrograman Flutter',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul course wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Input credits atau SKS.
            TextFormField(
              controller: _creditsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credits / SKS',
                hintText: 'Contoh: 3',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Credits wajib diisi';
                }

                if (int.tryParse(value.trim()) == null) {
                  return 'Credits harus berupa angka bulat';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pilihan status course.
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'planned',
                  child: Text('Planned'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: 'done',
                  child: Text('Done'),
                ),
              ],
              onChanged: provider.isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 24),

            // Tombol simpan dan indikator loading.
            ElevatedButton.icon(
              onPressed: provider.isSaving ? null : _saveCourse,
              icon: provider.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                provider.isSaving
                    ? 'Menyimpan...'
                    : 'Simpan Course',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
