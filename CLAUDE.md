# Pingye Call — CLAUDE.md

## 프로젝트 개요

Flutter 기반 iOS/Android 앱. 어색하거나 불편한 상황에서 가상 수신 전화를 시뮬레이션해 자리를 피할 수 있게 해주는 앱.

- **앱 이름**: 핑계콜 (App Store: Pingye Call)
- **번들 ID**: com.keepdev.pingyeCall
- **버전**: 1.0.0 (Build 1)
- **팀 ID**: HB2ZHR35Y4
- **지원 언어**: 한국어, 영어 (기기 언어 자동 전환)

---

## 주요 커맨드

```bash
# 개발 실행 (실제 기기 연결 필요)
flutter run

# iOS 배포용 빌드
flutter build ipa

# 로컬라이제이션 코드 재생성
flutter gen-l10n

# 의존성 설치
flutter pub get
```

---

## 프로젝트 구조

```
lib/
├── main.dart                      # 앱 진입점, Riverpod, 로컬라이제이션 설정
├── core/
│   ├── app_navigator.dart         # 화면 라우팅
│   └── theme.dart                 # 디자인 시스템 (다크 테마)
├── logic/
│   ├── call_simulator.dart        # iOS/Android 플랫폼별 전화 시뮬레이션
│   ├── trigger_manager.dart       # 타이머/탭 제스처 상태 관리 (Riverpod)
│   ├── caller_profile.dart        # 발신자 프로필 데이터 모델
│   ├── tap_sequence_detector.dart # 연속 탭 감지 로직
│   └── call_result.dart           # 전화 결과 enum
├── screens/
│   ├── settings_screen.dart       # 메인 화면 (타이머 선택, 대기 시작/취소)
│   ├── caller_profile_screen.dart # 발신자 이름 입력
│   └── gesture_setup_screen.dart  # 탭 횟수 설정
└── l10n/
    ├── app_ko.arb                 # 한국어 문자열
    ├── app_en.arb                 # 영어 문자열
    └── app_localizations.dart     # 자동 생성 (flutter gen-l10n)

ios/Runner/
├── PingyeCallKitProvider.swift    # iOS CallKit 네이티브 연동
└── Info.plist                     # CFBundleDisplayName: "pingyecall"

fastlane/metadata/
├── ko/                            # 한국어 App Store 메타데이터
└── en-US/                         # 영어 App Store 메타데이터

openspec/                          # OpenSpec 스펙 문서
├── specs/                         # 현재 앱 스펙 (누적 관리)
└── changes/archive/               # 완료된 Change 히스토리
```

---

## 아키텍처

```
UI (Flutter Screens)
    ↓ Riverpod (triggerManagerProvider)
TriggerManager — 타이머 카운트다운, 탭 시퀀스 감지
    ↓
CallSimulator
    iOS: MethodChannel(com.pingye/callkit) → PingyeCallKitProvider → CXProvider
    Android: flutter_callkit_incoming → fullScreenIntent
```

---

## 핵심 주의사항

### iOS CallKit
- `flutter_callkit_incoming`은 iOS 26+에서 CXProvider 메인스레드 데드락 발생 → iOS는 완전 우회
- iOS는 `com.pingye/callkit` 네이티브 채널 직접 사용
- CallKit 수신 화면 앱 이름: `"pingyecall"` (CFBundleDisplayName, CXProviderConfiguration.localizedName 동일)

### 로컬라이제이션
- 문자열 추가 시 `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb` 모두 수정
- 수정 후 `flutter gen-l10n` 실행 필수
- 화면에서 하드코딩 문자열 금지 → 반드시 `AppLocalizations.of(context)!.xxx` 사용

### 상태 관리
- Riverpod `NotifierProvider` 사용
- `TriggerManager`는 `ref.keepAlive()`로 화면 전환 시에도 대기 상태 유지

---

## App Store 배포

- **배포 방식**: Xcode Archive → Distribute App → App Store Connect
- **스크린샷 생성**: `/tmp/pingye_screenshots_build` (Next.js + html-to-image)
  - iPhone 6.5": 1284×2778
  - iPad 13": 2048×2732
- **메타데이터**: `fastlane/metadata/` 폴더 관리

---

## OpenSpec 워크플로우

새 기능 추가 시:
```
/opsx:propose "기능 설명"   → 스펙/설계/태스크 자동 생성
/opsx:apply                 → 구현
/opsx:archive               → 완료 후 아카이브
```
