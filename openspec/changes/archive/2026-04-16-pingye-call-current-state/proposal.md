# Proposal: Pingye Call — Current App State

## Why

핑계콜은 어색하거나 불편한 사회적 상황에서 자연스럽게 자리를 피할 수 있도록, 실제 수신 전화처럼 보이는 가상 전화 화면을 시뮬레이션하는 iOS/Android 앱이다. 이 문서는 현재 v1.0.0 출시 상태의 핵심 기능과 구조를 스펙으로 정리한다.

## What Changes

이 Change는 신규 기능 추가가 아닌 **현재 상태의 문서화**다. 이후 기능 추가/수정 시 이 스펙을 기반으로 작업한다.

## Capabilities

### Core Capabilities

- `fake-call-trigger`: 타이머 또는 제스처(탭 시퀀스)로 가상 수신 전화를 트리거
- `callkit-integration`: iOS CallKit을 통한 시스템 수준 수신 전화 UI 표시
- `caller-profile`: 발신자 이름 커스터마이징 및 저장
- `localization`: 한국어/영어 자동 전환

### Screens

- `settings-screen`: 메인 화면. 발신자 이름 설정, 타이머 선택, 대기 시작/취소
- `caller-profile-screen`: 발신자 이름 입력 화면
- `gesture-setup-screen`: 탭 횟수 설정 화면 (즉시 전화 트리거용)

## Impact

- `lib/logic/call_simulator.dart`: iOS/Android 플랫폼별 전화 시뮬레이션 핵심 로직
- `lib/logic/trigger_manager.dart`: 타이머 카운트다운, 탭 시퀀스 감지, 상태 관리 (Riverpod)
- `lib/logic/caller_profile.dart`: 발신자 프로필 데이터 모델
- `lib/screens/settings_screen.dart`: 메인 UI
- `ios/Runner/PingyeCallKitProvider.swift`: iOS CallKit 네이티브 연동
