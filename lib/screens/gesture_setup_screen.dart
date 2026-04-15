import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/tap_sequence_detector.dart';
import '../logic/trigger_manager.dart';

class GestureSetupScreen extends ConsumerStatefulWidget {
  const GestureSetupScreen({super.key});

  @override
  ConsumerState<GestureSetupScreen> createState() => _GestureSetupScreenState();
}

class _GestureSetupScreenState extends ConsumerState<GestureSetupScreen> {
  late TapSequenceDetector _liveDetector;
  int _liveCount = 0;
  bool _isFlash = false;

  @override
  void initState() {
    super.initState();
    final tapTarget = ref.read(triggerManagerProvider).tapTarget;
    _initLiveDetector(tapTarget);
  }

  void _initLiveDetector(int target) {
    _liveDetector = TapSequenceDetector(
      targetCount: target,
      onTriggered: _onLiveTriggered,
      onCountChanged: (count) {
        if (mounted) setState(() => _liveCount = count);
      },
    );
  }

  void _onLiveTriggered() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isFlash = true;
      _liveCount = 0;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isFlash = false);
    });
  }

  void _setTapTarget(int value) {
    ref.read(triggerManagerProvider.notifier).setTapTarget(value);
    _liveDetector.dispose();
    _initLiveDetector(value);
    setState(() {
      _liveCount = 0;
      _isFlash = false;
    });
  }

  @override
  void dispose() {
    _liveDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(triggerManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l.gestureNavTitle,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.accent, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _LiveTestArea(
              tapTarget: state.tapTarget,
              liveCount: _liveCount,
              isFlash: _isFlash,
              onTap: _liveDetector.onTap,
              completeLabel: l.gestureTestComplete,
              hintLabel: l.gestureTestHint,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SectionHeader(label: l.sectionTapCount),
                  _TapCountStepper(
                    value: state.tapTarget,
                    onChanged: _setTapTarget,
                    tapCountLabel: l.tapCountLabel,
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(label: l.sectionExtraTrigger),
                  _SettingsCell(
                    label: l.volumeButtonLabel,
                    subtitle: l.volumeButtonSubtitle,
                    value: state.volumeButtonEnabled,
                    onChanged: (v) =>
                        ref.read(triggerManagerProvider.notifier).setVolumeButtonEnabled(v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTestArea extends StatelessWidget {
  final int tapTarget;
  final int liveCount;
  final bool isFlash;
  final VoidCallback onTap;
  final String completeLabel;
  final String hintLabel;

  const _LiveTestArea({
    required this.tapTarget,
    required this.liveCount,
    required this.isFlash,
    required this.onTap,
    required this.completeLabel,
    required this.hintLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.45,
        width: double.infinity,
        color: AppColors.backgroundSecondary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tapTarget, (i) {
                final isFilled = i < liveCount;
                final color = isFlash
                    ? Colors.green
                    : (isFilled ? AppColors.dotFilled : AppColors.dotEmpty);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              isFlash ? completeLabel : hintLabel,
              style: TextStyle(
                color: isFlash ? Colors.green : AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapCountStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String tapCountLabel;

  const _TapCountStepper({
    required this.value,
    required this.onChanged,
    required this.tapCountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(tapCountLabel,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 17)),
          const Spacer(),
          IconButton(
            onPressed: value > 2 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: value > 2 ? AppColors.accent : AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: value < 10 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: value < 10 ? AppColors.accent : AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5),
      ),
    );
  }
}

class _SettingsCell extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsCell({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 17)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
