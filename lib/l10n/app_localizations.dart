import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @navTitleNotifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get navTitleNotifications;

  /// No description provided for @sectionCaller.
  ///
  /// In ko, this message translates to:
  /// **'발신자'**
  String get sectionCaller;

  /// No description provided for @nameNotSet.
  ///
  /// In ko, this message translates to:
  /// **'이름 설정 필요'**
  String get nameNotSet;

  /// No description provided for @sectionTimer.
  ///
  /// In ko, this message translates to:
  /// **'예약 시간'**
  String get sectionTimer;

  /// No description provided for @customTimerChip.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력...'**
  String get customTimerChip;

  /// No description provided for @customTimerDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get customTimerDialogTitle;

  /// No description provided for @customTimerHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 45'**
  String get customTimerHint;

  /// No description provided for @customTimerSuffix.
  ///
  /// In ko, this message translates to:
  /// **'초'**
  String get customTimerSuffix;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @armedHint.
  ///
  /// In ko, this message translates to:
  /// **'화면 어디든 탭하면 즉시 전화'**
  String get armedHint;

  /// No description provided for @waitingLabelNoTime.
  ///
  /// In ko, this message translates to:
  /// **'대기 중...'**
  String get waitingLabelNoTime;

  /// No description provided for @waitingLabel.
  ///
  /// In ko, this message translates to:
  /// **'예약됨 · {time} 후 전화'**
  String waitingLabel(String time);

  /// No description provided for @startButton.
  ///
  /// In ko, this message translates to:
  /// **'대기 시작'**
  String get startButton;

  /// No description provided for @noNameSnackbar.
  ///
  /// In ko, this message translates to:
  /// **'발신자 이름을 먼저 설정해주세요'**
  String get noNameSnackbar;

  /// No description provided for @callerNavTitle.
  ///
  /// In ko, this message translates to:
  /// **'발신자'**
  String get callerNavTitle;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @callerNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get callerNameLabel;

  /// No description provided for @callerNameHint.
  ///
  /// In ko, this message translates to:
  /// **'엄마'**
  String get callerNameHint;

  /// No description provided for @gestureNavTitle.
  ///
  /// In ko, this message translates to:
  /// **'제스처 설정'**
  String get gestureNavTitle;

  /// No description provided for @sectionTapCount.
  ///
  /// In ko, this message translates to:
  /// **'탭 횟수'**
  String get sectionTapCount;

  /// No description provided for @sectionExtraTrigger.
  ///
  /// In ko, this message translates to:
  /// **'추가 트리거'**
  String get sectionExtraTrigger;

  /// No description provided for @volumeButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'볼륨버튼 트리거'**
  String get volumeButtonLabel;

  /// No description provided for @volumeButtonSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'잠금화면에서도 작동 (실험적)'**
  String get volumeButtonSubtitle;

  /// No description provided for @gestureTestComplete.
  ///
  /// In ko, this message translates to:
  /// **'완료!'**
  String get gestureTestComplete;

  /// No description provided for @gestureTestHint.
  ///
  /// In ko, this message translates to:
  /// **'여기를 탭해서 테스트'**
  String get gestureTestHint;

  /// No description provided for @tapCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'탭 횟수'**
  String get tapCountLabel;

  /// No description provided for @durationSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{s}초'**
  String durationSeconds(int s);

  /// No description provided for @durationMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{m}분'**
  String durationMinutes(int m);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{m}분 {s}초'**
  String durationMinutesSeconds(int m, int s);

  /// No description provided for @timer1Min.
  ///
  /// In ko, this message translates to:
  /// **'1분'**
  String get timer1Min;

  /// No description provided for @timer5Min.
  ///
  /// In ko, this message translates to:
  /// **'5분'**
  String get timer5Min;

  /// No description provided for @timer10Min.
  ///
  /// In ko, this message translates to:
  /// **'10분'**
  String get timer10Min;

  /// No description provided for @timer30Min.
  ///
  /// In ko, this message translates to:
  /// **'30분'**
  String get timer30Min;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
