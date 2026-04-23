/// A single position sample captured during a slider drag gesture.
class SliderDragPoint {
  /// Horizontal offset in logical pixels at the time of capture.
  final double x;

  /// Unix timestamp in milliseconds when this point was sampled.
  final int timestampMs;

  const SliderDragPoint({required this.x, required this.timestampMs});

  Map<String, dynamic> toJson() => {'x': x, 'ts': timestampMs};
}

/// Movement data collected across the full duration of a slider drag gesture.
///
/// Pass this to your server alongside the position answer so it can apply
/// bot-detection heuristics on the raw movement trace.
class SliderMovementData {
  /// Ordered list of drag samples recorded from drag-start to drag-end.
  final List<SliderDragPoint> trail;

  /// Total elapsed time from the first drag event to release, in milliseconds.
  final int totalDurationMs;

  const SliderMovementData({
    required this.trail,
    required this.totalDurationMs,
  });

  /// Client-side heuristic: returns `true` when the movement pattern is
  /// consistent with a human gesture.
  ///
  /// Checks applied:
  /// - At least [minPoints] drag samples were recorded.
  /// - Total drag duration exceeded [minDurationMs] milliseconds.
  /// - Velocity variance is non-zero (movement was not perfectly uniform).
  ///
  /// **Note:** This is a convenience check only. Server-side validation of
  /// the full [trail] is always recommended for reliable bot detection.
  bool isLikelyHuman({int minPoints = 5, int minDurationMs = 300}) {
    if (trail.length < minPoints) return false;
    if (totalDurationMs < minDurationMs) return false;
    return _hasVelocityVariance();
  }

  /// Returns `true` when successive velocities between sampled points vary,
  /// which is characteristic of natural human movement.
  bool _hasVelocityVariance() {
    if (trail.length < 3) return false;

    final velocities = <double>[];
    for (int i = 1; i < trail.length; i++) {
      final dt = trail[i].timestampMs - trail[i - 1].timestampMs;
      if (dt <= 0) continue;
      velocities.add((trail[i].x - trail[i - 1].x) / dt);
    }

    if (velocities.length < 2) return false;

    final mean = velocities.reduce((a, b) => a + b) / velocities.length;
    final variance = velocities
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        velocities.length;

    // Any non-trivial variance indicates non-uniform speed.
    return variance > 0;
  }

  /// Serialises the full trail to a JSON-encodable list, suitable for
  /// including in a server verification request body.
  List<Map<String, dynamic>> trailToJson() =>
      trail.map((p) => p.toJson()).toList();
}
