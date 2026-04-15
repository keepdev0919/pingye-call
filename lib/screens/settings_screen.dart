import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../logic/trigger_manager.dart';
import 'caller_profile_screen.dart';

const _kNavTitle = '알림';

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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: state.isWaiting
                  ? _ArmedView(key: const ValueKey('armed'), remaining: state.remaining)
                  : ListView(
                      key: const ValueKey('idle'),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 20),

                        // Section 1: Caller (필수 입력 먼저)
                        const _SectionHeader(label: '발신자'),
                        _NavCell(
                          label: state.callerProfile.name.isEmpty
                              ? '이름 설정 필요'
                              : state.callerProfile.name,
                          enabled: true,
                          isHint: state.callerProfile.name.isEmpty,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CallerProfileScreen()),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section 2: Timer
                        const _SectionHeader(label: '예약 시간'),
                        _TimerSection(
                          selected: _selectedDuration,
                          onSelected: _selectDuration,
                          enabled: true,
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

// 대기 중 상태 — 중앙 카운트다운 hero
class _ArmedView extends StatelessWidget {
  final Duration? remaining;

  const _ArmedView({required this.remaining});

  String _formatHero(Duration? d) {
    if (d == null) return '--:--';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatHero(remaining),
            style: const TextStyle(
              color: AppColors.accentArmed,
              fontSize: 64,
              fontWeight: FontWeight.w200,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '화면 어디든 탭하면 즉시 전화',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
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
    final label = remaining != null ? '예약됨 — ${formatDuration(remaining!)} 후 전화' : '대기 중...';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentArmed.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.accentArmed,
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

class _TimerSection extends StatefulWidget {
  final Duration selected;
  final ValueChanged<Duration> onSelected;
  final bool enabled;

  const _TimerSection({
    required this.selected,
    required this.onSelected,
    required this.enabled,
  });

  @override
  State<_TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<_TimerSection> {
  late final TextEditingController _controller;

  static const _options = [
    (label: '1분', duration: Duration(minutes: 1)),
    (label: '5분', duration: Duration(minutes: 5)),
    (label: '10분', duration: Duration(minutes: 10)),
    (label: '30분', duration: Duration(minutes: 30)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isCustomSelected =>
      !_options.any((o) => o.duration == widget.selected);

  String _customLabel(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '$s초';
    return s == 0 ? '$m분' : '$m분 $s초';
  }

  Future<void> _showCustomDialog() async {
    _controller.clear();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('직접 입력'),
        content: TextField(
          controller: _controller,
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
              final v = int.tryParse(_controller.text);
              if (v != null && v > 0 && v <= 3600) {
                Navigator.pop(ctx, v);
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      widget.onSelected(Duration(seconds: result));
    }
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                : (enabled
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
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._options.map((opt) => _buildChip(
                    label: opt.label,
                    isSelected: widget.selected == opt.duration,
                    enabled: widget.enabled,
                    onTap: widget.enabled
                        ? () => widget.onSelected(opt.duration)
                        : null,
                  )),
              _buildChip(
                label: _isCustomSelected
                    ? _customLabel(widget.selected)
                    : '직접 입력...',
                isSelected: _isCustomSelected,
                enabled: widget.enabled,
                onTap: widget.enabled ? _showCustomDialog : null,
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
  final bool enabled;
  final bool isHint;
  final VoidCallback onTap;

  const _NavCell({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.isHint = false,
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
              child: Text(
                label,
                style: TextStyle(
                  color: isHint
                      ? AppColors.textSecondary
                      : (enabled ? AppColors.textPrimary : AppColors.textSecondary),
                  fontSize: 17,
                ),
              ),
            ),
            if (isHint)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.error_outline, color: AppColors.error, size: 16),
              ),
            Icon(
              Icons.chevron_right,
              color: enabled ? AppColors.textSecondary : AppColors.dotEmpty,
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
