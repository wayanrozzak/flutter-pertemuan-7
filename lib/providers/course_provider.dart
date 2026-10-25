
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  final Set<String> _favorites = {};

  Set<String> get favorites => Set.unmodifiable(_favorites);

  // Memeriksa favorit berdasarkan kode mata kuliah.
  bool isFavorite(String code) {
    return _favorites.contains(code);
  }

  // Mengubah status favorit.
  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }

    notifyListeners();
  }

  // Mengambil daftar mata kuliah favorit.
  List<Course> get favoriteCourses {
    return courses
        .where((course) => _favorites.contains(course.code))
        .toList();
  }

  // Memuat daftar mata kuliah dari repository.
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan course dan memuat ulang daftar.
  Future<Course> createCourse(Course course) async {
    if (isSaving) {
      throw Exception(
        'Proses penyimpanan course sedang berlangsung.',
      );
    }

    isSaving = true;
    notifyListeners();

    try {
      final createdCourse =
          await repository.createCourse(course);

      await loadCourses();

      if (error != null) {
        throw Exception(
          'Course berhasil dibuat, tetapi daftar gagal '
          'dimuat ulang: $error',
        );
      }

      return createdCourse;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Memperbarui course dan memuat ulang daftar.
  Future<void> updateCourse(int id, Course course) async {
    if (isSaving) {
      throw Exception(
        'Proses penyimpanan course sedang berlangsung.',
      );
    }

    isSaving = true;
    notifyListeners();

    try {
      await repository.updateCourse(id, course);

      await loadCourses();

      if (error != null) {
        throw Exception(
          'Course berhasil diperbarui, tetapi daftar gagal '
          'dimuat ulang: $error',
        );
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Menghapus course berdasarkan ID dan memuat ulang daftar.
  Future<void> deleteCourse(int id, String code) async {
    if (isSaving) {
      throw Exception(
        'Proses penyimpanan course sedang berlangsung.',
      );
    }

    isSaving = true;
    notifyListeners();

    try {
      // Hapus data dari database melalui repository.
      await repository.deleteCourse(id);

      // Hapus course dari daftar favorit.
      _favorites.remove(code);

      // Muat ulang daftar dari database.
      await loadCourses();

      if (error != null) {
        throw Exception(
          'Course berhasil dihapus, tetapi daftar gagal '
          'dimuat ulang: $error',
        );
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
