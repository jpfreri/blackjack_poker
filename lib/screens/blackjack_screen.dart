import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/blackjack_game.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';
import 'home_screen.dart';

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key});

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen>
    with SingleTickerProviderStateMixin {
  final BlackjackGame _game = BlackjackGame(playerChips: 1000);
  int _selectedSlot = 0;
  int _selectedChip = 5; // currently highlighted chip denomination

  // ── Animation state ──────────────────────────────────────────────────────
  int _visibleCardCount = 0;
  bool _isDealingCards = false;

  // Deck glow pulse
  late final AnimationController _deckPulse;
  late final Animation<double> _glowAnim;

  // ── Chip config ───────────────────────────────────────────────────────────
  static const List<int> _chipValues = [5, 10, 25, 50, 100];
  static const List<Color> _chipColors = [
    Color(0xFFDC2626),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF111827),
    Color(0xFF7C3AED),
  ];

  // ── Localization ──────────────────────────────────────────────────────────
  late AppLocalizations _l;

  // ── Life-cycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _deckPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.15, end: 0.55).animate(
      CurvedAnimation(parent: _deckPulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _deckPulse.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _bet(int amount) {
    setState(() => _game.placeBet(_selectedSlot, amount));
  }

  void _doubleBet() {
    setState(() => _game.doubleBet(_selectedSlot));
  }

  void _allIn() {
    setState(() => _game.allIn(_selectedSlot));
  }

  void _clearBet() {
    setState(() => _game.clearBet(_selectedSlot));
  }

  void _clearAllBets() {
    setState(() => _game.clearAllBets());
  }

  Future<void> _deal() async {
    _game.deal();
    final N = _game.activeSlots.length;
    setState(() {
      _visibleCardCount = 0;
      _isDealingCards = true;
    });
    // Deal sequence: slot[0..N-1] card 0, dealer card 0,
    //                slot[0..N-1] card 1, dealer card 1
    final totalSteps = N * 2 + 2;
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 230));
      if (!mounted) return;
      setState(() => _visibleCardCount = i);
    }
    if (mounted) setState(() => _isDealingCards = false);
  }

  void _hit() {
    setState(() => _game.hit());
  }

  void _stand() {
    setState(() => _game.stand());
  }

  void _double() {
    setState(() => _game.doubleDown());
  }

  void _newRound() {
    setState(() {
      _game.newRound();
      _visibleCardCount = 0;
      _isDealingCards = false;
    });
    if (_game.isBust) _showBustDialog();
  }

  void _showBustDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0d2015),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _l.bust,
          style: const TextStyle(
            color: Color(0xFFf43f5e),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          _l.bustMsg,
          style: const TextStyle(color: Colors.white70, height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf43f5e),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: Text(
              _l.leaveTable,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  // ── Visibility helpers ────────────────────────────────────────────────────
  bool _slotCardVisible(int globalIdx, int cardIdx) {
    if (!_isDealingCards) return true;
    final active = _game.activeSlots;
    final n = active.length;
    final ai = active.indexOf(_game.slots[globalIdx]);
    if (ai == -1) return false;
    if (cardIdx == 0) return _visibleCardCount >= ai + 1;
    if (cardIdx == 1) return _visibleCardCount >= n + ai + 2;
    return true; // hit cards always show
  }

  bool _dealerCardVisible(int cardIdx) {
    if (!_isDealingCards) return true;
    final n = _game.activeSlots.length;
    if (cardIdx == 0) return _visibleCardCount >= n + 1;
    if (cardIdx == 1) return _visibleCardCount >= n * 2 + 2;
    return true;
  }

  // ── Result helpers ────────────────────────────────────────────────────────
  Color _resultColor(SlotResult? r) {
    switch (r) {
      case SlotResult.win:
      case SlotResult.blackjack:
        return Colors.greenAccent;
      case SlotResult.lose:
        return Colors.redAccent;
      case SlotResult.push:
        return Colors.amber;
      default:
        return Colors.transparent;
    }
  }

  String _resultText(SlotResult? r) {
    switch (r) {
      case SlotResult.win:
        return _l.win;
      case SlotResult.lose:
        return _l.lose;
      case SlotResult.push:
        return _l.push;
      case SlotResult.blackjack:
        return 'BJ!';
      default:
        return '';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1a472a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d2015),
        title: const Text(
          'BLACKJACK', // game name — not translated
          style: TextStyle(
            color: Color(0xFFFFD700),
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '\$${_game.playerChips}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _dealerArea(),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: Column(
              children: [
                // Deck occupies the middle space
                Expanded(
                  child: Center(child: _deckWidget()),
                ),
                // 3+2 slot grid sits below the deck
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _slotsGrid(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          _controlArea(),
        ],
      ),
    );
  }

  // ── Dealer area ───────────────────────────────────────────────────────────
  Widget _dealerArea() {
    return Container(
      color: const Color(0xFF0d2015),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Text(
            _l.dealer,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _game.dealerCards.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: _animatedCard(
                        _game.dealerCards[i],
                        _dealerCardVisible(i),
                        width: 44,
                        height: 62,
                        dealOrder: i,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_game.dealerCards.isNotEmpty && _dealerCardVisible(0))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_game.dealerValue}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Deck widget ───────────────────────────────────────────────────────────
  Widget _deckWidget() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        final glow = _game.canDeal ? _glowAnim.value : 0.08;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: glow),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: 84,
        height: 118,
        child: Stack(
          children: [
            // Shadow layers (gives depth)
            for (int i = 5; i >= 1; i--)
              Positioned(
                top: i.toDouble(),
                left: i.toDouble(),
                child: Container(
                  width: 72,
                  height: 104,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: const Color(0xFF0a1640),
                  ),
                ),
              ),
            // Top card face
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 72,
                height: 104,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563eb), Color(0xFF1e3a8f)],
                  ),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: CustomPaint(painter: _DeckPatternPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated card helper ──────────────────────────────────────────────────
  Widget _animatedCard(
    PlayingCard card,
    bool visible, {
    double width = 56,
    double height = 80,
    int dealOrder = 0,
  }) {
    if (!visible) return SizedBox(width: width, height: height);
    return TweenAnimationBuilder<double>(
      key: ValueKey('${card.suit.index}_${card.value.index}_${card.isFaceUp}_$dealOrder'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Transform.translate(
        offset: Offset(0, (1 - v) * -50),
        child: Transform.scale(
          scale: 0.55 + v * 0.45,
          child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
        ),
      ),
      child: CardWidget(card: card, width: width, height: height),
    );
  }

  // ── Slots grid (3 top + 2 bottom) ─────────────────────────────────────────
  Widget _slotsGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: slots 0, 1, 2
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [0, 1, 2].map(_slotWidget).toList(),
        ),
        const SizedBox(height: 8),
        // Bottom row: slots 3, 4 centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slotWidget(3),
            const SizedBox(width: 22),
            _slotWidget(4),
          ],
        ),
      ],
    );
  }

  // ── Single slot ───────────────────────────────────────────────────────────
  Widget _slotWidget(int i) {
    final slot = _game.slots[i];
    final busy = _game.gameInProgress || _isDealingCards;
    final isSelected = !busy && _selectedSlot == i;
    final isActive = !_isDealingCards && _game.currentSlotIndex == i;
    final hasResult = slot.result != null;

    Color border = Colors.white24;
    if (isSelected) border = const Color(0xFFFFD700);
    if (isActive) border = Colors.greenAccent;
    if (hasResult) border = _resultColor(slot.result);

    return GestureDetector(
      onTap: busy ? null : () => setState(() => _selectedSlot = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 74,
        constraints: const BoxConstraints(minHeight: 108),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: (isSelected || isActive) ? 2 : 1),
          color: isActive
              ? Colors.greenAccent.withValues(alpha: 0.08)
              : isSelected
                  ? const Color(0xFFFFD700).withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.2),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.3), blurRadius: 10)]
              : null,
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'S${i + 1}',
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (slot.bet > 0)
              Text(
                '\$${slot.bet}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 3),
            // Cards with staggered deal animation
            ...slot.cards.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: _animatedCard(
                  e.value,
                  _slotCardVisible(i, e.key),
                  width: 58,
                  height: 80,
                  dealOrder: e.key,
                ),
              ),
            ),
            // Hand value badge
            if (slot.cards.isNotEmpty && _slotCardVisible(i, 0)) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: slot.isBust
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${slot.handValue}',
                  style: TextStyle(
                    color: slot.isBust ? Colors.redAccent : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            // Result badge
            if (hasResult) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _resultColor(slot.result).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _resultColor(slot.result), width: 1),
                ),
                child: Text(
                  _resultText(slot.result),
                  style: TextStyle(
                    color: _resultColor(slot.result),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Control area dispatcher ───────────────────────────────────────────────
  Widget _controlArea() {
    if (_isDealingCards) {
      return Container(
        color: const Color(0xFF0d2818),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _l.dealing,
                style: const TextStyle(color: Colors.white38, letterSpacing: 2),
              ),
            ],
          ),
        ),
      );
    }
    if (_game.gameInProgress && _game.isPlayerTurn) {
      return _playerActionButtons();
    }
    if (!_game.gameInProgress &&
        _game.activeSlots.isNotEmpty &&
        _game.slots.any((s) => s.result != null)) {
      return _newRoundButton();
    }
    return _bettingControls();
  }

  // ── Player action buttons (Hit / Stand / Double) ──────────────────────────
  Widget _playerActionButtons() {
    final slot = _game.currentSlot;
    final canDouble =
        slot != null && slot.cards.length == 2 && _game.playerChips >= slot.bet;

    return Container(
      color: const Color(0xFF0d2818),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Slot ${_game.currentSlotIndex + 1}  •  ${slot?.handValue ?? ""}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _actionBtn(_l.hit, Colors.amber, _hit)),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(_l.stand, const Color(0xFF4ade80), _stand)),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  _l.doubleDown,
                  canDouble ? const Color(0xFF818cf8) : Colors.grey,
                  canDouble ? _double : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: onTap != null ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          border: Border.all(
            color: onTap != null ? color : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: onTap != null ? color : Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── Betting controls ──────────────────────────────────────────────────────
  Widget _bettingControls() {
    return Container(
      color: const Color(0xFF0d2818),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _l.slotInfo(
              _selectedSlot + 1,
              _game.slots[_selectedSlot].bet,
              _game.playerChips,
            ),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 8),
          // Chip selector row — tap to select denomination, then press BET
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_chipValues.length, (i) {
              final isSelected = _selectedChip == _chipValues[i];
              final canAfford =
                  _game.totalBets + _chipValues[i] <= _game.playerChips;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: canAfford
                      ? () => setState(() => _selectedChip = _chipValues[i])
                      : null,
                  child: Opacity(
                    opacity: canAfford ? 1.0 : 0.3,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _chipColors[i],
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white30,
                          width: isSelected ? 3.5 : 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: _chipColors[i].withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : canAfford
                                ? [
                                    BoxShadow(
                                      color: _chipColors[i].withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '\$${_chipValues[i]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSelected ? 12 : 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // BET | DOUBLE row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _bottomBtn(
                  '${_l.betBtn}  \$$_selectedChip',
                  const Color(0xFF4ade80),
                  _game.totalBets + _selectedChip <= _game.playerChips
                      ? () => _bet(_selectedChip)
                      : null,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _bottomBtn(
                  '2×  \$${(_game.slots[_selectedSlot].bet * 2).clamp(0, _game.playerChips - (_game.totalBets - _game.slots[_selectedSlot].bet))}',
                  const Color(0xFF818cf8),
                  _game.slots[_selectedSlot].bet > 0 &&
                          (_game.playerChips -
                                  (_game.totalBets -
                                      _game.slots[_selectedSlot].bet)) >
                              _game.slots[_selectedSlot].bet
                      ? _doubleBet
                      : null,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _bottomBtn(
                  '${_l.maxBet}\n\$${_game.playerChips - (_game.totalBets - _game.slots[_selectedSlot].bet)}',
                  const Color(0xFFFFD700),
                  (_game.playerChips -
                              (_game.totalBets -
                                  _game.slots[_selectedSlot].bet)) >
                          0
                      ? _allIn
                      : null,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Button row: CLEAR | CLEAR ALL | DEAL
          Row(
            children: [
              Expanded(
                child: _bottomBtn(
                  _l.clear,
                  Colors.redAccent,
                  _clearBet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _bottomBtn(
                  _l.clearAll,
                  Colors.orangeAccent,
                  _clearAllBets,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _bottomBtn(
                  _l.deal,
                  _game.canDeal ? const Color(0xFFFFD700) : Colors.white24,
                  _game.canDeal ? _deal : null,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBtn(
    String label,
    Color color,
    VoidCallback? onTap, {
    double fontSize = 11,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? color : Colors.white12,
          ),
          color: onTap != null ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onTap != null ? color : Colors.white24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: fontSize,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ── Next round button ─────────────────────────────────────────────────────
  Widget _newRoundButton() {
    return Container(
      color: const Color(0xFF0d2818),
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _newRound,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF4ade80).withValues(alpha: 0.2),
            border: Border.all(color: const Color(0xFF4ade80), width: 1.5),
          ),
          child: Center(
            child: Text(
              _l.nextRound,
              style: const TextStyle(
                color: Color(0xFF4ade80),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Deck pattern painter ──────────────────────────────────────────────────────
class _DeckPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const step = 10.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    // Inner frame
    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final inset = size.width * 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset),
        const Radius.circular(4),
      ),
      framePaint,
    );
    // Center diamond
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.18;
    final diamondPath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();
    canvas.drawPath(diamondPath, framePaint);
  }

  @override
  bool shouldRepaint(_DeckPatternPainter old) => false;
}
