import 'dart:math';
import 'card_model.dart';
import 'deck.dart';
import 'hand_evaluator.dart';

enum PokerPhase { preflop, flop, turn, river, showdown }
enum PlayerAction { fold, check, call, raise, allIn }
enum AIDifficulty { easy, medium, hard, master }

class PokerPlayer {
  final String name;
  final bool isHuman;
  final AIDifficulty? difficulty;
  List<PlayingCard> holeCards = [];
  int chips;
  int currentBet = 0;
  bool folded = false;
  bool isAllIn = false;
  bool isDealer = false;
  bool isSmallBlind = false;
  bool isBigBlind = false;
  HandResult? handResult;
  String? lastActionLabel;

  PokerPlayer({
    required this.name,
    required this.isHuman,
    this.difficulty,
    this.chips = 1000,
  });

  bool get isActive => !folded && !isAllIn;
  bool get inHand => !folded;
}

class PokerGame {
  final List<PokerPlayer> players;
  final List<PlayingCard> communityCards = [];
  final Deck _deck = Deck();
  final Random _rng = Random();

  int pot = 0;
  int currentBet = 0;
  PokerPhase phase = PokerPhase.preflop;
  int dealerIndex = 0;
  int currentPlayerIndex = 0;
  int smallBlind = 10;
  int bigBlind = 20;
  bool roundOver = false;
  List<String> actionLog = [];

  int _actionsSinceLastRaise = 0;

  PokerGame({
    required int numBots,
    required AIDifficulty difficulty,
    int startingChips = 1000,
  }) : players = [
          PokerPlayer(name: 'You', isHuman: true, chips: startingChips),
          for (int i = 0; i < numBots; i++)
            PokerPlayer(
              name: _botName(i),
              isHuman: false,
              difficulty: difficulty,
              chips: startingChips,
            ),
        ];

  static String _botName(int i) {
    const names = ['Alex', 'Morgan', 'Jordan', 'Casey'];
    return names[i % names.length];
  }

  PokerPlayer get humanPlayer => players[0];

  List<PokerPlayer> get activePlayers => players.where((p) => p.inHand).toList();

  bool get isHumanTurn =>
      !roundOver &&
      currentPlayerIndex < players.length &&
      players[currentPlayerIndex].isHuman;

  int get callAmount {
    if (currentPlayerIndex >= players.length) return 0;
    final diff = currentBet - players[currentPlayerIndex].currentBet;
    return diff.clamp(0, players[currentPlayerIndex].chips);
  }

  bool get canCheck => callAmount == 0;

  void startNewHand() {
    _deck.reset();
    communityCards.clear();
    pot = 0;
    currentBet = 0;
    phase = PokerPhase.preflop;
    roundOver = false;
    actionLog.clear();
    _actionsSinceLastRaise = 0;

    players.removeWhere((p) => !p.isHuman && p.chips <= 0);

    for (final p in players) {
      p.holeCards.clear();
      p.currentBet = 0;
      p.folded = false;
      p.isAllIn = false;
      p.isDealer = false;
      p.isSmallBlind = false;
      p.isBigBlind = false;
      p.handResult = null;
      p.lastActionLabel = null;
    }

    if (players.length < 2) return;

    dealerIndex = (dealerIndex + 1) % players.length;
    players[dealerIndex].isDealer = true;

    final sbIdx = (dealerIndex + 1) % players.length;
    final bbIdx = (dealerIndex + 2) % players.length;
    players[sbIdx].isSmallBlind = true;
    players[bbIdx].isBigBlind = true;

    _postBlind(sbIdx, smallBlind);
    _postBlind(bbIdx, bigBlind);
    currentBet = bigBlind;

    for (int round = 0; round < 2; round++) {
      for (final p in players) {
        final card = _deck.deal(faceUp: p.isHuman);
        p.holeCards.add(card);
      }
    }

    currentPlayerIndex = (bbIdx + 1) % players.length;
    _skipNonActing();
  }

  void _postBlind(int idx, int amount) {
    final p = players[idx];
    final actual = min(amount, p.chips);
    p.chips -= actual;
    p.currentBet += actual;
    pot += actual;
    if (p.chips == 0) p.isAllIn = true;
    p.lastActionLabel = actual == smallBlind ? 'SB $actual' : 'BB $actual';
  }

