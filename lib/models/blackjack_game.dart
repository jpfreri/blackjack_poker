import 'card_model.dart';
import 'deck.dart';

enum SlotState { empty, betting, playing, standing, bust, blackjack, done }
enum SlotResult { win, lose, push, blackjack }

class BlackjackSlot {
  List<PlayingCard> cards = [];
  int bet = 0;
  SlotState state = SlotState.empty;
  SlotResult? result;
  bool isDoubledDown = false;

  // ── Split fields ────────────────────────────────────────────────────────────
  List<PlayingCard> splitCards = [];
  int splitBet = 0;
  SlotState splitState = SlotState.empty;
  SlotResult? splitResult;
  bool isSplit = false;
  bool isPlayingSplit = false;
  bool splitDoubledDown = false;

  int get handValue {
    int value = 0;
    int aces = 0;
    for (final card in cards) {
      if (!card.isFaceUp) continue;
      if (card.value == CardValue.ace) {
        aces++;
        value += 11;
      } else {
        value += card.blackjackValue;
      }
    }
    while (value > 21 && aces > 0) {
      value -= 10;
      aces--;
    }
    return value;
  }

  int get splitHandValue {
    int value = 0;
    int aces = 0;
    for (final card in splitCards) {
      if (card.value == CardValue.ace) {
        aces++;
        value += 11;
      } else {
        value += card.blackjackValue;
      }
    }
    while (value > 21 && aces > 0) {
      value -= 10;
      aces--;
    }
    return value;
  }

  bool get isBust => handValue > 21;
  bool get splitIsBust => splitHandValue > 21;
  bool get isNaturalBlackjack => cards.length == 2 && handValue == 21;
  bool get canSplit =>
      !isSplit &&
      cards.length == 2 &&
      cards[0].blackjackValue == cards[1].blackjackValue;

  void clearForNewRound() {
    cards.clear();
    result = null;
    isDoubledDown = false;
    splitCards.clear();
    splitBet = 0;
    splitState = SlotState.empty;
    splitResult = null;
    isSplit = false;
    isPlayingSplit = false;
    splitDoubledDown = false;
    if (bet > 0) {
      state = SlotState.betting;
    } else {
      state = SlotState.empty;
    }
  }

  void fullClear() {
    cards.clear();
    bet = 0;
    state = SlotState.empty;
    result = null;
    isDoubledDown = false;
    splitCards.clear();
    splitBet = 0;
    splitState = SlotState.empty;
    splitResult = null;
    isSplit = false;
    isPlayingSplit = false;
    splitDoubledDown = false;
  }
}

class BlackjackGame {
  final Deck _deck = Deck();
  final List<BlackjackSlot> slots = List.generate(5, (_) => BlackjackSlot());
  final List<PlayingCard> dealerCards = [];
  int playerChips;
  bool gameInProgress = false;
  int currentSlotIndex = -1;

  // ── Insurance fields ────────────────────────────────────────────────────────
  bool awaitingInsuranceDecision = false;
  int insuranceBet = 0;

  BlackjackGame({this.playerChips = 1000});

  int get dealerValue {
    int value = 0;
    int aces = 0;
    for (final card in dealerCards) {
      if (!card.isFaceUp) continue;
      if (card.value == CardValue.ace) {
        aces++;
        value += 11;
      } else {
        value += card.blackjackValue;
      }
    }
    while (value > 21 && aces > 0) {
      value -= 10;
      aces--;
    }
    return value;
  }

  int get dealerTrueValue {
    // All cards counted (including face-down)
    int value = 0;
    int aces = 0;
    for (final card in dealerCards) {
      if (card.value == CardValue.ace) {
        aces++;
        value += 11;
      } else {
        value += card.blackjackValue;
      }
    }
    while (value > 21 && aces > 0) {
      value -= 10;
      aces--;
    }
    return value;
  }

  bool get dealerHasBlackjack => dealerCards.length == 2 && dealerTrueValue == 21;

  bool get dealerShowingAce =>
      dealerCards.isNotEmpty &&
      dealerCards[0].isFaceUp &&
      dealerCards[0].value == CardValue.ace;

  List<BlackjackSlot> get activeSlots =>
      slots.where((s) => s.bet > 0).toList();

  int get totalBets => slots.fold(0, (sum, s) => sum + s.bet);

  bool get isBust => !gameInProgress && playerChips == 0 && totalBets == 0;

