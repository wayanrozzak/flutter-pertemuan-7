
import '../models/course.dart';
import '../services/course_data_source.dart';

class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  // Mengambil seluruh data course.
  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  // Membuat course baru melalui HTTP POST.
  Future<Course> createCourse(Course course) {
    return dataSource.createCourse(course);
  }

  // Memperbarui course melalui HTTP PUT.
  Future<void> updateCourse(int id, Course course) {
    return dataSource.updateCourse(id, course);
  }

  // Menghapus course melalui HTTP DELETE.
  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}
