import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../logic/trigger_manager.dart';
import 'caller_profile_screen.dart';

// Stealth branding: nav bar shows lowercase "pingye" — not "핑계콜".
// When the phone is face-up on a table, bystanders see a neutral, unremarkable title.
const _kNavTitle = 'pingye';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Duration _selectedDuration = const Duration(minutes: 5);

  void _selectDuration(Duration d) {
    setState(() => _selectedDuration = d);
    ref.read(triggerManagerProvider.notifier).setSelectedDuration(d);
  }

  Future<void> _onStartWaiting() async {
    final profile = ref.read(triggerManagerProvider).callerProfile;
    if (profile.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('발신자 이름을 먼저 설정해주세요')),
      );
      return;
    }
    ref.read(triggerManagerProvider.notifier).startWaiting();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(triggerManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          _kNavTitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 20),

                  // Section 1: Trigger
                  const _SectionHeader(label: '트리거'),
                  _TimerSection(
                    selected: _selectedDuration,
                    onSelected: _selectDuration,
                    enabled: !state.isWaiting,
                  ),

                  const SizedBox(height: 20),

                  // Section 2: Caller
                  const _SectionHeader(label: '발신자'),
                  _NavCell(
                    label: state.callerProfile.name,
                    subtitle: state.callerProfile.number,
                    enabled: !state.isWaiting,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CallerProfileScreen()),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // CTA — pinned at bottom
            _CTASection(
              state: state,
              onStart: _onStartWaiting,
              onCancel: () {
                ref.read(triggerManagerProvider.notifier).cancelWaiting();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  final TriggerState state;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const _CTASection({
    required this.state,
    required this.onStart,
    required this.onCancel,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '$s초';
    return s == 0 ? '$m분' : '$m분 $s초';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: state.isWaiting
            ? _WaitingButton(
                remaining: state.remaining,
                onCancel: onCancel,
                formatDuration: _formatDuration,
              )
            : ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '대기 시작',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }
}

class _WaitingButton extends StatelessWidget {
  final Duration? remaining;
  final VoidCallback onCancel;
  final String Function(Duration) formatDuration;

  const _WaitingButton({
    required this.remaining,
    required this.onCancel,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        remaining != null ? '⏱ ${formatDuration(remaining!)} 후 전화 예정' : '대기 중...';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  final Duration selected;
  final ValueChanged<Duration> onSelected;
  final bool enabled;

  const _TimerSection({
    required this.selected,
    required this.onSelected,
    required this.enabled,
  });

  static const _options = [
    (label: '1분', duration: Duration(minutes: 1)),
    (label: '5분', duration: Duration(minutes: 5)),
    (label: '10분', duration: Duration(minutes: 10)),
    (label: '30분', duration: Duration(minutes: 30)),
  ];

  bool get _isCustomSelected =>
      !_options.any((o) => o.duration == selected);

  String _customLabel(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '$s초';
    return s == 0 ? '$m분' : '$m분 $s초';
  }

  Future<void> _showCustomDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('직접 입력'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '예: 45',
            suffixText: '초',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v > 0) {
                Navigator.pop(ctx, v);
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (result != null) {
      onSelected(Duration(seconds: result));
    }
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.separator,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (onTap != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary),
            fontSize: 15,
            fontWeight:
                isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예약 타이머',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 17)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._options.map((opt) => _buildChip(
                    context,
                    label: opt.label,
                    isSelected: selected == opt.duration,
                    onTap: enabled ? () => onSelected(opt.duration) : null,
                  )),
              _buildChip(
                context,
                label:
                    _isCustomSelected ? _customLabel(selected) : '기타',
                isSelected: _isCustomSelected,
                onTap: enabled ? () => _showCustomDialog(context) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _NavCell({
    required this.label,
    this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 17,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:
                  enabled ? AppColors.textSecondary : AppColors.dotEmpty,
              size: 20,
            ),
          ],
        ),
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
          color: AppColors.textSecondary,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