  void _skipNonActing() {
    int safety = 0;
    while (safety < players.length &&
        (players[currentPlayerIndex].folded || players[currentPlayerIndex].isAllIn)) {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      safety++;
    }
  }

  void performAction(PlayerAction action, {int raiseExtra = 0}) {
    if (roundOver || currentPlayerIndex >= players.length) return;
    final player = players[currentPlayerIndex];

    switch (action) {
      case PlayerAction.fold:
        player.folded = true;
        player.lastActionLabel = 'Fold';
        _log('${player.name} folds');
        break;

      case PlayerAction.check:
        if (!canCheck) return;
        player.lastActionLabel = 'Check';
        _log('${player.name} checks');
        break;

      case PlayerAction.call:
        final amount = callAmount;
        player.chips -= amount;
        player.currentBet += amount;
        pot += amount;
        if (player.chips == 0) player.isAllIn = true;
        player.lastActionLabel = 'Call $amount';
        _log('${player.name} calls $amount');
        break;

      case PlayerAction.raise:
        final totalBet = currentBet + raiseExtra;
        final amount = min(totalBet - player.currentBet, player.chips);
        player.chips -= amount;
        player.currentBet += amount;
        pot += amount;
        currentBet = player.currentBet;
        _actionsSinceLastRaise = 0;
        if (player.chips == 0) player.isAllIn = true;
        player.lastActionLabel = 'Raise ${player.currentBet}';
        _log('${player.name} raises to ${player.currentBet}');
        break;

      case PlayerAction.allIn:
        final amount = player.chips;
        player.chips = 0;
        player.currentBet += amount;
        pot += amount;
        if (player.currentBet > currentBet) {
          currentBet = player.currentBet;
          _actionsSinceLastRaise = 0;
        }
        player.isAllIn = true;
        player.lastActionLabel = 'All-in';
        _log('${player.name} all-in for ${player.currentBet}');
        break;
    }

    _actionsSinceLastRaise++;

    if (_bettingRoundOver()) {
      _advancePhase();
    } else {
      _nextPlayer();
    }
  }

  bool _bettingRoundOver() {
    final canActPlayers = players.where((p) => !p.folded && !p.isAllIn).toList();
    if (canActPlayers.isEmpty) return true;
    if (canActPlayers.length == 1 && activePlayers.length <= 1) return true;

    final allCalled = canActPlayers.every((p) => p.currentBet >= currentBet);
    if (!allCalled) return false;
    return _actionsSinceLastRaise >= canActPlayers.length;
  }

  void _nextPlayer() {
    int next = (currentPlayerIndex + 1) % players.length;
    int safety = 0;
    while ((players[next].folded || players[next].isAllIn) && safety < players.length) {
      next = (next + 1) % players.length;
      safety++;
    }
    currentPlayerIndex = next;
  }

  void _advancePhase() {
    for (final p in players) {
      p.currentBet = 0;
    }
    currentBet = 0;
    _actionsSinceLastRaise = 0;

    if (activePlayers.length <= 1) {
      _endHand();
      return;
    }

    switch (phase) {
      case PokerPhase.preflop:
        phase = PokerPhase.flop;
        for (int i = 0; i < 3; i++) {
          communityCards.add(_deck.deal());
        }
        break;
      case PokerPhase.flop:
        phase = PokerPhase.turn;
        communityCards.add(_deck.deal());
        break;
      case PokerPhase.turn:
        phase = PokerPhase.river;
        communityCards.add(_deck.deal());
        break;
      case PokerPhase.river:
      case PokerPhase.showdown:
        _endHand();
        return;
    }

    currentPlayerIndex = (dealerIndex + 1) % players.length;
    _skipNonActing();
  }

  void _endHand() {
    phase = PokerPhase.showdown;
    roundOver = true;

    for (final p in players) {
      for (final c in p.holeCards) {
        c.isFaceUp = true;
      }
    }

    final active = activePlayers;
    if (active.length == 1) {
      active[0].chips += pot;
      _log('${active[0].name} wins \$$pot');
      return;
    }

    for (final p in active) {
      final all = [...p.holeCards, ...communityCards];
      if (all.length >= 5) {
        p.handResult = HandEvaluator.evaluate(all);
      }
    }

    HandResult? best;
    for (final p in active) {
      if (p.handResult == null) continue;
      if (best == null || p.handResult!.compareTo(best) > 0) {
        best = p.handResult;
      }
    }

    final winners = best == null
        ? active
        : active.where((p) => p.handResult?.compareTo(best!) == 0).toList();

    final share = pot ~/ winners.length;
    for (final w in winners) {
      w.chips += share;
    }

    if (winners.length == 1) {
      _log('${winners[0].name} wins \$$pot with ${winners[0].handResult?.rankName ?? 'best hand'}');
    } else {
      _log('Split pot \$$pot: ${winners.map((w) => w.name).join(' & ')}');
    }
  }

