enum DetectedScrollState {
  down,
  up,
  idle,
}

class ScrollDetector {
  final int scrollThreshold;

  final int timeDeltaThreshold;

  ScrollDetector({
    this.scrollThreshold = 5,
    this.timeDeltaThreshold = 500,
  });

  DateTime? _lastScrollTime;
  int? _lastScrollPosition;

  DetectedScrollState update(DateTime time, int y) {
    if (_lastScrollTime != null && _lastScrollPosition != null) {
      final direction = y - _lastScrollPosition!;
      final timeDelta = time.millisecondsSinceEpoch - _lastScrollTime!.millisecondsSinceEpoch;

      // Adjust the threshold and time delta as needed
      const scrollThreshold = 5;
      const timeDeltaThreshold = 500;

      if (direction.abs() > scrollThreshold && timeDelta < timeDeltaThreshold) {
        if (direction > 0) {
          return DetectedScrollState.down;
        } else {
          return DetectedScrollState.up;
        }
      }
    }

    _lastScrollTime = time;
    _lastScrollPosition = y;

    return DetectedScrollState.idle;
  }
}
