import 'package:flutter/foundation.dart';

enum AppLocale { en, pt, es, fr }

/// Global locale notifier — change this value to switch language everywhere.
final localeNotifier = ValueNotifier<AppLocale>(AppLocale.en);

class AppStrings {
  final AppLocale locale;
  const AppStrings(this.locale);

  String _s(String en, String pt, String es, String fr) {
    switch (locale) {
      case AppLocale.en:
        return en;
      case AppLocale.pt:
        return pt;
      case AppLocale.es:
        return es;
      case AppLocale.fr:
        return fr;
    }
  }

  // ── Meta ───────────────────────────────────────────────────────────────────
  String get languageLabel => _s('Language', 'Idioma', 'Idioma', 'Langue');

  // ── Home ───────────────────────────────────────────────────────────────────
  String get bjSubtitle => _s(
        '5 Betting Slots  ·  Beat the Dealer',
        '5 Apostas  ·  Supere o Dealer',
        '5 Apuestas  ·  Supera al Dealer',
        '5 Mises  ·  Battez le Croupier',
      );
  String get pokerSubtitle => _s(
        'Up to 4 AI Opponents  ·  4 Difficulties',
        'Até 4 Adversários IA  ·  4 Dificuldades',
        'Hasta 4 Oponentes IA  ·  4 Dificultades',
        "Jusqu'à 4 Adversaires  ·  4 Niveaux",
      );

  // ── Blackjack ──────────────────────────────────────────────────────────────
  String get dealer => _s('DEALER', 'DEALER', 'CROUPIER', 'CROUPIER');
  String get dealing =>
      _s('Dealing...', 'Distribuindo...', 'Repartiendo...', 'Distribution...');
  String get hit => _s('HIT', 'PEDIR', 'PEDIR', 'TIRER');
  String get stand => _s('STAND', 'PARAR', 'PLANTARSE', 'RESTER');
  String get doubleDown => _s('DOUBLE', 'DOBRAR', 'DOBLAR', 'DOUBLER');
  String get deal => _s('DEAL', 'DISTRIBUIR', 'REPARTIR', 'DISTRIBUER');
  String get clear => _s('CLEAR', 'LIMPAR', 'LIMPIAR', 'EFFACER');
  String get clearAll =>
      _s('CLEAR ALL', 'LIMPAR TUDO', 'LIMPIAR TODO', 'TOUT EFFACER');
  String get allIn => _s('ALL IN', 'ALL IN', 'ALL IN', 'TAPIS');
  String get betBtn => _s('BET', 'APOSTAR', 'APOSTAR', 'MISER');
  String get nextRound =>
      _s('NEXT ROUND', 'PRÓXIMA RODADA', 'SIGUIENTE RONDA', 'TOUR SUIVANT');
  String get win => _s('WIN', 'GANHOU', 'GANÓ', 'GAGNÉ');
  String get lose => _s('LOSE', 'PERDEU', 'PERDIÓ', 'PERDU');
  String get push => _s('PUSH', 'EMPATE', 'EMPATE', 'ÉGALITÉ');
  String get bust => _s('BUST!', 'FALIU!', '¡SIN FICHAS!', 'RUINÉ !');
  String get bustMsg => _s(
        "You're out of chips.\nLeave the table and come back to play again.",
        'Você ficou sem fichas.\nSaia da mesa e volte para jogar novamente.',
        'Te quedaste sin fichas.\nSal de la mesa y vuelve para jugar de nuevo.',
        "Vous n'avez plus de jetons.\nQuittez la table et revenez jouer.",
      );
  String get leaveTable =>
      _s('LEAVE TABLE', 'SAIR DA MESA', 'SALIR DE LA MESA', 'QUITTER LA TABLE');
  String slotInfo(int slot, int bet, int chips) => _s(
        'Slot $slot  •  Bet: \$$bet  •  Chips: \$$chips',
        'Slot $slot  •  Aposta: \$$bet  •  Fichas: \$$chips',
        'Slot $slot  •  Apuesta: \$$bet  •  Fichas: \$$chips',
        'Slot $slot  •  Mise: \$$bet  •  Jetons: \$$chips',
      );
  String slotAction(int slot, int value) =>
      'Slot $slot  •  $value';
  String get chipsLabel => _s('Chips:', 'Fichas:', 'Fichas:', 'Jetons:');

