// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navTitleNotifications => '알림';

  @override
  String get sectionCaller => '발신자';

  @override
  String get nameNotSet => '이름 설정 필요';

  @override
  String get sectionTimer => '예약 시간';

  @override
  String get customTimerChip => '직접 입력...';

  @override
  String get customTimerDialogTitle => '직접 입력';

  @override
  String get customTimerHint => '예: 45';

  @override
  String get customTimerSuffix => '초';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get armedHint => '화면 어디든 탭하면 즉시 전화';

  @override
  String get waitingLabelNoTime => '대기 중...';

  @override
  String waitingLabel(String time) {
    return '예약됨 · $time 후 전화';
  }

  @override
  String get startButton => '대기 시작';

  @override
  String get noNameSnackbar => '발신자 이름을 먼저 설정해주세요';

  @override
  String get callerNavTitle => '발신자';

  @override
  String get save => '저장';

  @override
  String get callerNameLabel => '이름';

  @override
  String get callerNameHint => '엄마';

  @override
  String get gestureNavTitle => '제스처 설정';

  @override
  String get sectionTapCount => '탭 횟수';

  @override
  String get sectionExtraTrigger => '추가 트리거';

  @override
  String get volumeButtonLabel => '볼륨버튼 트리거';

  @override
  String get volumeButtonSubtitle => '잠금화면에서도 작동 (실험적)';

  @override
  String get gestureTestComplete => '완료!';

  @override
  String get gestureTestHint => '여기를 탭해서 테스트';

  @override
  String get tapCountLabel => '탭 횟수';

  @override
  String durationSeconds(int s) {
    return '$s초';
  }

  @override
  String durationMinutes(int m) {
    return '$m분';
  }

  @override
  String durationMinutesSeconds(int m, int s) {
    return '$m분 $s초';
  }

  @override
  String get timer1Min => '1분';

  @override
  String get timer5Min => '5분';

  @override
  String get timer10Min => '10분';

  @override
  String get timer30Min => '30분';
}
