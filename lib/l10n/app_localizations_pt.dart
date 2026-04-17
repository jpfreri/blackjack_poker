// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get languageLabel => 'Idioma';

  @override
  String get bjSubtitle => '5 Apostas  ·  Supere o Dealer';

  @override
  String get pokerSubtitle => 'Até 4 Adversários IA  ·  4 Dificuldades';

  @override
  String get dealer => 'DEALER';

  @override
  String get dealing => 'Distribuindo...';

  @override
  String get hit => 'PEDIR';

  @override
  String get stand => 'PARAR';

  @override
  String get doubleDown => 'DOBRAR';

  @override
  String get deal => 'DISTRIBUIR';

  @override
  String get clear => 'LIMPAR';

  @override
  String get clearAll => 'LIMPAR TUDO';

  @override
  String get allIn => 'ALL IN';

  @override
  String get betBtn => 'APOSTAR';

  @override
  String get nextRound => 'PRÓXIMA RODADA';

  @override
  String get win => 'GANHOU';

  @override
  String get lose => 'PERDEU';

  @override
  String get push => 'EMPATE';

  @override
  String get bust => 'FALIU!';

  @override
  String get bustMsg =>
      'Você ficou sem fichas.\nSaia da mesa e volte para jogar novamente.';

  @override
  String get leaveTable => 'SAIR DA MESA';

  @override
  String slotInfo(int slot, int bet, int chips) {
    return 'Slot $slot  •  Aposta: \$$bet  •  Fichas: \$$chips';
  }

  @override
  String get preflop => 'PRÉ-FLOP';

  @override
  String get flop => 'FLOP';

  @override
  String get turn => 'TURN';

  @override
  String get river => 'RIVER';

  @override
  String get showdown => 'CONFRONTO';

  @override
  String get fold => 'DESISTIR';

  @override
  String get checkAction => 'PASSAR';

  @override
  String get callBtn => 'PAGAR';

  @override
  String get maxBet => 'APOSTA MÁX';

  @override
  String get twoBB => '2× BB';

  @override
  String get raiseBtn => 'AUMENTAR';

  @override
  String get raiseLabel => 'AUMENTAR';

  @override
  String get thinking => 'Pensando...';

  @override
  String get waiting => 'Aguardando...';

  @override
  String get nextHand => 'PRÓXIMA MÃO';

  @override
  String get bustLeave => 'FALIU — SAIR DA MESA';

  @override
  String get youWin => 'VOCÊ GANHOU! — NOVO JOGO';

  @override
  String get opponents => 'NÚMERO DE ADVERSÁRIOS';

  @override
  String get aiDifficulty => 'DIFICULDADE DA IA';

  @override
  String get startGame => 'INICIAR JOGO';

  @override
  String get botSingular => 'bot';

  @override
  String get botPlural => 'bots';

  @override
  String get easyLabel => 'FÁCIL';

  @override
  String get mediumLabel => 'MÉDIO';

  @override
  String get hardLabel => 'DIFÍCIL';

  @override
  String get masterLabel => 'MESTRE';

  @override
  String get easyDesc => 'Bots iniciantes — mal sabem as regras.';

  @override
  String get mediumDesc => 'Jogadores sólidos com boa estratégia.';

  @override
  String get hardDesc => 'Contadores de cartas, ~60-70% de vitórias.';

  @override
  String get masterDesc => 'Eles veem suas cartas. Boa sorte.';

  @override
  String get potLabel => 'POTE';

  @override
  String get betLabel => 'APOSTA';

  @override
  String get actionFold => 'Desistiu';

  @override
  String get actionCheck => 'Passou';

  @override
  String get actionCall => 'Pagou';

  @override
  String get actionRaise => 'Aumentou';

  @override
  String get actionAllIn => 'All In';

  @override
  String get handHighCard => 'Carta Alta';

  @override
  String get handOnePair => 'Um Par';

  @override
  String get handTwoPair => 'Dois Pares';

  @override
  String get handThreeOfAKind => 'Trinca';

  @override
  String get handStraight => 'Sequência';

  @override
  String get handFlush => 'Flush';

  @override
  String get handFullHouse => 'Full House';

  @override
  String get handFourOfAKind => 'Quadra';

  @override
  String get handStraightFlush => 'Straight Flush';

  @override
  String get handRoyalFlush => 'Royal Flush';

  @override
  String logWins(String name, int amount) {
    return '$name ganha \$$amount';
  }

  @override
  String logWinsWith(String name, int amount, String handName) {
    return '$name ganha \$$amount com $handName';
  }

  @override
  String logSplit(int amount, String names) {
    return 'Divisão de \$$amount entre $names';
  }

  @override
  String get split => 'DIVIDIR';

  @override
  String get insuranceTitle => 'SEGURO?';

  @override
  String get takeInsuranceBtn => 'ACEITAR SEGURO';

  @override
  String get declineBtn => 'RECUSAR';

  @override
  String get mainHandLabel => 'PRINCIPAL';

  @override
  String get splitHandLabel => 'DIVISÃO';
}
