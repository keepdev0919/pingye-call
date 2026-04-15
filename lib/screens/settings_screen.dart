import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/trigger_manager.dart';
import 'caller_profile_screen.dart';

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
    final l = AppLocalizations.of(context)!;
    final profile = ref.read(triggerManagerProvider).callerProfile;
    if (profile.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noNameSnackbar)),
      );
      return;
    }
    ref.read(triggerManagerProvider.notifier).startWaiting();
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
          l.navTitleNotifications,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 17,
            fontWeight: FontWeight.w400,
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

                        _SectionHeader(label: l.sectionCaller),
                        _NavCell(
                          label: state.callerProfile.name.isEmpty
                              ? l.nameNotSet
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

                        _SectionHeader(label: l.sectionTimer),
                        _TimerSection(
                          selected: _selectedDuration,
                          onSelected: _selectDuration,
                          enabled: true,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
              ),
            ),

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

class _ArmedView extends StatefulWidget {
  final Duration? remaining;

  const _ArmedView({super.key, required this.remaining});

  @override
  State<_ArmedView> createState() => _ArmedViewState();
}

class _ArmedViewState extends State<_ArmedView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _formatHero(Duration? d) {
    if (d == null) return '--:--';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Text(
              _formatHero(widget.remaining),
              style: const TextStyle(
                color: AppColors.accentArmed,
                fontSize: 64,
                fontWeight: FontWeight.w200,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.armedHint,
            style: const TextStyle(
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

  String _formatDuration(BuildContext context, Duration d) {
    final l = AppLocalizations.of(context)!;
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return l.durationSeconds(s);
    return s == 0 ? l.durationMinutes(m) : l.durationMinutesSeconds(m, s);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: state.isWaiting
            ? _WaitingButton(
                remaining: state.remaining,
                onCancel: onCancel,
                formatDuration: (d) => _formatDuration(context, d),
                waitingLabel: l.waitingLabel,
                waitingLabelNoTime: l.waitingLabelNoTime,
                cancelLabel: l.cancel,
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
                child: Text(
                  l.startButton,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
  final String Function(String) waitingLabel;
  final String waitingLabelNoTime;
  final String cancelLabel;

  const _WaitingButton({
    required this.remaining,
    required this.onCancel,
    required this.formatDuration,
    required this.waitingLabel,
    required this.waitingLabelNoTime,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = remaining != null
        ? waitingLabel(formatDuration(remaining!))
        : waitingLabelNoTime;

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
            child: Text(
              cancelLabel,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
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

  List<({String label, Duration duration})> _options(AppLocalizations l) => [
    (label: l.timer1Min, duration: const Duration(minutes: 1)),
    (label: l.timer5Min, duration: const Duration(minutes: 5)),
    (label: l.timer10Min, duration: const Duration(minutes: 10)),
    (label: l.timer30Min, duration: const Duration(minutes: 30)),
  ];

  bool _isCustomSelected(AppLocalizations l) =>
      !_options(l).any((o) => o.duration == widget.selected);

  String _customLabel(AppLocalizations l, Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return l.durationSeconds(s);
    return s == 0 ? l.durationMinutes(m) : l.durationMinutesSeconds(m, s);
  }

  Future<void> _showCustomDialog(AppLocalizations l) async {
    _controller.clear();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.customTimerDialogTitle),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.customTimerHint,
            suffixText: l.customTimerSuffix,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(_controller.text);
              if (v != null && v > 0 && v <= 3600) {
                Navigator.pop(ctx, v);
              }
            },
            child: Text(l.confirm),
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
    return Material(
      color: isSelected ? AppColors.accent : AppColors.background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.separator,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (enabled ? AppColors.textPrimary : AppColors.textSecondary),
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = _options(l);
    final isCustom = _isCustomSelected(l);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...options.map((opt) => _buildChip(
                label: opt.label,
                isSelected: widget.selected == opt.duration,
                enabled: widget.enabled,
                onTap: widget.enabled ? () => widget.onSelected(opt.duration) : null,
              )),
          _buildChip(
            label: isCustom ? _customLabel(l, widget.selected) : l.customTimerChip,
            isSelected: isCustom,
            enabled: widget.enabled,
            onTap: widget.enabled ? () => _showCustomDialog(l) : null,
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
    return Material(
      color: AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        splashColor: AppColors.accent.withValues(alpha: 0.08),
        highlightColor: AppColors.accent.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
