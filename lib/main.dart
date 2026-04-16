import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

// Global locale notifier — changing this rebuilds the whole app with new locale
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

void main() => runApp(const CasinoApp());

class CasinoApp extends StatelessWidget {
  const CasinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) => MaterialApp(
        title: 'Casino Royale',
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1a472a),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
