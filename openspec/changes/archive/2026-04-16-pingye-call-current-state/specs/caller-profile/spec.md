# Spec: caller-profile

## ADDED Requirements

### Requirement: 발신자 이름 설정

사용자는 수신 전화 화면에 표시될 발신자 이름을 SHALL 자유롭게 입력할 수 있어야 한다.

#### Scenario: 이름 입력 및 저장

- **WHEN** 사용자가 CallerProfileScreen에서 이름을 입력하고 저장하면
- **THEN** 해당 이름이 TriggerState.callerProfile에 저장된다
- **AND** 이후 전화 트리거 시 이 이름이 수신 전화 화면에 표시된다

#### Scenario: 이름 미입력 시 기본값 사용

- **WHEN** 사용자가 이름을 설정하지 않으면
- **THEN** 기본값 '엄마'(CallerProfile.defaultProfile)가 MUST 사용되어야 한다

---

### Requirement: 탭 횟수 설정

사용자는 즉시 전화 트리거에 필요한 탭 횟수를 SHALL 커스터마이징할 수 있어야 한다.

#### Scenario: 탭 횟수 변경

- **WHEN** 사용자가 GestureSetupScreen에서 탭 횟수를 변경하면
- **THEN** TriggerManager.tapTarget이 업데이트되어야 한다
- **AND** 이후 대기 중 해당 횟수만큼 탭해야 즉시 전화가 트리거된다
