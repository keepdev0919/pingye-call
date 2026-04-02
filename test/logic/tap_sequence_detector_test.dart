import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingye_call/logic/tap_sequence_detector.dart';

void main() {
  group('TapSequenceDetector', () {
    late bool triggered;
    late List<int> countUpdates;

    TapSequenceDetector make({int target = 3}) {
      return TapSequenceDetector(
        targetCount: target,
        onTriggered: () => triggered = true,
        onCountChanged: countUpdates.add,
      );
    }

    setUp(() {
      triggered = false;
      countUpdates = [];
    });

    // 1. Happy path: N taps within window triggers
    test('triggers on N taps within window', () {
      fakeAsync((async) {
        final detector = make(target: 3);
        detector.onTap();
        detector.onTap();
        detector.onTap();
        expect(triggered, isTrue);
        expect(detector.state, TapDetectorState.cooldown);
        detector.dispose();
      });
    });

    // 2. Timeout: taps that exceed the sliding window reset the counter
    test('resets count on 2s window timeout', () {
      fakeAsync((async) {
        final detector = make(target: 3);
        detector.onTap(); // count = 1
        detector.onTap(); // count = 2
        async.elapse(const Duration(seconds: 2, milliseconds: 1));
        expect(triggered, isFalse);
        expect(detector.state, TapDetectorState.idle);
        expect(detector.count, 0);
        detector.dispose();
      });
    });

    // 3. Cooldown: taps during cooldown are ignored
    test('ignores taps during 3s cooldown', () {
      fakeAsync((async) {
        final detector = make(target: 2);
        detector.onTap();
        detector.onTap(); // triggers
        expect(triggered, isTrue);

        triggered = false;
        detector.onTap(); // should be ignored
        detector.onTap();
        expect(triggered, isFalse);
        expect(detector.state, TapDetectorState.cooldown);

        async.elapse(const Duration(seconds: 3, milliseconds: 1));
        expect(detector.state, TapDetectorState.idle);
        detector.dispose();
      });
    });

    // 4. Sliding window: timer resets on every tap
    test('sliding window: last tap resets the 2s timer', () {
      fakeAsync((async) {
        final detector = make(target: 3);
        detector.onTap(); // count = 1
        async.elapse(const Duration(milliseconds: 1500));
        detector.onTap(); // count = 2, timer resets
        async.elapse(const Duration(milliseconds: 1500));
        // 1.5s since last tap — still within window
        expect(triggered, isFalse);
        expect(detector.count, 2);
        detector.onTap(); // count = 3 → triggers
        expect(triggered, isTrue);
        detector.dispose();
      });
    });

    // 5. Count callback reflects each tap
    test('onCountChanged fires for each tap', () {
      fakeAsync((async) {
        final detector = make(target: 5);
        detector.onTap();
        detector.onTap();
        detector.onTap();
        expect(countUpdates, [1, 2, 3]);
        detector.dispose();
      });
    });

    // 6. Reset method returns to idle immediately
    test('reset() clears state immediately', () {
      fakeAsync((async) {
        final detector = make(target: 5);
        detector.onTap();
        detector.onTap();
        expect(detector.count, 2);
        detector.reset();
        expect(detector.state, TapDetectorState.idle);
        expect(detector.count, 0);
        expect(countUpdates.last, 0);
        detector.dispose();
      });
    });
  });
}
