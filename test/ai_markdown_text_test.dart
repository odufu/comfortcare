import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comfort_care/features/clinical/presentation/widgets/ai_markdown_text.dart';

void main() {
  group('AiMarkdownText Parsing & Rendering Tests', () {
    testWidgets('Renders plain paragraphs correctly without markdown symbols', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiMarkdownText(
              text: 'Good afternoon, Joel. I am here to assist you.',
            ),
          ),
        ),
      );

      expect(find.byType(AiMarkdownText), findsOneWidget);
      expect(find.textContaining('Good afternoon, Joel.'), findsOneWidget);
    });

    testWidgets('Parses and bolds **bold text** while stripping raw asterisks', (tester) async {
      const sample = 'For quick relief, I recommend **Panadol Extra Tablets** with water.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiMarkdownText(
              text: sample,
            ),
          ),
        ),
      );

      // Verify that raw ** is NOT in any rendered text
      expect(find.textContaining('**'), findsNothing);
      expect(find.textContaining('Panadol Extra Tablets'), findsOneWidget);

      // Find Text widget and verify TextSpan has bold styling
      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);

      bool foundBoldSpan = false;
      for (final element in textFinder.evaluate()) {
        final textWidget = element.widget as Text;
        textWidget.textSpan?.visitChildren((span) {
          if (span is TextSpan &&
              span.text == 'Panadol Extra Tablets' &&
              span.style?.fontWeight == FontWeight.w700) {
            foundBoldSpan = true;
          }
          return true;
        });
      }
      expect(foundBoldSpan, isTrue);
    });

    testWidgets('Renders bullet points and sub-bullets with bullet indicators', (tester) async {
      const sample = '''
* **Panadol Extra Tablets** (Paracetamol 500mg)
  * Dosage: Take two tablets with water.
  * Price: ₦1850 for 10 blister packs.
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiMarkdownText(
              text: sample,
            ),
          ),
        ),
      );

      // Raw bullet asterisk should be stripped from rendered text spans
      expect(find.textContaining('* **'), findsNothing);
      expect(find.textContaining('Panadol Extra Tablets'), findsOneWidget);
      expect(find.textContaining('Dosage: Take two tablets with water.'), findsOneWidget);
      expect(find.textContaining('Price: ₦1850 for 10 blister packs.'), findsOneWidget);
    });

    testWidgets('Renders numbered lists correctly', (tester) async {
      const sample = '''
1. Rest in a quiet dark room.
2. Hydrate adequately with cold water.
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiMarkdownText(
              text: sample,
            ),
          ),
        ),
      );

      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.textContaining('Rest in a quiet dark room.'), findsOneWidget);
    });
  });
}
