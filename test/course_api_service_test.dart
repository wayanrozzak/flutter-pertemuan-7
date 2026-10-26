
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_pertemuan_7/models/course.dart';
import 'package:flutter_pertemuan_7/services/course_api_service.dart';

void main() {
  group('CourseApiService error handling', () {
    test('menampilkan error ketika server mengembalikan HTTP 404', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/courses');
        return http.Response('Not Found', 404);
      });

      final service = CourseApiService(
        'https://example.com',
        client: client,
      );

      await expectLater(
        service.getCourses(),
        throwsA(
          predicate(
            (error) => error.toString().contains('HTTP 404'),
          ),
        ),
      );

      client.close();
    });

    test('Course.fromJson menolak credits dengan tipe data salah', () {
      final json = jsonDecode('''
        {
          "id": 1,
          "code": "IF101",
          "title": "Pengantar Informatika",
          "credits": "tiga",
          "status": "planned"
        }
      ''') as Map<String, dynamic>;

      expect(
        () => Course.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
