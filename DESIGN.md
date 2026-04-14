# Design System — 핑계콜

## Product Context
- **What this is:** 어색한 상황에서 탈출하기 위해 가짜 수신 전화를 예약하는 iOS 유틸리티 앱
- **Who it's for:** 사회적 불안/불편한 상황에서 자연스럽게 자리를 피하고 싶은 한국 iOS 유저
- **Space/industry:** 유틸리티 / 사회적 도피 도구. 경쟁: Faker 3, Fake Call Pro
- **Project type:** Flutter iOS 네이티브 유틸리티 앱 (다크 전용, 세로 고정)

## 핵심 포지셔닝 인사이트

**다른 가짜전화 앱들은 "장난" 도구로 포지셔닝.**  
핑계콜은 다르다 — *사회적 불안 완화 유틸리티*.  
디자인 언어는 Clock.app 또는 Timer 앱처럼 **신뢰감 있는 유틸리티**여야 한다.  
화려하거나 장난스럽지 않게. 빠르고, 조용하고, 믿음직하게.

## Aesthetic Direction
- **Direction:** Minimal Utility (iOS 네이티브 완성도 최우선)
- **Decoration level:** minimal — 타이포그래피와 상태 색이 모든 일을 한다
- **Mood:** 조용하고 신뢰감 있는. 긴장한 상황에서 손이 떨려도 쓸 수 있는 느낌.
- **Stealth principle:** 화면을 누군가 봤을 때 "전화 설정 앱"처럼 보여야 한다

## Typography
- **Display/Hero:** SF Pro Display (시스템 기본) — iOS 네이티브 일관성
- **Body/UI:** SF Pro Text (시스템 기본) — 읽기 편하고 익숙함
- **Countdown (대기 중):** `fontFeatures: [FontFeature.tabularFigures()]` 반드시 적용 — 숫자 너비 고정
- **Scale:**
  - navTitle: 17sp / w400 (현재 유지)
  - sectionHeader: 13sp / w400 / letterSpacing 0.5 (현재 유지)
  - body: 17sp / w400
  - countdown hero: 48sp / w200 / tabularFigures (신규)
  - chip: 15sp / w400 (selected: w500)

## Color
- **Approach:** restrained — accent은 드물게, 의미 있을 때만
- **Background:** `#1C1C1E` (현재 유지)
- **Surface:** `#2C2C2E` (현재 유지)
- **Text Primary:** `#FFFFFF`
- **Text Secondary:** `#8E8E93`
- **Separator:** `#38383A`
- **Accent (idle):** `#5856D6` — iOS system indigo (현재 유지)
- **Accent (waiting/armed):** `#30D158` — iOS system green. "준비됨"의 신호등 언어
- **Error:** `#FF453A`
- **Dot empty:** `#3A3A3C`

> **색 전환 원칙:** 대기 중 상태에서만 green 사용. Idle 상태에서는 indigo.  
> Green = "작동 중 / 안전 / 준비됨"의 보편적 신호. 사용자가 설명 없이도 상태를 이해한다.

## Spacing
- **Base unit:** 8px
- **Section gap:** 20px (현재 유지)
- **Card internal padding:** 16px horizontal, 12px vertical (현재 유지)
- **Screen horizontal padding:** 16px (현재 유지)
- **CTA bottom padding:** 16px (현재 유지)

## Layout (개선된 정보 구조)

현재 순서:
```
[트리거 → 예약 타이머 chips]
[발신자 → 이름 NavCell]
[CTA 버튼]
```

개선 순서:
```
[발신자 → 이름 NavCell]       ← 필수 입력 먼저
[예약 시간 → 타이머 chips]    ← 선택적 설정
[CTA 버튼]
```

이유: 이름 없으면 시작 불가 (현재 코드도 snackBar로 막음). 필수 필드가 먼저여야 사용자가 흐름을 이해한다.

## 상태별 UI 원칙

### Idle 상태 (대기 전)
- Accent: indigo `#5856D6`
- 화면: 발신자 + 타이머 + CTA 버튼
- CTA: "대기 시작" (filled, indigo)

### Armed 상태 (대기 중)
- Accent: green `#30D158`
- 상단 섹션들: opacity 0.4로 dim (설정 변경 불가 상태 시각화)
- 중앙 hero: 남은 시간 카운트다운 (48sp, w200, tabularFigures)
- 보조 텍스트: "화면 어디든 [N]번 탭하면 즉시 전화" (회색)
- CTA: "취소" (outlined, gray)
- 배경 색조 변화: 없음 (너무 튀면 주변에 노출됨)

### 트리거 완료 직후
- HapticFeedback.mediumImpact() (현재 있음)
- 시스템 전화 UI로 전환됨 (CallKit)

## Motion
- **Approach:** minimal-functional
- 상태 전환 애니메이션: `AnimatedSwitcher` duration 200ms
- Opacity dim: `AnimatedOpacity` duration 150ms
- 카운트다운 숫자: 갱신마다 fade 없이 즉시 (tabularFigures로 레이아웃 시프트 없음)

## 네이밍 & 카피 개선

| 현재 | 개선 | 이유 |
|------|------|------|
| 앱바 "핑계콜" | "알림" 또는 아이콘만 | 화면 노출 시 자연스럽게 보임 |
| 섹션헤더 "트리거" | "예약 시간" | 더 자연스럽고 덜 의심스러운 단어 |
| 타이머 칩 "기타" | "직접 입력..." | 무엇을 하는지 명확히 |
| AlertDialog 커스텀 입력 | 바텀시트 | iOS 네이티브 UX 패턴 |

## Border Radius
- Card/cell: `BorderRadius.circular(10)` — 현재 유지
- CTA 버튼: `BorderRadius.circular(12)` — 현재 유지
- Chip: `BorderRadius.circular(20)` — 현재 유지

## 구현 우선순위

1. **P0 (즉시):** 섹션 헤더 리네이밍, 칩 레이블 수정, 레이아웃 순서 변경
2. **P1 (핵심 UX):** 대기 중 상태 - 중앙 카운트다운 hero + dim 효과
3. **P2 (polish):** 커스텀 시간 입력 바텀시트 전환

## Decisions Log
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-04-14 | 앱 포지셔닝을 "장난" 아닌 "유틸리티"로 명확화 | 경쟁 앱과 차별화, 신뢰감 있는 디자인 언어 채택 |
| 2026-04-14 | 대기 중 accent를 green으로 전환 | 신호등 언어 활용, 설명 없이도 "작동 중" 상태 전달 |
| 2026-04-14 | 발신자 섹션을 타이머 위로 이동 | 필수 입력이 선택적 설정보다 먼저여야 함 |
| 2026-04-14 | 대기 중 hero 카운트다운 추가 | 남은 시간이 가장 중요한 정보 — 화면 중앙에 위치 |
| 2026-04-14 | 앱바 "핑계콜" → "알림" | 화면 노출 시 스텔스 유지 |
