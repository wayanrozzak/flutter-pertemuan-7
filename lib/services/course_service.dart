
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseService {
  static const String baseUrl =
      'https://course-api-pearl.vercel.app';

  Future<List<Course>> loadCourses() async {
    final uri = Uri.parse('$baseUrl/courses');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => Course.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Gagal memuat mata kuliah. HTTP ${response.statusCode}',
    );
  }
}
