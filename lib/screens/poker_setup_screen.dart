import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/poker_game.dart';
import 'poker_screen.dart';

class PokerSetupScreen extends StatefulWidget {
  const PokerSetupScreen({super.key});

  @override
  State<PokerSetupScreen> createState() => _PokerSetupScreenState();
}

class _PokerSetupScreenState extends State<PokerSetupScreen> {
  int _numBots = 2;
  AIDifficulty _difficulty = AIDifficulty.medium;

  static const _difficultyColors = {
    AIDifficulty.easy: Color(0xFF4ade80),
    AIDifficulty.medium: Color(0xFFfbbf24),
    AIDifficulty.hard: Color(0xFFf97316),
    AIDifficulty.master: Color(0xFFf43f5e),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final difficultyInfo =
        <AIDifficulty, ({String label, String desc, Color color})>{
      AIDifficulty.easy: (
        label: l.easyLabel,
        desc: l.easyDesc,
        color: _difficultyColors[AIDifficulty.easy]!,
      ),
      AIDifficulty.medium: (
        label: l.mediumLabel,
        desc: l.mediumDesc,
        color: _difficultyColors[AIDifficulty.medium]!,
      ),
      AIDifficulty.hard: (
        label: l.hardLabel,
        desc: l.hardDesc,
        color: _difficultyColors[AIDifficulty.hard]!,
      ),
      AIDifficulty.master: (
        label: l.masterLabel,
        desc: l.masterDesc,
        color: _difficultyColors[AIDifficulty.master]!,
      ),
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0d2015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d2015),
        title: const Text(
          "TEXAS HOLD'EM", // game name — not translated
          style: TextStyle(
            color: Color(0xFF4ade80),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF4ade80)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.opponents,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (i) {
                  final n = i + 1;
                  final selected = _numBots == n;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _numBots = n),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF4ade80)
                                : Colors.white24,
                            width: selected ? 2 : 1,
                          ),
                          color: selected
                              ? const Color(0xFF4ade80).withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.04),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? const Color(0xFF4ade80)
                                    : Colors.white54,
                              ),
                            ),
                            Text(
                              n == 1 ? l.botSingular : l.botPlural,
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? const Color(0xFF4ade80)
                                    : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Text(
                l.aiDifficulty,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              ...AIDifficulty.values.map((d) {
                final info = difficultyInfo[d]!;
                final selected = _difficulty == d;
                return GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? info.color : Colors.white24,
                        width: selected ? 2 : 1,
                      ),
                      color: selected
                          ? info.color.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.03),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? info.color : Colors.transparent,
                            border: Border.all(color: info.color, width: 2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.label,
                                style: TextStyle(
                                  color: selected ? info.color : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                info.desc,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokerScreen(
                      numBots: _numBots,
                      difficulty: _difficulty,
                    ),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF16a34a), Color(0xFF4ade80)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ade80).withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      l.startGame,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
