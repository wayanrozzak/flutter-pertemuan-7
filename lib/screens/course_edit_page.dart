
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseEditPage extends StatefulWidget {
  const CourseEditPage({
    super.key,
    required this.course,
  });

  final Course course;

  @override
  State<CourseEditPage> createState() => _CourseEditPageState();
}

class _CourseEditPageState extends State<CourseEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  late String _status;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController(
      text: widget.course.code,
    );
    _titleController = TextEditingController(
      text: widget.course.title,
    );
    _creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );

    _status = widget.course.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final id = widget.course.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Course tidak memiliki ID sehingga tidak dapat diperbarui.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedCourse = Course(
      id: id,
      code: widget.course.code,
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    final provider = context.read<CourseProvider>();

    try {
      await provider.updateCourse(id, updatedCourse);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui course: $e'),
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
        title: const Text('Edit Course'),
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

            // Kode course read-only karena menjadi kunci favorit.
            TextFormField(
              controller: _codeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Kode Course',
                border: OutlineInputBorder(),
                helperText: 'Kode course tidak dapat diubah.',
              ),
            ),
            const SizedBox(height: 16),

            // Judul course.
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Course',
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

            // Credits / SKS.
            TextFormField(
              controller: _creditsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credits / SKS',
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

            // Status course.
            DropdownButtonFormField<String>(
              initialValue: [
                'planned',
                'active',
                'done',
              ].contains(_status)
                  ? _status
                  : 'planned',
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

            // Tombol update dengan indikator loading.
            ElevatedButton.icon(
              onPressed:
                  provider.isSaving ? null : _updateCourse,
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
                    ? 'Memperbarui...'
                    : 'Simpan Perubahan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
