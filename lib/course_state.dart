
import 'package:flutter/foundation.dart';

import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_api_service.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository _courseRepository = CourseRepository(
    CourseApiService(
      'https://course-api-pearl.vercel.app',
    ),
  );

  List<Course> _courses = [];
  final Set<String> _favorites = {};
  bool _isLoading = true;
  String? _errorMessage;

  CourseState() {
    loadCourses();
  }

  List<Course> get courses => List.unmodifiable(_courses);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _courseRepository.getCourses();
    } catch (e) {
      _errorMessage = 'Gagal memuat data course: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String courseTitle) {
    return _favorites.contains(courseTitle);
  }

  void toggleFavorite(String courseTitle) {
    if (_favorites.contains(courseTitle)) {
      _favorites.remove(courseTitle);
    } else {
      _favorites.add(courseTitle);
    }

    notifyListeners();
  }
}