  BlackjackSlot? get currentSlot =>
      (currentSlotIndex >= 0 && currentSlotIndex < 5) ? slots[currentSlotIndex] : null;

  int get insuranceMaxAmount => totalBets ~/ 2;
  bool get canAffordInsurance =>
      insuranceMaxAmount > 0 && playerChips >= insuranceMaxAmount;

  bool get canDeal =>
      !gameInProgress && activeSlots.isNotEmpty && totalBets <= playerChips;

  bool get isPlayerTurn {
    if (!gameInProgress || currentSlotIndex < 0 || awaitingInsuranceDecision) return false;
    final slot = currentSlot;
    if (slot == null) return false;
    if (slot.isSplit && slot.isPlayingSplit) return slot.splitState == SlotState.playing;
    return slot.state == SlotState.playing;
  }

  bool get canSplit =>
      isPlayerTurn &&
      currentSlot != null &&
      !currentSlot!.isPlayingSplit &&
      currentSlot!.canSplit &&
      playerChips >= currentSlot!.bet;

  void placeBet(int slotIndex, int amount) {
    if (gameInProgress) return;
    final slot = slots[slotIndex];
    // Guard: total bets across all slots must not exceed available chips
    if (totalBets + amount <= playerChips) {
      slot.bet += amount;
      slot.state = SlotState.betting;
    }
  }

  void doubleBet(int slotIndex) {
    if (gameInProgress) return;
    final slot = slots[slotIndex];
    if (slot.bet == 0) return;
    final otherBets = totalBets - slot.bet;
    final available = playerChips - otherBets;
    // Double if affordable, otherwise push to max available
    slot.bet = (slot.bet * 2).clamp(0, available);
    if (slot.bet == 0) slot.state = SlotState.empty;
  }

  void allIn(int slotIndex) {
    if (gameInProgress) return;
    final slot = slots[slotIndex];
    // Available chips = total chips minus bets on every OTHER slot
    final otherBets = totalBets - slot.bet;
    final available = playerChips - otherBets;
    if (available > 0) {
      slot.bet = available;
      slot.state = SlotState.betting;
    }
  }

  void clearBet(int slotIndex) {
    if (gameInProgress) return;
    final slot = slots[slotIndex];
    slot.bet = 0;
    slot.state = SlotState.empty;
  }

  void clearAllBets() {
    if (gameInProgress) return;
    for (final slot in slots) {
      slot.bet = 0;
      slot.state = SlotState.empty;
    }
  }

  void deal() {
    if (!canDeal) return;
    gameInProgress = true;
    _deck.reset();
    dealerCards.clear();

    for (final slot in slots) {
      slot.cards.clear();
      slot.result = null;
      slot.isDoubledDown = false;
      slot.splitCards.clear();
      slot.splitBet = 0;
      slot.splitState = SlotState.empty;
      slot.splitResult = null;
      slot.isSplit = false;
      slot.isPlayingSplit = false;
      slot.splitDoubledDown = false;
    }

    // Deduct bets
    for (final slot in activeSlots) {
      playerChips -= slot.bet;
    }

    // Deal two rounds
    for (int round = 0; round < 2; round++) {
      for (final slot in activeSlots) {
        slot.cards.add(_deck.deal());
      }
      dealerCards.add(_deck.deal(faceUp: round == 0));
    }

    // Set initial slot states
    for (final slot in activeSlots) {
      slot.state = slot.isNaturalBlackjack ? SlotState.blackjack : SlotState.playing;
    }

    currentSlotIndex = _nextPlayingSlot(-1);
    if (dealerShowingAce) {
      awaitingInsuranceDecision = true;
    } else if (currentSlotIndex == -1) {
      _runDealerTurn();
    }
  }

  int _nextPlayingSlot(int from) {
    for (int i = from + 1; i < 5; i++) {
      if (slots[i].state == SlotState.playing) return i;
    }
    return -1;
  }

  // ── Insurance ───────────────────────────────────────────────────────────────
  void takeInsurance() {
    if (!awaitingInsuranceDecision) return;
    final amount = insuranceMaxAmount;
    if (amount > 0 && playerChips >= amount) {
      insuranceBet = amount;
      playerChips -= insuranceBet;
    }
    awaitingInsuranceDecision = false;
    _continueAfterInsurance();
  }

  void declineInsurance() {
    if (!awaitingInsuranceDecision) return;
    awaitingInsuranceDecision = false;
    _continueAfterInsurance();
  }

