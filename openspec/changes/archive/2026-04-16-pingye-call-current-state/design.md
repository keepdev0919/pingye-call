# Design: Pingye Call v1.0.0

## Context

Flutter 기반 iOS/Android 앱. 핵심은 iOS에서 실제 시스템 수신 전화 UI를 띄우는 것.

## Architecture

```
┌─────────────────────────────────────────────┐
│              UI Layer (Flutter)              │
│  SettingsScreen → CallerProfileScreen        │
│                 → GestureSetupScreen         │
└────────────────────┬────────────────────────┘
                     │ Riverpod (triggerManagerProvider)
┌────────────────────▼────────────────────────┐
│           TriggerManager (Logic)             │
│  - 타이머 카운트다운                          │
│  - TapSequenceDetector (탭 횟수 감지)         │
│  - CallerProfile 상태 관리                   │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│           CallSimulator (Platform)           │
│  iOS: MethodChannel(com.pingye/callkit)      │
│       → Swift PingyeCallKitProvider          │
│       → CXProvider.reportNewIncomingCall()   │
│                                             │
│  Android: flutter_callkit_incoming           │
│           → fullScreenIntent notification   │
└─────────────────────────────────────────────┘
```

## Key Decisions

### iOS: flutter_callkit_incoming 우회

flutter_callkit_incoming은 iOS 26+에서 CXProvider 메인스레드 데드락을 유발한다. 이를 해결하기 위해 iOS에서는 해당 패키지를 완전히 우회하고 네이티브 Swift 채널을 직접 사용한다.

### 상태 관리: Riverpod

TriggerManager를 Riverpod NotifierProvider로 관리. `ref.keepAlive()`로 화면 전환 시에도 대기 상태 유지.

### CallKit 앱 이름: "pingyecall"

iOS CallKit 수신 화면에 표시되는 앱 이름은 "pingyecall"로 설정. (CFBundleDisplayName, CXProviderConfiguration.localizedName 모두 동일 설정)

## Non-Goals

- 실제 전화 발신 기능 없음
- 서버/백엔드 없음. 완전 온디바이스
- 계정/로그인 없음
