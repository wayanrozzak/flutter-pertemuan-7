
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  CourseSupabaseService();

  final supabase = Supabase.instance.client;

  // Mengambil ID user yang sedang login.
  String get _currentUserId {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    return user.id;
  }

  // Memeriksa identitas user yang sedang login.
  void debugCurrentUser() {
    final user = supabase.auth.currentUser;

    debugPrint('========== DEBUG CURRENT USER ==========');
    debugPrint('LOGIN EMAIL: ${user?.email}');
    debugPrint('LOGIN USER ID: ${user?.id}');
    debugPrint('=========================================');
  }

  // Mengambil seluruh data course.
  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map(
          (e) => Course.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  // Menambahkan course dengan owner_id user yang login.
  @override
  Future<Course> createCourse(Course course) async {
    debugCurrentUser();

    final ownerId = _currentUserId;

    debugPrint('OWNER ID YANG DIKIRIM: $ownerId');

    final row = await supabase
        .from('courses')
        .insert({
          ...course.toJson(),
          'owner_id': ownerId,
        })
        .select()
        .single();

    debugPrint('INSERT COURSE BERHASIL');

    return Course.fromJson(
      Map<String, dynamic>.from(row),
    );
  }

  // Mengubah course milik sendiri.
  @override
  Future<void> updateCourse(int id, Course course) async {
    final rows = await supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id)
        .select();

    if (rows.isEmpty) {
      throw Exception(
        'Update ditolak: course bukan milik Anda '
        'atau data tidak ditemukan.',
      );
    }

    debugPrint('UPDATE COURSE BERHASIL: $id');
  }

  // Menghapus course milik sendiri.
  @override
  Future<void> deleteCourse(int id) async {
    final rows = await supabase
        .from('courses')
        .delete()
        .eq('id', id)
        .select();

    if (rows.isEmpty) {
      throw Exception(
        'Delete ditolak: course bukan milik Anda '
        'atau data tidak ditemukan.',
      );
    }

    debugPrint('DELETE COURSE BERHASIL: $id');
  }
}
