# fake-call-trigger Specification

## Purpose
TBD - created by archiving change pingye-call-current-state. Update Purpose after archive.
## Requirements
### Requirement: Timer Trigger

앱은 사용자가 설정한 시간(1분, 5분, 10분, 30분, 커스텀)이 경과하면 SHALL 자동으로 가상 수신 전화를 트리거해야 한다.

#### Scenario: 타이머 만료 시 전화 발신

- **WHEN** 사용자가 타이머 시간을 선택하고 대기를 시작한 후 해당 시간이 경과하면
- **THEN** 시스템 수준의 수신 전화 UI가 표시된다
- **AND** 발신자 이름은 사용자가 설정한 CallerProfile.name으로 표시된다

#### Scenario: 대기 중 취소

- **WHEN** 사용자가 대기 중 취소 버튼을 누르면
- **THEN** 카운트다운이 중단되고 대기 상태가 해제된다

---

### Requirement: Tap Gesture Trigger

앱은 대기 중 화면에서 설정된 횟수만큼 연속 탭하면 SHALL 즉시 가상 전화를 트리거해야 한다.

#### Scenario: 탭 시퀀스 완성 시 즉시 전화

- **WHEN** 대기 상태에서 사용자가 설정된 tapTarget 횟수만큼 화면을 연속으로 탭하면
- **THEN** 타이머를 무시하고 즉시 수신 전화 UI가 표시된다

#### Scenario: 대기 상태가 아닐 때 탭 무시

- **WHEN** isWaiting이 false인 상태에서 화면을 탭하면
- **THEN** 아무 반응도 없어야 한다

---

### Requirement: iOS CallKit Integration

iOS에서 앱은 SHALL 네이티브 Swift 채널을 통해 CXProvider를 직접 호출해야 한다. flutter_callkit_incoming을 우회해야 한다.

#### Scenario: iOS 수신 전화 표시

- **WHEN** CallSimulator.showCall()이 iOS에서 호출되면
- **THEN** com.pingye/callkit 채널을 통해 Swift PingyeCallKitProvider가 CXProvider.reportNewIncomingCall()을 호출한다
- **AND** 시스템 잠금화면 수준의 수신 전화 UI가 표시된다

#### Scenario: 이미 활성 전화 중 중복 호출 방지

- **WHEN** _isActive가 true인 상태에서 showCall()이 다시 호출되면
- **THEN** CallResult.alreadyActive를 반환하고 새 전화를 MUST 트리거하지 않아야 한다

