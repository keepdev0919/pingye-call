import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'call_result.dart';
import 'caller_profile.dart';

// CallSimulator wraps platform-specific call UI display.
//
// iOS:  Direct Swift channel (com.pingye/callkit) → PingyeCallKitProvider
//       → CXProvider.reportNewIncomingCall() → real iOS system call screen.
//       NOTE: flutter_callkit_incoming deadlocks on iOS 26+ (result(true) called
//       AFTER synchronous showCallkitIncoming() which triggers CXProvider main-thread
//       deadlock). We bypass it entirely on iOS.
//
// Android: flutter_callkit_incoming → fullScreenIntent notification
//          → WindowManager overlay (TYPE_APPLICATION_OVERLAY)
class CallSimulator {
  static bool _isActive = false;
  static bool _handlerSet = false;
  static const _iosChannel = MethodChannel('com.pingye/callkit');
  // ignore: unused_field — held to keep Android event subscription alive
  static StreamSubscription? _androidEventSub;

  // Listen for onAccepted / onDeclined sent back from native.
  // iOS: PingyeCallKitProvider → MethodChannel
  // Android: FlutterCallkitIncoming.onEvent stream
  static void _ensureHandler() {
    if (_handlerSet) return;
    _handlerSet = true;

    if (Platform.isIOS) {
      _iosChannel.setMethodCallHandler((call) async {
        if (call.method == 'onAccepted') {
          // iOS native in-call UI stays visible — user ends call via the
          // system hang-up button, which triggers CXEndCallAction → onDeclined.
          _isActive = false;
        } else if (call.method == 'onDeclined') {
          onCallEnded();
        }
      });
    } else {
      // Android: listen for accept/decline from flutter_callkit_incoming
      _androidEventSub = FlutterCallkitIncoming.onEvent.listen((event) {
        if (event == null) return;
        switch (event.event) {
          case Event.actionCallAccept:
            _isActive = false;
            break;
          case Event.actionCallDecline:
          case Event.actionCallEnded:
            onCallEnded();
            break;
          default:
            break;
        }
      });
    }
  }

  static Future<CallResult> showCall(CallerProfile profile) async {
    if (_isActive) return CallResult.alreadyActive;

    try {
      _ensureHandler();
      _isActive = true;
      print('[CallSimulator] showCall — name=${profile.name}');

      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('showCall', {
          'name': profile.name,
          'number': '',
        });
      } else {
        final callId = DateTime.now().millisecondsSinceEpoch.toString();
        await FlutterCallkitIncoming.showCallkitIncoming(
          CallKitParams(
            id: callId,
            nameCaller: profile.name,
            appName: 'Phone',
            handle: profile.name,
            type: 0,
            duration: 30000,
            textAccept: '수락',
            textDecline: '거절',
            android: const AndroidParams(
              isCustomNotification: false,
              isShowLogo: false,
              ringtonePath: 'system_ringtone_default',
            ),
          ),
        );
      }

      print('[CallSimulator] showCall returned');
      return CallResult.success;
    } catch (e) {
      print('[CallSimulator] ERROR: $e');
      _isActive = false;
      return CallResult.permissionDenied;
    }
  }

  static void onCallEnded() {
    _isActive = false;
  }

  // Called before starting a new waiting session to clear any stuck state
  // (e.g. if onAccepted/onDeclined never fired due to a channel issue).
  static void reset() {
    _isActive = false;
  }
}
