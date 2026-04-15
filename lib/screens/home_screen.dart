import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import 'blackjack_screen.dart';
import 'poker_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final s = AppStrings(locale);
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0d2818), Color(0xFF1a472a), Color(0xFF0d2015)],
                stops: [0, 0.5, 1],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'CASINO ROYALE',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                        letterSpacing: 5,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '♠  ♥  ♦  ♣',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 56),
                    _GameCard(
                      title: 'BLACKJACK',
                      subtitle: s.bjSubtitle,
                      icon: '🃏',
                      accentColor: const Color(0xFFFFD700),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BlackjackScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _GameCard(
                      title: "TEXAS HOLD'EM",
                      subtitle: s.pokerSubtitle,
                      icon: '♠',
                      accentColor: const Color(0xFF4ade80),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PokerSetupScreen()),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // ── Language picker ──────────────────────────────────────
                    Text(
                      s.languageLabel,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LangButton(
                          flag: '🇺🇸',
                          code: 'EN',
                          target: AppLocale.en,
                          current: locale,
                        ),
                        const SizedBox(width: 10),
                        _LangButton(
                          flag: '🇧🇷',
                          code: 'PT',
                          target: AppLocale.pt,
                          current: locale,
                        ),
                        const SizedBox(width: 10),
                        _LangButton(
                          flag: '🇪🇸',
                          code: 'ES',
                          target: AppLocale.es,
                          current: locale,
                        ),
                        const SizedBox(width: 10),
                        _LangButton(
                          flag: '🇫🇷',
                          code: 'FR',
                          target: AppLocale.fr,
                          current: locale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Language button ─────────────────────────────────────────────────────────

class _LangButton extends StatelessWidget {
  final String flag;
  final String code;
  final AppLocale target;
  final AppLocale current;

  const _LangButton({
    required this.flag,
    required this.code,
    required this.target,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == target;
    return GestureDetector(
      onTap: () => localeNotifier.value = target,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? const Color(0xFFFFD700)
                : Colors.white.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
          color: selected
              ? const Color(0xFFFFD700).withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              code,
              style: TextStyle(
                color: selected ? const Color(0xFFFFD700) : Colors.white54,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Game card ───────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: accentColor.withOpacity(0.5), width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.15),
              accentColor.withOpacity(0.04),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: accentColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
