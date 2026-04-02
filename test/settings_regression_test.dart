// Regression tests for UI changes applied 2026-04-02:
//   1. 예약 타이머 "기타" chip + 초단위 입력 다이얼로그
//   2. 제스처 설정 셀 제거
//   3. 진동 피드백 토글 제거
// Report: ~/.gstack/projects/pingye_call/unknown-plan-20260402-172928.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingye_call/main.dart';

void main() {
  group('Settings screen — timer chips', () {
    testWidgets('모든 프리셋 chip과 기타 chip이 표시된다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      expect(find.text('1분'), findsOneWidget);
      expect(find.text('5분'), findsOneWidget);
      expect(find.text('10분'), findsOneWidget);
      expect(find.text('30분'), findsOneWidget);
      expect(find.text('기타'), findsOneWidget);
    });

    testWidgets('기타 chip을 탭하면 직접 입력 다이얼로그가 열린다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();
      expect(find.text('직접 입력'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('유효한 초 입력 시 기타 chip이 해당 값으로 업데이트된다', (tester) async {
      // Regression: custom duration chip highlight was broken because
      // isSelected = (selected == preset) never matches a custom Duration.
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '45');
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      // chip label becomes "45초", original "기타" label disappears
      expect(find.text('45초'), findsOneWidget);
      expect(find.text('기타'), findsNothing);
    });

    testWidgets('0 입력 시 다이얼로그가 닫히지 않는다', (tester) async {
      // Regression: Duration(seconds: 0) would fire the countdown timer
      // immediately, triggering the fake call before the user is ready.
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      // dialog must remain open
      expect(find.text('직접 입력'), findsOneWidget);
    });

    testWidgets('빈 입력값으로 확인 탭 시 다이얼로그가 닫히지 않는다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.text('직접 입력'), findsOneWidget);
    });

    testWidgets('취소 탭 시 다이얼로그가 닫히고 기존 선택이 유지된다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();
      // dialog is open
      expect(find.text('직접 입력'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      // dialog closed, no selection change
      expect(find.text('직접 입력'), findsNothing);
      expect(find.text('5분'), findsOneWidget); // default selection intact
      expect(find.text('기타'), findsOneWidget); // label unchanged
    });
  });

  group('Settings screen — 제거된 항목', () {
    testWidgets('제스처 설정 셀이 표시되지 않는다', (tester) async {
      // Regression: gesture settings NavCell was removed in this PR.
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      expect(find.text('제스처 설정'), findsNothing);
    });

    testWidgets('진동 피드백 토글이 표시되지 않는다', (tester) async {
      // Regression: vibration feedback ToggleCell was removed in this PR.
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      expect(find.text('진동 피드백'), findsNothing);
    });

    testWidgets('옵션 섹션 헤더가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PingyeApp()));
      expect(find.text('OPTIONS'), findsNothing);
      expect(find.text('옵션'), findsNothing);
    });
  });
}
