import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pertemuan_7/main.dart';

void main() {
  testWidgets('Aplikasi KosFinder berhasil dibuat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KosFinderApp());
    expect(find.byType(KosFinderApp), findsOneWidget);
  });
}
