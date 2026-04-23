import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_captcha/slider_captcha.dart';

void main() {
  group('SliderMovementData', () {
    test('isLikelyHuman returns false when trail is too short', () {
      final data = SliderMovementData(
        trail: const [
          SliderDragPoint(x: 10, timestampMs: 0),
          SliderDragPoint(x: 50, timestampMs: 100),
        ],
        totalDurationMs: 100,
      );
      expect(data.isLikelyHuman(), isFalse);
    });

    test('isLikelyHuman returns false when duration is too short', () {
      final trail = List.generate(
        10,
        (i) => SliderDragPoint(x: i * 10.0, timestampMs: i),
      );
      final data = SliderMovementData(trail: trail, totalDurationMs: 50);
      expect(data.isLikelyHuman(), isFalse);
    });

    test('isLikelyHuman returns false when velocity is perfectly uniform', () {
      // All points have identical velocity: move 10px every 100ms.
      final trail = List.generate(
        10,
        (i) => SliderDragPoint(x: i * 10.0, timestampMs: i * 100),
      );
      final data = SliderMovementData(trail: trail, totalDurationMs: 900);
      // Variance of a constant series is 0 -> bot-like.
      expect(data.isLikelyHuman(), isFalse);
    });

    test('isLikelyHuman returns true for varied human-like movement', () {
      // Non-uniform intervals and distances simulate natural hand movement.
      const trail = [
        SliderDragPoint(x: 0, timestampMs: 0),
        SliderDragPoint(x: 12, timestampMs: 80),
        SliderDragPoint(x: 28, timestampMs: 160),
        SliderDragPoint(x: 50, timestampMs: 300),
        SliderDragPoint(x: 65, timestampMs: 420),
        SliderDragPoint(x: 80, timestampMs: 510),
        SliderDragPoint(x: 100, timestampMs: 650),
      ];
      final data = SliderMovementData(trail: trail, totalDurationMs: 650);
      expect(data.isLikelyHuman(), isTrue);
    });

    test('trailToJson produces a list with x and ts keys', () {
      const trail = [
        SliderDragPoint(x: 42.5, timestampMs: 1000),
      ];
      final data = SliderMovementData(trail: trail, totalDurationMs: 0);
      final json = data.trailToJson();
      expect(json, hasLength(1));
      expect(json[0]['x'], 42.5);
      expect(json[0]['ts'], 1000);
    });
  });

  group('SliderCaptcha widget', () {
    testWidgets('renders without crashing with default parameters',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCaptcha(
              image: const SizedBox(width: 200, height: 100),
              onConfirm: (_) async {},
            ),
          ),
        ),
      );
      expect(find.byType(SliderCaptcha), findsOneWidget);
    });

    testWidgets('onBehaviorData callback parameter is accepted', (tester) async {
      SliderMovementData? received;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCaptcha(
              image: const SizedBox(width: 200, height: 100),
              onConfirm: (_) async {},
              onBehaviorData: (data) => received = data,
            ),
          ),
        ),
      );
      expect(find.byType(SliderCaptcha), findsOneWidget);
      // Callback registered; no drag fired yet so received stays null.
      expect(received, isNull);
    });

    testWidgets('maxAttempts parameter is accepted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCaptcha(
              image: const SizedBox(width: 200, height: 100),
              onConfirm: (_) async {},
              maxAttempts: 3,
            ),
          ),
        ),
      );
      expect(find.byType(SliderCaptcha), findsOneWidget);
    });
  });
}
