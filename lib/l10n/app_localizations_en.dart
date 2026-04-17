// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageLabel => 'Language';

  @override
  String get bjSubtitle => '5 Betting Slots  ·  Beat the Dealer';

  @override
  String get pokerSubtitle => 'Up to 4 AI Opponents  ·  4 Difficulties';

  @override
  String get dealer => 'DEALER';

  @override
  String get dealing => 'Dealing...';

  @override
  String get hit => 'HIT';

  @override
  String get stand => 'STAND';

  @override
  String get doubleDown => 'DOUBLE';

  @override
  String get deal => 'DEAL';

  @override
  String get clear => 'CLEAR';

  @override
  String get clearAll => 'CLEAR ALL';

  @override
  String get allIn => 'ALL IN';

  @override
  String get betBtn => 'BET';

  @override
  String get nextRound => 'NEXT ROUND';

  @override
  String get win => 'WIN';

  @override
  String get lose => 'LOSE';

  @override
  String get push => 'PUSH';

  @override
  String get bust => 'BUST!';

  @override
  String get bustMsg =>
      'You\'re out of chips.\nLeave the table and come back to play again.';

  @override
  String get leaveTable => 'LEAVE TABLE';

  @override
  String slotInfo(int slot, int bet, int chips) {
    return 'Slot $slot  •  Bet: \$$bet  •  Chips: \$$chips';
  }

  @override
  String get preflop => 'PRE-FLOP';

  @override
  String get flop => 'FLOP';

  @override
  String get turn => 'TURN';

  @override
  String get river => 'RIVER';

  @override
  String get showdown => 'SHOWDOWN';

  @override
  String get fold => 'FOLD';

  @override
  String get checkAction => 'CHECK';

  @override
  String get callBtn => 'CALL';

  @override
  String get maxBet => 'MAX BET';

  @override
  String get twoBB => '2× BB';

  @override
  String get raiseBtn => 'RAISE';

  @override
  String get raiseLabel => 'RAISE';

  @override
  String get thinking => 'Thinking...';

  @override
  String get waiting => 'Waiting...';

  @override
  String get nextHand => 'NEXT HAND';

  @override
  String get bustLeave => 'BUST — LEAVE TABLE';

  @override
  String get youWin => 'YOU WIN! — NEW GAME';

  @override
  String get opponents => 'NUMBER OF OPPONENTS';

  @override
  String get aiDifficulty => 'AI DIFFICULTY';

  @override
  String get startGame => 'START GAME';

  @override
  String get botSingular => 'bot';

  @override
  String get botPlural => 'bots';

  @override
  String get easyLabel => 'EASY';

  @override
  String get mediumLabel => 'MEDIUM';

  @override
  String get hardLabel => 'HARD';

  @override
  String get masterLabel => 'MASTER';

  @override
  String get easyDesc => 'Beginner bots — they barely know the rules.';

  @override
  String get mediumDesc => 'Solid players with decent strategy.';

  @override
  String get hardDesc => 'Card-counters winning ~60-70% of the time.';

  @override
  String get masterDesc => 'They see your cards. Good luck.';

  @override
  String get potLabel => 'POT';

  @override
  String get betLabel => 'BET';

  @override
  String get actionFold => 'Folded';

  @override
  String get actionCheck => 'Checked';

  @override
  String get actionCall => 'Called';

  @override
  String get actionRaise => 'Raised';

  @override
  String get actionAllIn => 'All In';

  @override
  String get handHighCard => 'High Card';

  @override
  String get handOnePair => 'One Pair';

  @override
  String get handTwoPair => 'Two Pair';

  @override
  String get handThreeOfAKind => 'Three of a Kind';

  @override
  String get handStraight => 'Straight';

  @override
  String get handFlush => 'Flush';

  @override
  String get handFullHouse => 'Full House';

  @override
  String get handFourOfAKind => 'Four of a Kind';

  @override
  String get handStraightFlush => 'Straight Flush';

  @override
  String get handRoyalFlush => 'Royal Flush';

  @override
  String logWins(String name, int amount) {
    return '$name wins \$$amount';
  }

  @override
  String logWinsWith(String name, int amount, String handName) {
    return '$name wins \$$amount with $handName';
  }

  @override
  String logSplit(int amount, String names) {
    return 'Split \$$amount between $names';
  }

  @override
  String get split => 'SPLIT';

  @override
  String get insuranceTitle => 'INSURANCE?';

  @override
  String get takeInsuranceBtn => 'TAKE INSURANCE';

  @override
  String get declineBtn => 'DECLINE';

  @override
  String get mainHandLabel => 'MAIN';

  @override
  String get splitHandLabel => 'SPLIT';
}
