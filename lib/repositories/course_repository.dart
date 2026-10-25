
import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  // Mengambil seluruh data course
  Future<List<Course>> getCourses() {
    return service.getCourses();
  }

  // Membuat course baru melalui HTTP POST
  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }
}
