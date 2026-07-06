import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_captcha/slider_captcha.dart';

// Create a mock provider that doesn't rely on base64 decoding if possible
class MockSliderCaptchaClientProvider extends SliderCaptchaClientProvider {
  MockSliderCaptchaClientProvider()
      : super(
          puzzleBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
          pieceBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
          coordinatesY: 0.25,
        );

  @override
  Future<bool> init(BuildContext context) async {
    puzzleSize = const Size(100, 100);
    pieceSize = const Size(20, 20);
    ratio = 1.0;
    // We don't even need real images for some tests if we handle nulls
    return true;
  }
}

void main() {
  group('Slider Captcha Client', () {
    testWidgets('Test if Slider Captcha Client renders', (tester) async {
      final provider = MockSliderCaptchaClientProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCaptchaClient(
              provider: provider,
              onConfirm: (value) async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Slider to verify'), findsOneWidget);
    });

    testWidgets('Test drag interaction', (tester) async {
      double confirmedValue = -1;
      final provider = MockSliderCaptchaClientProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCaptchaClient(
              provider: provider,
              onConfirm: (value) async {
                confirmedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);
      expect(thumbFinder, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(thumbFinder));
      await gesture.moveBy(const Offset(100.0, 0.0));
      await gesture.up();
      
      await tester.pumpAndSettle();

      expect(confirmedValue, greaterThan(0));
    });
   group('Slider Captcha Client Provider', () {
    test('Provider decodes base64 in constructor', () {
      final provider = SliderCaptchaClientProvider(
        puzzleBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
        pieceBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
        coordinatesY: 0.5,
      );
      expect(provider.puzzleUnit8List, isNotEmpty);
      expect(provider.pieceUnit8List, isNotEmpty);
    });
  });
  });
}
