
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import 'course_data_source.dart';

class CourseApiService implements CourseDataSource {
  CourseApiService(
    this.baseUrl, {
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<List<Course>> getCourses() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/courses'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil course: HTTP ${response.statusCode}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    return data
        .map(
          (e) => Course.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Course.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        ),
      );
    }

    throw Exception(
      'Gagal membuat course: HTTP ${response.statusCode}',
    );
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal memperbarui course: HTTP ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/courses/$id'),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal menghapus course: HTTP ${response.statusCode}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
