import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../logic/caller_profile.dart';
import '../logic/trigger_manager.dart';

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CallerProfileScreen extends ConsumerStatefulWidget {
  const CallerProfileScreen({super.key});

  @override
  ConsumerState<CallerProfileScreen> createState() => _CallerProfileScreenState();
}

class _CallerProfileScreenState extends ConsumerState<CallerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(triggerManagerProvider).callerProfile;
    _nameController = TextEditingController(text: profile.name);
    _numberController = TextEditingController(text: profile.number);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();
    if (name.isEmpty) return;
    ref.read(triggerManagerProvider.notifier).setCallerProfile(
          CallerProfile(name: name, number: number),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('발신자'),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.accent, fontSize: 17),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              _buildField(
                controller: _nameController,
                label: '이름',
                placeholder: '엄마',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _numberController,
                label: '번호',
                placeholder: '010-0000-0000',
                keyboardType: TextInputType.phone,
                inputFormatters: [_PhoneNumberFormatter()],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool autofocus = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          hintText: placeholder,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
