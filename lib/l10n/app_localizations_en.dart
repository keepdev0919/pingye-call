// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTitleNotifications => 'Reminders';

  @override
  String get sectionCaller => 'Caller';

  @override
  String get nameNotSet => 'Set caller name';

  @override
  String get sectionTimer => 'Schedule';

  @override
  String get customTimerChip => 'Custom...';

  @override
  String get customTimerDialogTitle => 'Custom time';

  @override
  String get customTimerHint => 'e.g. 45';

  @override
  String get customTimerSuffix => 'sec';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get armedHint => 'Tap anywhere to call instantly';

  @override
  String get waitingLabelNoTime => 'Waiting...';

  @override
  String waitingLabel(String time) {
    return 'Scheduled · calls in $time';
  }

  @override
  String get startButton => 'Start';

  @override
  String get noNameSnackbar => 'Please set a caller name first';

  @override
  String get callerNavTitle => 'Caller';

  @override
  String get save => 'Save';

  @override
  String get callerNameLabel => 'Name';

  @override
  String get callerNameHint => 'Mom';

  @override
  String get gestureNavTitle => 'Gesture';

  @override
  String get sectionTapCount => 'Tap count';

  @override
  String get sectionExtraTrigger => 'Extra triggers';

  @override
  String get volumeButtonLabel => 'Volume button trigger';

  @override
  String get volumeButtonSubtitle => 'Works on lock screen (experimental)';

  @override
  String get gestureTestComplete => 'Done!';

  @override
  String get gestureTestHint => 'Tap here to test';

  @override
  String get tapCountLabel => 'Tap count';

  @override
  String durationSeconds(int s) {
    return '${s}s';
  }

  @override
  String durationMinutes(int m) {
    return '${m}m';
  }

  @override
  String durationMinutesSeconds(int m, int s) {
    return '${m}m ${s}s';
  }

  @override
  String get timer1Min => '1m';

  @override
  String get timer5Min => '5m';

  @override
  String get timer10Min => '10m';

  @override
  String get timer30Min => '30m';
}