  // ── Poker ──────────────────────────────────────────────────────────────────
  String get preflop => _s('PRE-FLOP', 'PRÉ-FLOP', 'PRE-FLOP', 'PRÉ-FLOP');
  String get flop => _s('FLOP', 'FLOP', 'FLOP', 'FLOP');
  String get turn => _s('TURN', 'TURN', 'TURN', 'TOURNANT');
  String get river => _s('RIVER', 'RIVER', 'RIVER', 'RIVIÈRE');
  String get showdown =>
      _s('SHOWDOWN', 'CONFRONTO', 'ENFRENTAMIENTO', 'ABATTAGE');
  String get fold => _s('FOLD', 'DESISTIR', 'RETIRARSE', 'SE COUCHER');
  String get check => _s('CHECK', 'PASSAR', 'PASAR', 'CHECKER');
  String get callBtn => _s('CALL', 'PAGAR', 'IGUALAR', 'SUIVRE');
  String get raiseBtn => _s('RAISE', 'AUMENTAR', 'SUBIR', 'RELANCER');
  String get raiseLabel =>
      _s('RAISE  ', 'AUMENTAR  ', 'SUBIR  ', 'RELANCER  ');
  String get thinking =>
      _s('Thinking...', 'Pensando...', 'Pensando...', 'Réflexion...');
  String get waiting =>
      _s('Waiting...', 'Aguardando...', 'Esperando...', 'En attente...');
  String get nextHand =>
      _s('NEXT HAND', 'PRÓXIMA MÃO', 'SIGUIENTE MANO', 'MAIN SUIVANTE');
  String get bustLeave => _s(
        'BUST — LEAVE TABLE',
        'FALIU — SAIR DA MESA',
        'SIN FICHAS — SALIR',
        'RUINÉ — QUITTER',
      );
  String get youWin => _s(
        'YOU WIN! — NEW GAME',
        'VOCÊ GANHOU! — NOVO JOGO',
        '¡GANASTE! — NUEVO JUEGO',
        'VOUS GAGNEZ ! — NOUVEAU JEU',
      );

  // ── Poker Setup ────────────────────────────────────────────────────────────
  String get opponents => _s(
        'NUMBER OF OPPONENTS',
        'NÚMERO DE ADVERSÁRIOS',
        'NÚMERO DE OPONENTES',
        "NOMBRE D'ADVERSAIRES",
      );
  String get aiDifficulty => _s(
        'AI DIFFICULTY',
        'DIFICULDADE DA IA',
        'DIFICULTAD DE LA IA',
        "DIFFICULTÉ DE L'IA",
      );
  String get startGame =>
      _s('START GAME', 'INICIAR JOGO', 'INICIAR JUEGO', 'COMMENCER');
  String botCount(int n) =>
      n == 1 ? _s('bot', 'bot', 'bot', 'bot') : _s('bots', 'bots', 'bots', 'bots');
  String get easyLabel => _s('EASY', 'FÁCIL', 'FÁCIL', 'FACILE');
  String get mediumLabel => _s('MEDIUM', 'MÉDIO', 'MEDIO', 'MOYEN');
  String get hardLabel => _s('HARD', 'DIFÍCIL', 'DIFÍCIL', 'DIFFICILE');
  String get masterLabel => _s('MASTER', 'MESTRE', 'MAESTRO', 'MAÎTRE');
  String get easyDesc => _s(
        "Beginner bots — they barely know the rules.",
        'Bots iniciantes — mal sabem as regras.',
        'Bots principiantes — apenas conocen las reglas.',
        'Bots débutants — ils connaissent à peine les règles.',
      );
  String get mediumDesc => _s(
        'Solid players with decent strategy.',
        'Jogadores sólidos com boa estratégia.',
        'Jugadores sólidos con buena estrategia.',
        'Joueurs solides avec une bonne stratégie.',
      );
  String get hardDesc => _s(
        'Card-counters winning ~60-70% of the time.',
        'Contadores de cartas, ~60-70% de vitórias.',
        'Contadores de cartas, ~60-70% de victorias.',
        'Compteurs de cartes, ~60-70% de victoires.',
      );
  String get masterDesc => _s(
        'They see your cards. Good luck.',
        'Eles veem suas cartas. Boa sorte.',
        'Ven tus cartas. Buena suerte.',
        'Ils voient vos cartes. Bonne chance.',
      );
}