  void _continueAfterInsurance() {
    if (currentSlotIndex == -1) _runDealerTurn();
  }

  // ── Split ───────────────────────────────────────────────────────────────────
  void split() {
    if (!canSplit) return;
    final slot = currentSlot!;
    final secondCard = slot.cards.removeLast();
    slot.splitCards.add(secondCard);
    slot.splitBet = slot.bet;
    playerChips -= slot.splitBet;
    slot.isSplit = true;
    slot.isPlayingSplit = false;
    slot.cards.add(_deck.deal());
    slot.splitCards.add(_deck.deal());
    slot.splitState = SlotState.playing;
    if (slot.handValue == 21) {
      slot.state = SlotState.standing;
      slot.isPlayingSplit = true;
    } else {
      slot.state = SlotState.playing;
    }
    if (slot.splitHandValue == 21) {
      slot.splitState = SlotState.standing;
      if (slot.state != SlotState.playing) _advance();
    }
  }

  // ── Player actions ──────────────────────────────────────────────────────────
  void hit() {
    if (!isPlayerTurn) return;
    final slot = currentSlot!;
    if (slot.isSplit && slot.isPlayingSplit) {
      // Acting on the split hand
      slot.splitCards.add(_deck.deal());
      if (slot.splitIsBust) {
        slot.splitState = SlotState.bust;
        _advance();
      } else if (slot.splitHandValue == 21) {
        slot.splitState = SlotState.standing;
        _advance();
      }
    } else {
      // Acting on the main hand
      slot.cards.add(_deck.deal());
      if (slot.isBust) {
        slot.state = SlotState.bust;
        _advanceFromMain(slot);
      } else if (slot.handValue == 21) {
        slot.state = SlotState.standing;
        _advanceFromMain(slot);
      }
    }
  }

  void stand() {
    if (!isPlayerTurn) return;
    final slot = currentSlot!;
    if (slot.isSplit && slot.isPlayingSplit) {
      slot.splitState = SlotState.standing;
      _advance();
    } else {
      slot.state = SlotState.standing;
      _advanceFromMain(slot);
    }
  }

  void doubleDown() {
    if (!isPlayerTurn) return;
    final slot = currentSlot!;
    if (slot.isSplit && slot.isPlayingSplit) {
      // Double on split hand
      if (slot.splitCards.length != 2 || playerChips < slot.splitBet) return;
      playerChips -= slot.splitBet;
      slot.splitBet *= 2;
      slot.splitDoubledDown = true;
      slot.splitCards.add(_deck.deal());
      slot.splitState = slot.splitIsBust ? SlotState.bust : SlotState.standing;
      _advance();
    } else {
      // Double on main hand
      if (slot.cards.length != 2 || playerChips < slot.bet) return;
      playerChips -= slot.bet;
      slot.bet *= 2;
      slot.isDoubledDown = true;
      slot.cards.add(_deck.deal());
      slot.state = slot.isBust ? SlotState.bust : SlotState.standing;
      _advanceFromMain(slot);
    }
  }

  void _advanceFromMain(BlackjackSlot slot) {
    if (slot.isSplit && slot.splitState == SlotState.playing) {
      slot.isPlayingSplit = true;
    } else {
      _advance();
    }
  }

  void _advance() {
    final slot = currentSlot;
    // If we were playing the split hand, move to next slot
    if (slot != null && slot.isSplit && slot.isPlayingSplit) {
      slot.isPlayingSplit = false;
      final next = _nextPlayingSlot(currentSlotIndex);
      if (next == -1) {
        _runDealerTurn();
      } else {
        currentSlotIndex = next;
      }
      return;
    }
    final next = _nextPlayingSlot(currentSlotIndex);
    if (next == -1) {
      _runDealerTurn();
    } else {
      currentSlotIndex = next;
    }
  }

  void _runDealerTurn() {
    currentSlotIndex = -1;
    // Reveal hole card
    for (final card in dealerCards) {
      card.isFaceUp = true;
    }
    // Dealer hits on soft 16 or less, stands on 17+
    while (dealerValue < 17) {
      dealerCards.add(_deck.deal());
    }
    _resolveRound();
  }

  // ── Result helpers ──────────────────────────────────────────────────────────
  SlotResult _computeResult(
      SlotState state, int handValue, int dv, bool dealerBJ, bool isNatural) {
    if (state == SlotState.bust) return SlotResult.lose;
    if (isNatural) return dealerBJ ? SlotResult.push : SlotResult.blackjack;
    if (dealerBJ) return SlotResult.lose;
    if (dv > 21 || handValue > dv) return SlotResult.win;
    if (handValue == dv) return SlotResult.push;
    return SlotResult.lose;
  }

