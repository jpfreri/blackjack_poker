import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/poker_game.dart';
import '../models/hand_evaluator.dart';
import '../widgets/card_widget.dart';
import 'home_screen.dart';
import 'poker_setup_screen.dart';

class PokerScreen extends StatefulWidget {
  final int numBots;
  final AIDifficulty difficulty;

  const PokerScreen({super.key, required this.numBots, required this.difficulty});

  @override
  State<PokerScreen> createState() => _PokerScreenState();
}

class _PokerScreenState extends State<PokerScreen>
    with SingleTickerProviderStateMixin {
  late AppLocalizations _l;
  late PokerGame _game;
  bool _aiThinking = false;
  int _raiseAmount = 0;

  late AnimationController _deckPulse;
  late Animation<double> _glowAnim;

  // Tracks how many community cards have been "shown" with animation
  int _shownCommunityCount = 0;

  @override
  void initState() {
    super.initState();
    _game = PokerGame(
      numBots: widget.numBots,
      difficulty: widget.difficulty,
    );
    _game.startNewHand();
    _raiseAmount = _game.bigBlind;

    _deckPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.1, end: 0.45).animate(
      CurvedAnimation(parent: _deckPulse, curve: Curves.easeInOut),
    );

    _maybeRunAI();
  }

  @override
  void dispose() {
    _deckPulse.dispose();
    super.dispose();
  }

  void _maybeRunAI() {
    if (_game.roundOver || _game.isHumanTurn) return;
    if (_game.players.isEmpty) return;

    final player = _game.players[_game.currentPlayerIndex];
    if (player.isHuman) return;

    _aiThinking = true;
    final delay = 700 + (500 * (player.difficulty == AIDifficulty.easy ? 0 : 1));
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final action = _game.getAIAction(player);
      final raiseExtra = _game.getAIRaiseExtra(player);
      setState(() {
        _game.performAction(action, raiseExtra: raiseExtra);
        _aiThinking = false;
      });
      _animateNewCommunityCards();
      _maybeRunAI();
    });
  }

  void _doAction(PlayerAction action, {int raiseExtra = 0}) {
    if (!_game.isHumanTurn) return;
    setState(() {
      _game.performAction(action, raiseExtra: raiseExtra);
    });
    _animateNewCommunityCards();
    _maybeRunAI();
  }

  void _animateNewCommunityCards() {
    final newCount = _game.communityCards.length;
    if (newCount > _shownCommunityCount) {
      _dealCommunityCards(newCount);
    }
  }

  Future<void> _dealCommunityCards(int targetCount) async {
    for (int i = _shownCommunityCount; i < targetCount; i++) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() => _shownCommunityCount = i + 1);
    }
  }

  void _startNextHand() {
    setState(() {
      if (_game.players.length < 2) return;
      _game.startNewHand();
      _raiseAmount = _game.bigBlind;
      _shownCommunityCount = 0;
    });
    _maybeRunAI();
  }

  @override
  Widget build(BuildContext context) {
    _l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1a472a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d2015),
        title: Text(
          _phaseName(),
          style: const TextStyle(
            color: Color(0xFF4ade80),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4ade80)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PokerSetupScreen()),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '\$${_game.humanPlayer.chips}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _opponentsArea(),
                  _communityArea(),
                  _logArea(),
                  _playerArea(),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  String _phaseName() {
    switch (_game.phase) {
      case PokerPhase.preflop:
        return _l.preflop;
      case PokerPhase.flop:
        return _l.flop;
      case PokerPhase.turn:
        return _l.turn;
      case PokerPhase.river:
        return _l.river;
      case PokerPhase.showdown:
        return _l.showdown;
    }
  }

  Widget _opponentsArea() {
    final bots = _game.players.where((p) => !p.isHuman).toList();
    return Container(
      color: const Color(0xFF0d2015),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: bots.map((p) => _opponentCard(p)).toList(),
      ),
    );
  }

  Widget _opponentCard(PokerPlayer p) {
    final isCurrent = !_game.roundOver &&
        _game.currentPlayerIndex < _game.players.length &&
        _game.players[_game.currentPlayerIndex] == p;

    final isWinner = _game.roundOver &&
        p.handResult != null &&
        _game.activePlayers.isNotEmpty &&
        p == _game.activePlayers.reduce((a, b) {
          final aResult = a.handResult ??
              const HandResult(
                rank: HandRank.highCard,
                tiebreakers: [],
              );
          final bResult = b.handResult ??
              const HandResult(
                rank: HandRank.highCard,
                tiebreakers: [],
              );
          return aResult.compareTo(bResult) >= 0 ? a : b;
        });

    Color borderColor = Colors.white24;
    if (isCurrent && _aiThinking) borderColor = Colors.amber;
    if (p.folded) borderColor = Colors.white12;
    if (isWinner) borderColor = const Color(0xFF4ade80);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
        color: p.folded
            ? Colors.black.withValues(alpha: 0.3)
            : isCurrent
                ? Colors.amber.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.name,
                style: TextStyle(
                  color: p.folded ? Colors.white24 : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (p.isDealer)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'D',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: p.holeCards
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: CardWidget(card: c, width: 32, height: 46),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${p.chips}',
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10),
          ),
          if (p.lastActionLabel != null)
            Text(
              _translateAction(p.lastActionLabel),
              style: TextStyle(
                color: p.folded ? Colors.white24 : Colors.white54,
                fontSize: 9,
              ),
            ),
          if (p.handResult != null && _game.roundOver)
            Text(
              _translateHandRank(p.handResult!.rank.name),
              style: TextStyle(
                color: isWinner ? const Color(0xFF4ade80) : Colors.white38,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  // ── Deck widget ──────────────────────────────────────────────────────────────

  Widget _deckWidget() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          width: 48,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: _glowAnim.value),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Card layers (stacked slightly)
              for (int i = 3; i >= 0; i--)
                Positioned(
                  left: i * 0.5,
                  top: i * 0.5,
                  child: Container(
                    width: 46,
                    height: 66,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFF1e3a5f),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              // Top card with pattern
              Positioned(
                left: 2,
                top: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CustomPaint(
                    size: const Size(46, 66),
                    painter: _PokerDeckPatternPainter(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Community area ───────────────────────────────────────────────────────────

  Widget _communityArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          // Pot / bet badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_l.potLabel}: \$${_game.pot}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_game.currentBet > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_l.betLabel}: \$${_game.currentBet}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // Deck + community cards on the same row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _deckWidget(),
              const SizedBox(width: 14),
              // Community card slots
              ...List.generate(5, (i) {
                final hasCard = i < _game.communityCards.length;
                final isVisible = i < _shownCommunityCount;

                if (hasCard && isVisible) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('community_$i'),
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * -30),
                          child: Transform.scale(
                            scale: 0.6 + value * 0.4,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: CardWidget(
                        card: _game.communityCards[i],
                        width: 50,
                        height: 72,
                      ),
                    ),
                  );
                }

                // Placeholder
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 50,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logArea() {
    if (_game.actionLog.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _game.actionLog
            .reversed
            .take(3)
            .map((entry) => Text(
                  _translateLog(entry),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ))
            .toList(),
      ),
    );
  }

  Widget _playerArea() {
    final p = _game.humanPlayer;
    final isTurn = _game.isHumanTurn;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTurn ? const Color(0xFF4ade80) : Colors.white24,
          width: isTurn ? 2 : 1,
        ),
        color: isTurn
            ? const Color(0xFF4ade80).withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (p.isDealer)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'D',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (p.isSmallBlind)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('SB', style: TextStyle(color: Colors.white, fontSize: 9)),
                    ),
                  if (p.isBigBlind)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('BB', style: TextStyle(color: Colors.white, fontSize: 9)),
                    ),
                ],
              ),
              Text(
                '\$${p.chips}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: p.holeCards
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CardWidget(card: c, width: 64, height: 90),
                    ))
                .toList(),
          ),
          if (p.handResult != null && _game.roundOver) ...[
            const SizedBox(height: 8),
            Text(
              _translateHandRank(p.handResult!.rank.name),
              style: const TextStyle(
                color: Color(0xFF4ade80),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottomBar() {
    if (_game.roundOver) return _nextHandButton();
    if (!_game.isHumanTurn) return _waitingBar();
    return _actionBar();
  }

  Widget _waitingBar() {
    return Container(
      color: const Color(0xFF0d2015),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          _aiThinking ? _l.thinking : _l.waiting,
          style: const TextStyle(color: Colors.white38, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _actionBar() {
    final canCheck = _game.canCheck;
    final callAmt = _game.callAmount;
    final humanChips = _game.humanPlayer.chips;
    final canRaise = humanChips > callAmt && humanChips > 0;

    // Clamp _raiseAmount to valid range
    final minRaise = _game.bigBlind;
    final maxRaise = humanChips;
    final clampedRaise = _raiseAmount.clamp(minRaise, maxRaise);

    // 2×BB total: currentBet + bigBlind
    final twoBbTotal = _game.currentBet + _game.bigBlind;
    final canAfford2Bb = humanChips >= (_game.bigBlind - _game.humanPlayer.currentBet);

    return Container(
      color: const Color(0xFF0d2015),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: FOLD | CHECK/CALL | 2×BB | MAX BET
          Row(
            children: [
              Expanded(
                child: _pokerBtn(
                  _l.fold,
                  const Color(0xFFf43f5e),
                  () => _doAction(PlayerAction.fold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: canCheck
                    ? _pokerBtn(
                        _l.checkAction,
                        const Color(0xFF4ade80),
                        () => _doAction(PlayerAction.check),
                      )
                    : _pokerBtn(
                        '${_l.callBtn} \$$callAmt',
                        callAmt <= humanChips
                            ? const Color(0xFF4ade80)
                            : Colors.grey,
                        callAmt <= humanChips
                            ? () => _doAction(PlayerAction.call)
                            : null,
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pokerBtn(
                  '${_l.twoBB} \$$twoBbTotal',
                  const Color(0xFF818cf8),
                  canAfford2Bb
                      ? () => setState(() => _raiseAmount = twoBbTotal)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pokerBtn(
                  _l.maxBet,
                  const Color(0xFFFFD700),
                  humanChips > 0
                      ? () => _doAction(PlayerAction.allIn)
                      : null,
                ),
              ),
            ],
          ),
          // Row 2: Custom raise row (only if canRaise)
          if (canRaise) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                // Minus button
                GestureDetector(
                  onTap: () => setState(() {
                    _raiseAmount = max(clampedRaise - 10, minRaise);
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1.5),
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: const Center(
                      child: Text(
                        '−',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Raise amount display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF818cf8), width: 1),
                      color: const Color(0xFF818cf8).withValues(alpha: 0.08),
                    ),
                    child: Center(
                      child: Text(
                        '${_l.raiseLabel}: \$$clampedRaise',
                        style: const TextStyle(
                          color: Color(0xFF818cf8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Plus button
                GestureDetector(
                  onTap: () => setState(() {
                    _raiseAmount = min(clampedRaise + 10, maxRaise);
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1.5),
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: const Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // RAISE button
                Expanded(
                  child: _pokerBtn(
                    '${_l.raiseBtn} \$$clampedRaise',
                    const Color(0xFF818cf8),
                    () => _doAction(PlayerAction.raise, raiseExtra: clampedRaise),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _translateAction(String? code) {
    if (code == null) return '';
    final parts = code.split('|');
    switch (parts[0]) {
      case 'FOLD':
        return _l.actionFold;
      case 'CHECK':
        return _l.actionCheck;
      case 'CALL':
        return '${_l.actionCall} \$${parts.length > 1 ? parts[1] : ''}';
      case 'RAISE':
        return '${_l.actionRaise} \$${parts.length > 1 ? parts[1] : ''}';
      case 'ALLIN':
        return '${_l.actionAllIn} \$${parts.length > 1 ? parts[1] : ''}';
      case 'SB':
        return 'SB \$${parts.length > 1 ? parts[1] : ''}';
      case 'BB':
        return 'BB \$${parts.length > 1 ? parts[1] : ''}';
      default:
        return code;
    }
  }

  String _translateLog(String entry) {
    final parts = entry.split('|');
    switch (parts[0]) {
      case 'FOLD':
        return '${parts.length > 1 ? parts[1] : ''} ${_l.actionFold.toLowerCase()}';
      case 'CHECK':
        return '${parts.length > 1 ? parts[1] : ''} ${_l.actionCheck.toLowerCase()}';
      case 'CALL':
        return '${parts.length > 1 ? parts[1] : ''} ${_l.actionCall.toLowerCase()} \$${parts.length > 2 ? parts[2] : ''}';
      case 'RAISE':
        return '${parts.length > 1 ? parts[1] : ''} ${_l.actionRaise.toLowerCase()} \$${parts.length > 2 ? parts[2] : ''}';
      case 'ALLIN':
        return '${parts.length > 1 ? parts[1] : ''} ${_l.actionAllIn.toLowerCase()} \$${parts.length > 2 ? parts[2] : ''}';
      case 'WINS':
        return _l.logWins(
          parts.length > 1 ? parts[1] : '',
          parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
        );
      case 'WINS_HAND':
        return _l.logWinsWith(
          parts.length > 1 ? parts[1] : '',
          parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
          parts.length > 3 ? _translateHandRank(parts[3]) : '',
        );
      case 'SPLIT':
        return _l.logSplit(
          parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
          parts.length > 2 ? parts[2] : '',
        );
      default:
        return entry;
    }
  }

  String _translateHandRank(String rankEnumName) {
    switch (rankEnumName) {
      case 'highCard':       return _l.handHighCard;
      case 'onePair':        return _l.handOnePair;
      case 'twoPair':        return _l.handTwoPair;
      case 'threeOfAKind':   return _l.handThreeOfAKind;
      case 'straight':       return _l.handStraight;
      case 'flush':          return _l.handFlush;
      case 'fullHouse':      return _l.handFullHouse;
      case 'fourOfAKind':    return _l.handFourOfAKind;
      case 'straightFlush':  return _l.handStraightFlush;
      case 'royalFlush':     return _l.handRoyalFlush;
      default:               return rankEnumName;
    }
  }

  Widget _pokerBtn(String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: onTap != null ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
          border: Border.all(
            color: onTap != null ? color : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onTap != null ? color : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _nextHandButton() {
    final humanAlive = _game.humanPlayer.chips > 0;
    final enoughPlayers = _game.players.where((p) => p.chips > 0).length >= 2;

    return Container(
      color: const Color(0xFF0d2015),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_game.actionLog.isNotEmpty)
            Text(
              _translateLog(_game.actionLog.last),
              style: const TextStyle(
                color: Color(0xFF4ade80),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
          if (!humanAlive)
            _pokerBtn(_l.bustLeave, const Color(0xFFf43f5e), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            })
          else if (!enoughPlayers)
            _pokerBtn(_l.youWin, const Color(0xFFFFD700), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PokerSetupScreen()),
              );
            })
          else
            _pokerBtn(_l.nextHand, const Color(0xFF4ade80), _startNextHand),
        ],
      ),
    );
  }
}

// ── Deck pattern painter ─────────────────────────────────────────────────────

class _PokerDeckPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF1e3a5f);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(5),
      ),
      bg,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    // Grid lines
    const step = 7.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Inner border frame
    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(4, 4, size.width - 4, size.height - 4),
        const Radius.circular(3),
      ),
      framePaint,
    );

    // Center diamond
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 7.0;
    final diamondPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();
    canvas.drawPath(path, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
