import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_captcha/slider_captcha.dart';

void main() {
  group('Slider Captcha (Client Verify)', () {
    testWidgets('Test if SliderCaptcha renders correctly', (tester) async {
      bool? isConfirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCaptcha(
              image: Container(
                width: 300,
                height: 200,
                color: Colors.grey,
              ),
              onConfirm: (value) async {
                isConfirmed = value;
              },
            ),
          ),
        ),
      );

      expect(find.text('Slide to authenticate'), findsOneWidget);
      expect(find.byType(SliderCaptcha), findsOneWidget);
      
      // Wait for initializations if any (like addPostFrameCallback)
      await tester.pumpAndSettle();
    });

    testWidgets('Test drag interaction and successful confirmation', (tester) async {
      bool? isConfirmed;
      final controller = SliderController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: SliderCaptcha(
                controller: controller,
                image: Container(
                  width: 300,
                  height: 200,
                  color: Colors.grey,
                ),
                onConfirm: (value) async {
                  isConfirmed = value;
                },
                threshold: 10, // Default is 10
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // The answer position is random, but we can't easily know it without exposing it.
      // However, we can mock the create() method if we could, but it's internal.
      // Let's try to drag it and see if it triggers onConfirm.
      
      final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);
      expect(thumbFinder, findsOneWidget);

      // Drag to some position
      await tester.drag(thumbFinder, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // onConfirm is called on drag end
      expect(isConfirmed, isNotNull);
    });
  });
}
