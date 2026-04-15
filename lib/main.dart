import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_navigator.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'logic/trigger_manager.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await FlutterCallkitIncoming.requestNotificationPermission({
    'rationaleMessagePermission': '전화 알림을 받으려면 알림 권한이 필요합니다.',
    'postNotificationMessageRequired': '알림 권한을 허용해주세요.',
  });

  runApp(
    const ProviderScope(child: PingyeApp()),
  );
}

class PingyeApp extends StatelessWidget {
  const PingyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pingye',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: buildAppTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      home: const _TapListenerRoot(),
    );
  }
}

class _TapListenerRoot extends ConsumerWidget {
  const _TapListenerRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(triggerManagerProvider.notifier).onTap(),
      child: const SettingsScreen(),
    );
  }
}
