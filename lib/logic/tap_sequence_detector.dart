import 'dart:async';

// Renamed from GestureDetector to avoid Flutter SDK naming conflict.
//
// State machine:
//
//   [idle] → (first tap) → [detecting: count=1, timer=2s]
//          → (more taps) → count++, reset timer
//          → (count == N) → [triggered] → onTriggered() → [cooldown: 3s] → [idle]
//          → (2s timeout) → [idle] (counter reset)
//
enum TapDetectorState { idle, detecting, triggered, cooldown }

typedef TriggerCallback = void Function();
typedef CountCallback = void Function(int count);

class TapSequenceDetector {
  final int targetCount;
  final Duration windowDuration;
  final Duration cooldownDuration;
  final TriggerCallback onTriggered;
  final CountCallback? onCountChanged;

  TapDetectorState _state = TapDetectorState.idle;
  int _count = 0;
  Timer? _windowTimer;
  Timer? _cooldownTimer;

  TapSequenceDetector({
    required this.targetCount,
    required this.onTriggered,
    this.onCountChanged,
    this.windowDuration = const Duration(seconds: 2),
    this.cooldownDuration = const Duration(seconds: 3),
  });

  TapDetectorState get state => _state;
  int get count => _count;

  void onTap() {
    if (_state == TapDetectorState.cooldown || _state == TapDetectorState.triggered) {
      return;
    }

    // Sliding window: reset timer on every tap
    _windowTimer?.cancel();
    _count++;
    onCountChanged?.call(_count);

    if (_count >= targetCount) {
      _trigger();
      return;
    }

    _state = TapDetectorState.detecting;
    _windowTimer = Timer(windowDuration, _resetCount);
  }

  void _trigger() {
    _state = TapDetectorState.triggered;
    _windowTimer?.cancel();
    _count = 0;
    onTriggered();
    _startCooldown();
  }

  void _startCooldown() {
    _state = TapDetectorState.cooldown;
    _cooldownTimer = Timer(cooldownDuration, () {
      _state = TapDetectorState.idle;
    });
  }

  void _resetCount() {
    _count = 0;
    _state = TapDetectorState.idle;
    onCountChanged?.call(0);
  }

  void reset() {
    _windowTimer?.cancel();
    _cooldownTimer?.cancel();
    _count = 0;
    _state = TapDetectorState.idle;
    onCountChanged?.call(0);
  }

  void dispose() {
    _windowTimer?.cancel();
    _cooldownTimer?.cancel();
  }
}
