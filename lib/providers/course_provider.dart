
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  final Set<String> _favorites = {};

  Set<String> get favorites => Set.unmodifiable(_favorites);

  // Memeriksa favorit berdasarkan kode mata kuliah.
  bool isFavorite(String code) {
    return _favorites.contains(code);
  }

  // Mengubah status favorit dan memberi tahu semua screen.
  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }

    notifyListeners();
  }

  // Mengambil daftar mata kuliah yang menjadi favorit.
  List<Course> get favoriteCourses {
    return courses
        .where((course) => _favorites.contains(course.code))
        .toList();
  }

  // Memuat data serta menangani loading, success, dan error.
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
}
