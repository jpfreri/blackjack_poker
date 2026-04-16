// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get languageLabel => 'Langue';

  @override
  String get bjSubtitle => '5 Mises  ·  Battez le Croupier';

  @override
  String get pokerSubtitle => 'Jusqu\'à 4 Adversaires  ·  4 Niveaux';

  @override
  String get dealer => 'CROUPIER';

  @override
  String get dealing => 'Distribution...';

  @override
  String get hit => 'TIRER';

  @override
  String get stand => 'RESTER';

  @override
  String get doubleDown => 'DOUBLER';

  @override
  String get deal => 'DISTRIBUER';

  @override
  String get clear => 'EFFACER';

  @override
  String get clearAll => 'TOUT EFFACER';

  @override
  String get allIn => 'TAPIS';

  @override
  String get betBtn => 'MISER';

  @override
  String get nextRound => 'TOUR SUIVANT';

  @override
  String get win => 'GAGNÉ';

  @override
  String get lose => 'PERDU';

  @override
  String get push => 'ÉGALITÉ';

  @override
  String get bust => 'RUINÉ !';

  @override
  String get bustMsg =>
      'Vous n\'avez plus de jetons.\nQuittez la table et revenez jouer.';

  @override
  String get leaveTable => 'QUITTER LA TABLE';

  @override
  String slotInfo(int slot, int bet, int chips) {
    return 'Slot $slot  •  Mise: \$$bet  •  Jetons: \$$chips';
  }

  @override
  String get preflop => 'PRÉ-FLOP';

  @override
  String get flop => 'FLOP';

  @override
  String get turn => 'TOURNANT';

  @override
  String get river => 'RIVIÈRE';

  @override
  String get showdown => 'ABATTAGE';

  @override
  String get fold => 'SE COUCHER';

  @override
  String get checkAction => 'CHECKER';

  @override
  String get callBtn => 'SUIVRE';

  @override
  String get maxBet => 'MISE MAX';

  @override
  String get twoBB => '2× BB';

  @override
  String get raiseBtn => 'RELANCER';

  @override
  String get raiseLabel => 'RELANCER';

  @override
  String get thinking => 'Réflexion...';

  @override
  String get waiting => 'En attente...';

  @override
  String get nextHand => 'MAIN SUIVANTE';

  @override
  String get bustLeave => 'RUINÉ — QUITTER';

  @override
  String get youWin => 'VOUS GAGNEZ ! — NOUVEAU JEU';

  @override
  String get opponents => 'NOMBRE D\'ADVERSAIRES';

  @override
  String get aiDifficulty => 'DIFFICULTÉ DE L\'IA';

  @override
  String get startGame => 'COMMENCER';

  @override
  String get botSingular => 'bot';

  @override
  String get botPlural => 'bots';

  @override
  String get easyLabel => 'FACILE';

  @override
  String get mediumLabel => 'MOYEN';

  @override
  String get hardLabel => 'DIFFICILE';

  @override
  String get masterLabel => 'MAÎTRE';

  @override
  String get easyDesc => 'Bots débutants — ils connaissent à peine les règles.';

  @override
  String get mediumDesc => 'Joueurs solides avec une bonne stratégie.';

  @override
  String get hardDesc => 'Compteurs de cartes, ~60-70% de victoires.';

  @override
  String get masterDesc => 'Ils voient vos cartes. Bonne chance.';

  @override
  String get potLabel => 'POT';

  @override
  String get betLabel => 'MISE';

  @override
  String get actionFold => 'Couché';

  @override
  String get actionCheck => 'Checké';

  @override
  String get actionCall => 'Suivi';

  @override
  String get actionRaise => 'Relancé';

  @override
  String get actionAllIn => 'Tapis';

  @override
  String get handHighCard => 'Carte Haute';

  @override
  String get handOnePair => 'Une Paire';

  @override
  String get handTwoPair => 'Deux Paires';

  @override
  String get handThreeOfAKind => 'Brelan';

  @override
  String get handStraight => 'Suite';

  @override
  String get handFlush => 'Couleur';

  @override
  String get handFullHouse => 'Full';

  @override
  String get handFourOfAKind => 'Carré';

  @override
  String get handStraightFlush => 'Quinte Flush';

  @override
  String get handRoyalFlush => 'Quinte Flush Royale';

  @override
  String logWins(String name, int amount) {
    return '$name gagne \$$amount';
  }

  @override
  String logWinsWith(String name, int amount, String handName) {
    return '$name gagne \$$amount avec $handName';
  }

  @override
  String logSplit(int amount, String names) {
    return 'Partage de \$$amount entre $names';
  }
}
