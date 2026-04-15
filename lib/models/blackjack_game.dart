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

  bool get isBust => handValue > 21;
  bool get isNaturalBlackjack => cards.length == 2 && handValue == 21;

  void clearForNewRound() {
    cards.clear();
    result = null;
    isDoubledDown = false;
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
  }
}

class BlackjackGame {
  final Deck _deck = Deck();
  final List<BlackjackSlot> slots = List.generate(5, (_) => BlackjackSlot());
  final List<PlayingCard> dealerCards = [];
  int playerChips;
  bool gameInProgress = false;
  int currentSlotIndex = -1;

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

  List<BlackjackSlot> get activeSlots =>
      slots.where((s) => s.bet > 0).toList();

  int get totalBets => slots.fold(0, (sum, s) => sum + s.bet);

  bool get isBust => !gameInProgress && playerChips == 0 && totalBets == 0;

  BlackjackSlot? get currentSlot =>
      (currentSlotIndex >= 0 && currentSlotIndex < 5) ? slots[currentSlotIndex] : null;

  bool get canDeal =>
      !gameInProgress && activeSlots.isNotEmpty && totalBets <= playerChips;
  bool get isPlayerTurn =>
      gameInProgress &&
      currentSlotIndex >= 0 &&
      currentSlot?.state == SlotState.playing;

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
    if (currentSlotIndex == -1) _runDealerTurn();
  }

  int _nextPlayingSlot(int from) {
    for (int i = from + 1; i < 5; i++) {
      if (slots[i].state == SlotState.playing) return i;
    }
    return -1;
  }

  void hit() {
    if (!isPlayerTurn) return;
    final slot = currentSlot!;
    slot.cards.add(_deck.deal());
    if (slot.isBust) {
      slot.state = SlotState.bust;
      _advance();
    } else if (slot.handValue == 21) {
      slot.state = SlotState.standing;
      _advance();
    }
  }

  void stand() {
    if (!isPlayerTurn) return;
    currentSlot!.state = SlotState.standing;
    _advance();
  }

  void doubleDown() {
    if (!isPlayerTurn) return;
    final slot = currentSlot!;
    if (slot.cards.length != 2 || playerChips < slot.bet) return;
    playerChips -= slot.bet;
    slot.bet *= 2;
    slot.isDoubledDown = true;
    slot.cards.add(_deck.deal());
    slot.state = slot.isBust ? SlotState.bust : SlotState.standing;
    _advance();
  }

  void _advance() {
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

  void _resolveRound() {
    final dv = dealerValue;
    final dealerBJ = dealerHasBlackjack;

    for (final slot in activeSlots) {
      if (slot.state == SlotState.bust) {
        slot.result = SlotResult.lose;
      } else if (slot.state == SlotState.blackjack) {
        if (dealerBJ) {
          slot.result = SlotResult.push;
          playerChips += slot.bet;
        } else {
          slot.result = SlotResult.blackjack;
          playerChips += slot.bet + (slot.bet * 3 / 2).floor(); // 3:2
        }
      } else if (dealerBJ) {
        slot.result = SlotResult.lose;
      } else if (dv > 21 || slot.handValue > dv) {
        slot.result = SlotResult.win;
        playerChips += slot.bet * 2;
      } else if (slot.handValue == dv) {
        slot.result = SlotResult.push;
        playerChips += slot.bet;
      } else {
        slot.result = SlotResult.lose;
      }
      slot.state = SlotState.done;
    }
    gameInProgress = false;
  }

  void newRound() {
    dealerCards.clear();
    gameInProgress = false;
    currentSlotIndex = -1;
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
    if (currentSlotIndex == -1) {
      // All blackjacks or no playing slots – reveal and resolve
      revealDealerHoleCard();
      _resolveRound();
    }
  }
}
