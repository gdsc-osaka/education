import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reading_note/main.dart';

void main() {
  testWidgets('renders the masthead title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ReadingNoteApp()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('読書メモ'), findsOneWidget);
  });
}
