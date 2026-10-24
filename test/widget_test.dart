
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_pertemuan_7/providers/course_provider.dart';
import 'package:flutter_pertemuan_7/repositories/course_repository.dart';
import 'package:flutter_pertemuan_7/services/course_api_service.dart';
import 'package:flutter_pertemuan_7/main.dart';

void main() {
  testWidgets('Aplikasi Course Explorer berhasil dibuat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CourseProvider>(
        create: (_) => CourseProvider(
          CourseRepository(
            CourseApiService(
              'https://course-api-pearl.vercel.app',
            ),
          ),
        ),
        child: const CourseExplorerApp(),
      ),
    );

    expect(find.text('Course Explorer'), findsOneWidget);
  });
}
