
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_pertemuan_7/providers/course_provider.dart';
import 'package:flutter_pertemuan_7/repositories/course_repository.dart';
import 'package:flutter_pertemuan_7/services/course_service.dart';
import 'package:flutter_pertemuan_7/main.dart';

void main() {
  testWidgets('Aplikasi Course Explorer berhasil dibuat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CourseProvider>(
        create: (_) => CourseProvider(
          CourseRepository(CourseService()),
        ),
        child: const CourseExplorerApp(),
      ),
    );

    expect(find.text('Flutter UI Fundamentals'), findsOneWidget);
    expect(find.text('Wayan Muizul Rozzak'), findsOneWidget);
    expect(find.text('NIM: 2415051111'), findsOneWidget);
  });
}
