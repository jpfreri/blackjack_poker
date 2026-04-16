// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get languageLabel => 'Idioma';

  @override
  String get bjSubtitle => '5 Apuestas  ·  Supera al Dealer';

  @override
  String get pokerSubtitle => 'Hasta 4 Oponentes IA  ·  4 Dificultades';

  @override
  String get dealer => 'CROUPIER';

  @override
  String get dealing => 'Repartiendo...';

  @override
  String get hit => 'PEDIR';

  @override
  String get stand => 'PLANTARSE';

  @override
  String get doubleDown => 'DOBLAR';

  @override
  String get deal => 'REPARTIR';

  @override
  String get clear => 'LIMPIAR';

  @override
  String get clearAll => 'LIMPIAR TODO';

  @override
  String get allIn => 'ALL IN';

  @override
  String get betBtn => 'APOSTAR';

  @override
  String get nextRound => 'SIGUIENTE RONDA';

  @override
  String get win => 'GANÓ';

  @override
  String get lose => 'PERDIÓ';

  @override
  String get push => 'EMPATE';

  @override
  String get bust => '¡SIN FICHAS!';

  @override
  String get bustMsg =>
      'Te quedaste sin fichas.\nSal de la mesa y vuelve para jugar de nuevo.';

  @override
  String get leaveTable => 'SALIR DE LA MESA';

  @override
  String slotInfo(int slot, int bet, int chips) {
    return 'Slot $slot  •  Apuesta: \$$bet  •  Fichas: \$$chips';
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
  String get showdown => 'ENFRENTAMIENTO';

  @override
  String get fold => 'RETIRARSE';

  @override
  String get checkAction => 'PASAR';

  @override
  String get callBtn => 'IGUALAR';

  @override
  String get maxBet => 'APUESTA MÁX';

  @override
  String get twoBB => '2× BB';

  @override
  String get raiseBtn => 'SUBIR';

  @override
  String get raiseLabel => 'SUBIR';

  @override
  String get thinking => 'Pensando...';

  @override
  String get waiting => 'Esperando...';

  @override
  String get nextHand => 'SIGUIENTE MANO';

  @override
  String get bustLeave => 'SIN FICHAS — SALIR';

  @override
  String get youWin => '¡GANASTE! — NUEVO JUEGO';

  @override
  String get opponents => 'NÚMERO DE OPONENTES';

  @override
  String get aiDifficulty => 'DIFICULTAD DE LA IA';

  @override
  String get startGame => 'INICIAR JUEGO';

  @override
  String get botSingular => 'bot';

  @override
  String get botPlural => 'bots';

  @override
  String get easyLabel => 'FÁCIL';

  @override
  String get mediumLabel => 'MEDIO';

  @override
  String get hardLabel => 'DIFÍCIL';

  @override
  String get masterLabel => 'MAESTRO';

  @override
  String get easyDesc => 'Bots principiantes — apenas conocen las reglas.';

  @override
  String get mediumDesc => 'Jugadores sólidos con buena estrategia.';

  @override
  String get hardDesc => 'Contadores de cartas, ~60-70% de victorias.';

  @override
  String get masterDesc => 'Ven tus cartas. Buena suerte.';

  @override
  String get potLabel => 'BOTE';

  @override
  String get betLabel => 'APUESTA';

  @override
  String get actionFold => 'Se retiró';

  @override
  String get actionCheck => 'Pasó';

  @override
  String get actionCall => 'Igualó';

  @override
  String get actionRaise => 'Subió';

  @override
  String get actionAllIn => 'All In';

  @override
  String get handHighCard => 'Carta Alta';

  @override
  String get handOnePair => 'Un Par';

  @override
  String get handTwoPair => 'Dos Pares';

  @override
  String get handThreeOfAKind => 'Trío';

  @override
  String get handStraight => 'Escalera';

  @override
  String get handFlush => 'Color';

  @override
  String get handFullHouse => 'Full House';

  @override
  String get handFourOfAKind => 'Póker';

  @override
  String get handStraightFlush => 'Escalera de Color';

  @override
  String get handRoyalFlush => 'Escalera Real';

  @override
  String logWins(String name, int amount) {
    return '$name gana \$$amount';
  }

  @override
  String logWinsWith(String name, int amount, String handName) {
    return '$name gana \$$amount con $handName';
  }

  @override
  String logSplit(int amount, String names) {
    return 'División de \$$amount entre $names';
  }
}
