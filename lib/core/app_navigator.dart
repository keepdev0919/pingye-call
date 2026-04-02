import 'package:flutter/material.dart';

/// Global navigator key — allows CallSimulator to push CallingScreen
/// without a BuildContext (onAccepted arrives from native channel).
final appNavigatorKey = GlobalKey<NavigatorState>();