  int _computePayout(SlotResult result, int bet) {
    switch (result) {
      case SlotResult.blackjack:
        return bet + (bet * 3 / 2).floor();
      case SlotResult.win:
        return bet * 2;
      case SlotResult.push:
        return bet;
      case SlotResult.lose:
        return 0;
    }
  }

  void _resolveRound() {
    final dv = dealerValue;
    final dealerBJ = dealerHasBlackjack;

    for (final slot in activeSlots) {
      final mainResult = _computeResult(
        slot.state,
        slot.handValue,
        dv,
        dealerBJ,
        slot.state == SlotState.blackjack,
      );
      slot.result = mainResult;
      playerChips += _computePayout(mainResult, slot.bet);

      if (slot.isSplit) {
        final splitRes = _computeResult(
          slot.splitState,
          slot.splitHandValue,
          dv,
          dealerBJ,
          false,
        );
        slot.splitResult = splitRes;
        playerChips += _computePayout(splitRes, slot.splitBet);
      }

      slot.state = SlotState.done;
    }

    // Insurance resolution: 2:1 payout if dealer has blackjack
    if (insuranceBet > 0) {
      if (dealerBJ) playerChips += insuranceBet * 3; // original bet back + 2:1 win
      insuranceBet = 0;
    }

    gameInProgress = false;
    awaitingInsuranceDecision = false;
  }

  void newRound() {
    dealerCards.clear();
    gameInProgress = false;
    currentSlotIndex = -1;
    awaitingInsuranceDecision = false;
    insuranceBet = 0;
    for (final slot in slots) {
      slot.clearForNewRound();
    }
    // If player has no chips, wipe all bets (they're bust)
    if (playerChips == 0) {
      for (final slot in slots) {
        slot.fullClear();
      }
      return;
    }
    // Trim any carried-over bets that now exceed remaining chips
    int remaining = playerChips;
    for (final slot in slots) {
      if (slot.bet > 0) {
        if (slot.bet > remaining) {
          slot.bet = 0;
          slot.state = SlotState.empty;
        } else {
          remaining -= slot.bet;
        }
      }
    }
  }

  void resetAll() {
    dealerCards.clear();
    gameInProgress = false;
    currentSlotIndex = -1;
    awaitingInsuranceDecision = false;
    insuranceBet = 0;
    for (final slot in slots) {
      slot.fullClear();
    }
  }

  // Simulate dealer turn animation steps — returns true if dealer needs another card.
  bool dealerNeedsHit() => dealerValue < 17 && dealerCards.every((c) => c.isFaceUp);

  void dealerHit() {
    if (dealerNeedsHit()) dealerCards.add(_deck.deal());
  }

  void resolveAfterDealer() => _resolveRound();

  // For animated dealer turn
  void revealDealerHoleCard() {
    for (final card in dealerCards) {
      card.isFaceUp = true;
    }
  }

  // Override deal() to support animated dealer — call this instead when using animation
  void dealAnimated() {
    if (!canDeal) return;
    gameInProgress = true;
    _deck.reset();
    dealerCards.clear();

    for (final slot in slots) {
      slot.cards.clear();
      slot.result = null;
      slot.isDoubledDown = false;
      slot.splitCards.clear();
      slot.splitBet = 0;
      slot.splitState = SlotState.empty;
      slot.splitResult = null;
      slot.isSplit = false;
      slot.isPlayingSplit = false;
      slot.splitDoubledDown = false;
    }

    for (final slot in activeSlots) {
      playerChips -= slot.bet;
    }

    for (int round = 0; round < 2; round++) {
      for (final slot in activeSlots) {
        slot.cards.add(_deck.deal());
      }
      dealerCards.add(_deck.deal(faceUp: round == 0));
    }

    for (final slot in activeSlots) {
      slot.state = slot.isNaturalBlackjack ? SlotState.blackjack : SlotState.playing;
    }

    currentSlotIndex = _nextPlayingSlot(-1);
    if (dealerShowingAce) {
      awaitingInsuranceDecision = true;
    } else if (currentSlotIndex == -1) {
      // All blackjacks or no playing slots – reveal and resolve
      revealDealerHoleCard();
      _resolveRound();
    }
  }
}
