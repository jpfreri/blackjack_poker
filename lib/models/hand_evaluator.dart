import 'card_model.dart';

enum HandRank {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush,
}

class HandResult implements Comparable<HandResult> {
  final HandRank rank;
  final List<int> tiebreakers;

  const HandResult({required this.rank, required this.tiebreakers});

  @override
  int compareTo(HandResult other) {
    if (rank.index != other.rank.index) {
      return rank.index.compareTo(other.rank.index);
    }
    for (int i = 0; i < tiebreakers.length && i < other.tiebreakers.length; i++) {
      if (tiebreakers[i] != other.tiebreakers[i]) {
        return tiebreakers[i].compareTo(other.tiebreakers[i]);
      }
    }
    return 0;
  }

  String get rankName {
    const names = [
      'High Card', 'One Pair', 'Two Pair', 'Three of a Kind',
      'Straight', 'Flush', 'Full House', 'Four of a Kind',
      'Straight Flush', 'Royal Flush',
    ];
    return names[rank.index];
  }
}

class HandEvaluator {
  static HandResult evaluate(List<PlayingCard> cards) {
    final combos = _combinations(cards, 5);
    HandResult? best;
    for (final combo in combos) {
      final r = _evaluateFive(combo);
      if (best == null || r.compareTo(best) > 0) best = r;
    }
    return best!;
  }

  static List<List<T>> _combinations<T>(List<T> items, int k) {
    final result = <List<T>>[];
    void go(int start, List<T> cur) {
      if (cur.length == k) {
        result.add(List.from(cur));
        return;
      }
      for (int i = start; i < items.length; i++) {
        cur.add(items[i]);
        go(i + 1, cur);
        cur.removeLast();
      }
    }
    go(0, []);
    return result;
  }

  static HandResult _evaluateFive(List<PlayingCard> hand) {
    final sorted = List<PlayingCard>.from(hand)
      ..sort((a, b) => b.numericValue.compareTo(a.numericValue));
    final vals = sorted.map((c) => c.numericValue).toList();
    final isFlush = hand.map((c) => c.suit).toSet().length == 1;
    final isStraight = _checkStraight(vals);

    final counts = <int, int>{};
    for (final v in vals) { counts[v] = (counts[v] ?? 0) + 1; }
    final groups = counts.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        return cmp != 0 ? cmp : b.key.compareTo(a.key);
      });
    final tieKeys = groups.map((e) => e.key).toList();

    if (isFlush && isStraight) {
      final hi = vals[0] == 14 && vals[1] == 5 ? 5 : vals[0];
      return HandResult(
        rank: hi == 14 ? HandRank.royalFlush : HandRank.straightFlush,
        tiebreakers: [hi],
      );
    }
    if (groups[0].value == 4) {
      return HandResult(rank: HandRank.fourOfAKind, tiebreakers: tieKeys);
    }
    if (groups[0].value == 3 && groups.length > 1 && groups[1].value == 2) {
      return HandResult(rank: HandRank.fullHouse, tiebreakers: tieKeys);
    }
    if (isFlush) return HandResult(rank: HandRank.flush, tiebreakers: vals);
    if (isStraight) {
      final hi = vals[0] == 14 && vals[1] == 5 ? 5 : vals[0];
      return HandResult(rank: HandRank.straight, tiebreakers: [hi]);
    }
    if (groups[0].value == 3) {
      return HandResult(rank: HandRank.threeOfAKind, tiebreakers: tieKeys);
    }
    if (groups[0].value == 2 && groups.length > 1 && groups[1].value == 2) {
      return HandResult(rank: HandRank.twoPair, tiebreakers: tieKeys);
    }
    if (groups[0].value == 2) {
      return HandResult(rank: HandRank.onePair, tiebreakers: tieKeys);
    }
    return HandResult(rank: HandRank.highCard, tiebreakers: vals);
  }

  static bool _checkStraight(List<int> vals) {
    if (vals[0] == 14 && vals[1] == 5 && vals[2] == 4 && vals[3] == 3 && vals[4] == 2) {
      return true;
    }
    for (int i = 0; i < 4; i++) {
      if (vals[i] - vals[i + 1] != 1) return false;
    }
    return true;
  }

  /// Returns a 0.0–1.0 strength estimate for the given hole + community cards.
  static double getHandStrength(List<PlayingCard> hole, List<PlayingCard> community) {
    final all = [...hole, ...community];
    if (all.length < 5) return _preflopStrength(hole);
    return evaluate(all).rank.index / (HandRank.values.length - 1);
  }

  static double _preflopStrength(List<PlayingCard> hole) {
    if (hole.length < 2) return 0.3;
    final v1 = hole[0].numericValue;
    final v2 = hole[1].numericValue;
    final suited = hole[0].suit == hole[1].suit;
    if (v1 == v2) return 0.5 + (v1 / 28.0);
    final hi = v1 > v2 ? v1 : v2;
    final lo = v1 < v2 ? v1 : v2;
    double s = hi / 35.0 + lo / 50.0;
    if (suited) s += 0.08;
    if (hi - lo <= 3) s += 0.05;
    return s.clamp(0.0, 1.0);
  }
}
