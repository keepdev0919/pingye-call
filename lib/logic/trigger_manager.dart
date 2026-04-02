import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'call_result.dart';
import 'call_simulator.dart';
import 'caller_profile.dart';
import 'tap_sequence_detector.dart';

class TriggerState {
  final bool isWaiting;
  final Duration? selectedDuration;
  final Duration? remaining;
  final CallerProfile callerProfile;
  final int tapCount;
  final int tapTarget;
  final bool volumeButtonEnabled;

  const TriggerState({
    this.isWaiting = false,
    this.selectedDuration,
    this.remaining,
    this.callerProfile = CallerProfile.defaultProfile,
    this.tapCount = 0,
    this.tapTarget = 5,
    this.volumeButtonEnabled = false,
  });

  TriggerState copyWith({
    bool? isWaiting,
    Duration? selectedDuration,
    Duration? remaining,
    CallerProfile? callerProfile,
    int? tapCount,
    int? tapTarget,
    bool? volumeButtonEnabled,
    bool clearRemaining = false,
  }) {
    return TriggerState(
      isWaiting: isWaiting ?? this.isWaiting,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remaining: clearRemaining ? null : (remaining ?? this.remaining),
      callerProfile: callerProfile ?? this.callerProfile,
      tapCount: tapCount ?? this.tapCount,
      tapTarget: tapTarget ?? this.tapTarget,
      volumeButtonEnabled: volumeButtonEnabled ?? this.volumeButtonEnabled,
    );
  }
}

class TriggerManager extends Notifier<TriggerState> {
  Timer? _countdownTimer;
  late TapSequenceDetector _tapDetector;

  @override
  TriggerState build() {
    ref.keepAlive();
    _initTapDetector(5);
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _tapDetector.dispose();
    });
    return const TriggerState();
  }

  void _initTapDetector(int target) {
    _tapDetector = TapSequenceDetector(
      targetCount: target,
      onTriggered: _onGestureTriggered,
      onCountChanged: (count) => state = state.copyWith(tapCount: count),
    );
  }

  void onTap() {
    if (!state.isWaiting) return; // isWaiting guard
    _tapDetector.onTap();
  }

  void startWaiting() {
    CallSimulator.reset(); // clear any stuck _isActive from a previous session
    final duration = state.selectedDuration ?? const Duration(minutes: 5);
    state = state.copyWith(isWaiting: true, remaining: duration);
    _startCountdown(duration);
  }

  void cancelWaiting() {
    _countdownTimer?.cancel();
    _tapDetector.reset();
    state = state.copyWith(isWaiting: false, clearRemaining: true, tapCount: 0);
  }

  void setSelectedDuration(Duration duration) {
    state = state.copyWith(selectedDuration: duration);
  }

  void setCallerProfile(CallerProfile profile) {
    state = state.copyWith(callerProfile: profile);
  }

  void setTapTarget(int count) {
    _tapDetector.dispose();
    _initTapDetector(count);
    state = state.copyWith(tapTarget: count);
  }

  void setVolumeButtonEnabled(bool enabled) {
    state = state.copyWith(volumeButtonEnabled: enabled);
  }

  void _startCountdown(Duration duration) {
    var remaining = duration;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining -= const Duration(seconds: 1);
      if (remaining <= Duration.zero) {
        timer.cancel();
        _onTimerTriggered();
      } else {
        state = state.copyWith(remaining: remaining);
      }
    });
  }

  Future<void> _onTimerTriggered() async {
    if (!state.isWaiting) return;
    final result = await CallSimulator.showCall(state.callerProfile);
    if (result == CallResult.success) {
      state = state.copyWith(isWaiting: false, clearRemaining: true, tapCount: 0);
    }
  }

  Future<void> _onGestureTriggered() async {
    if (!state.isWaiting) return;
    _countdownTimer?.cancel();
    final result = await CallSimulator.showCall(state.callerProfile);
    if (result == CallResult.success) {
      state = state.copyWith(isWaiting: false, clearRemaining: true, tapCount: 0);
    }
  }
}

// keepAlive: TriggerManager survives widget rebuilds and screen navigation
final triggerManagerProvider =
    NotifierProvider<TriggerManager, TriggerState>(TriggerManager.new);
