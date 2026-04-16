# Spec: localization

## ADDED Requirements

### Requirement: 한국어/영어 자동 전환

앱은 기기 언어 설정에 따라 SHALL 자동으로 한국어 또는 영어 UI를 표시해야 한다.

#### Scenario: 기기 언어가 한국어인 경우

- **WHEN** 기기 언어가 ko(한국어)로 설정된 경우
- **THEN** 앱의 모든 UI 텍스트가 한국어로 표시되어야 한다

#### Scenario: 기기 언어가 영어인 경우

- **WHEN** 기기 언어가 en(영어)로 설정된 경우
- **THEN** 앱의 모든 UI 텍스트가 영어로 표시되어야 한다

#### Scenario: 지원하지 않는 언어인 경우

- **WHEN** 기기 언어가 ko/en 이외인 경우
- **THEN** 기본값인 한국어(ko)로 MUST 폴백되어야 한다

---

### Requirement: ARB 기반 문자열 관리

모든 UI 문자열은 SHALL lib/l10n/app_ko.arb, lib/l10n/app_en.arb에서 관리되어야 한다.

#### Scenario: 문자열 접근

- **WHEN** UI 컴포넌트가 텍스트를 렌더링할 때
- **THEN** AppLocalizations.of(context)!를 통해 접근해야 한다
- **AND** 하드코딩된 한국어 문자열이 MUST 없어야 한다
