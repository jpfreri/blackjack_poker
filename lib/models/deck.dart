import 'dart:math';
import 'card_model.dart';

class Deck {
  final List<PlayingCard> _cards = [];
  final Random _rng = Random();

  Deck() {
    reset();
  }

  void reset() {
    _cards.clear();
    for (final suit in Suit.values) {
      for (final value in CardValue.values) {
        _cards.add(PlayingCard(suit: suit, value: value));
      }
    }
    _cards.shuffle(_rng);
  }

  PlayingCard deal({bool faceUp = true}) {
    if (_cards.isEmpty) reset();
    final card = _cards.removeLast();
    card.isFaceUp = faceUp;
    return card;
  }

  int get remaining => _cards.length;
}
