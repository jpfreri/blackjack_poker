enum Suit { hearts, diamonds, clubs, spades }

enum CardValue {
  two, three, four, five, six, seven, eight, nine, ten,
  jack, queen, king, ace,
}

class PlayingCard {
  final Suit suit;
  final CardValue value;
  bool isFaceUp;

  PlayingCard({required this.suit, required this.value, this.isFaceUp = true});

  int get blackjackValue {
    switch (value) {
      case CardValue.ace:
        return 11;
      case CardValue.jack:
      case CardValue.queen:
      case CardValue.king:
        return 10;
      default:
        return value.index + 2;
    }
  }

  int get numericValue => value.index + 2; // 2–14 (ace = 14)

  String get displayValue {
    switch (value) {
      case CardValue.jack:
        return 'J';
      case CardValue.queen:
        return 'Q';
      case CardValue.king:
        return 'K';
      case CardValue.ace:
        return 'A';
      default:
        return (value.index + 2).toString();
    }
  }

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  @override
  String toString() => '$displayValue$suitSymbol';
}