  void _log(String msg) => actionLog.add(msg);

  PlayerAction getAIAction(PokerPlayer player) {
    switch (player.difficulty!) {
      case AIDifficulty.easy:
        return _easyAI(player);
      case AIDifficulty.medium:
        return _mediumAI(player);
      case AIDifficulty.hard:
        return _hardAI(player);
      case AIDifficulty.master:
        return _masterAI(player);
    }
  }

  int getAIRaiseExtra(PokerPlayer player) {
    return bigBlind * (1 + _rng.nextInt(3));
  }

  PlayerAction _easyAI(PokerPlayer player) {
    final r = _rng.nextDouble();
    if (callAmount == 0) {
      if (r < 0.1) return PlayerAction.raise;
      return PlayerAction.check;
    }
    if (r < 0.5) return PlayerAction.call;
    if (r < 0.7) return PlayerAction.fold;
    return PlayerAction.call;
  }

  PlayerAction _mediumAI(PokerPlayer player) {
    final strength = HandEvaluator.getHandStrength(player.holeCards, communityCards);
    final r = _rng.nextDouble();

    if (strength > 0.65) {
      if (r < 0.55) return PlayerAction.raise;
      return PlayerAction.call;
    } else if (strength > 0.35) {
      if (callAmount == 0) return PlayerAction.check;
      if (r < 0.65) return PlayerAction.call;
      return PlayerAction.fold;
    } else {
      if (callAmount == 0) return PlayerAction.check;
      if (r < 0.2) return PlayerAction.call;
      return PlayerAction.fold;
    }
  }

  PlayerAction _hardAI(PokerPlayer player) {
    final strength = HandEvaluator.getHandStrength(player.holeCards, communityCards);
    final potOdds = pot > 0 ? callAmount / (pot + callAmount.toDouble()) : 0.0;
    final r = _rng.nextDouble();

    if (r < 0.15 && callAmount <= bigBlind * 2) {
      return PlayerAction.raise;
    }

    if (strength > potOdds + 0.12) {
      if (strength > 0.72 && r < 0.65) return PlayerAction.raise;
      return PlayerAction.call;
    } else if (callAmount == 0) {
      return PlayerAction.check;
    } else if (strength > potOdds - 0.05) {
      return PlayerAction.call;
    }
    return PlayerAction.fold;
  }

  PlayerAction _masterAI(PokerPlayer player) {
    final ownCards = [...player.holeCards, ...communityCards];
    final HandResult? ownResult =
        ownCards.length >= 5 ? HandEvaluator.evaluate(ownCards) : null;
    final opponents = players.where((p) => !p.folded && p != player).toList();
    final r = _rng.nextDouble();

    double winProb = 0.5;
    if (ownResult != null && opponents.isNotEmpty) {
      int wins = 0;
      for (final opp in opponents) {
        final oppCards = [...opp.holeCards, ...communityCards];
        if (oppCards.length >= 5) {
          final oppResult = HandEvaluator.evaluate(oppCards);
          if (ownResult.compareTo(oppResult) > 0) {
            wins++;
          }
        } else {
          wins++;
        }
      }
      winProb = wins / opponents.length;
    }

    if (winProb > 0.65) {
      if (r < 0.75) return PlayerAction.raise;
      return PlayerAction.call;
    } else if (winProb > 0.4) {
      if (callAmount == 0) return PlayerAction.check;
      if (r < 0.6) return PlayerAction.call;
      return PlayerAction.fold;
    } else {
      if (callAmount == 0) {
        if (r < 0.25) return PlayerAction.raise;
        return PlayerAction.check;
      }
      if (r < 0.12) return PlayerAction.call;
      return PlayerAction.fold;
    }
  }
}