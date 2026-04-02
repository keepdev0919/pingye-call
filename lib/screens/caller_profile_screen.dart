import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../logic/caller_profile.dart';
import '../logic/trigger_manager.dart';

class CallerProfileScreen extends ConsumerStatefulWidget {
  const CallerProfileScreen({super.key});

  @override
  ConsumerState<CallerProfileScreen> createState() => _CallerProfileScreenState();
}

class _CallerProfileScreenState extends ConsumerState<CallerProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(triggerManagerProvider).callerProfile;
    _nameController = TextEditingController(text: profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(triggerManagerProvider.notifier).setCallerProfile(
          CallerProfile(name: name),
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
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
              decoration: const InputDecoration(
                labelText: '이름',
                labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                hintText: '엄마',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
