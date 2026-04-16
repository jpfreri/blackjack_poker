import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @bjSubtitle.
  ///
  /// In en, this message translates to:
  /// **'5 Betting Slots  ·  Beat the Dealer'**
  String get bjSubtitle;

  /// No description provided for @pokerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 4 AI Opponents  ·  4 Difficulties'**
  String get pokerSubtitle;

  /// No description provided for @dealer.
  ///
  /// In en, this message translates to:
  /// **'DEALER'**
  String get dealer;

  /// No description provided for @dealing.
  ///
  /// In en, this message translates to:
  /// **'Dealing...'**
  String get dealing;

  /// No description provided for @hit.
  ///
  /// In en, this message translates to:
  /// **'HIT'**
  String get hit;

  /// No description provided for @stand.
  ///
  /// In en, this message translates to:
  /// **'STAND'**
  String get stand;

  /// No description provided for @doubleDown.
  ///
  /// In en, this message translates to:
  /// **'DOUBLE'**
  String get doubleDown;

  /// No description provided for @deal.
  ///
  /// In en, this message translates to:
  /// **'DEAL'**
  String get deal;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// No description provided for @allIn.
  ///
  /// In en, this message translates to:
  /// **'ALL IN'**
  String get allIn;

  /// No description provided for @betBtn.
  ///
  /// In en, this message translates to:
  /// **'BET'**
  String get betBtn;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'NEXT ROUND'**
  String get nextRound;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'WIN'**
  String get win;

  /// No description provided for @lose.
  ///
  /// In en, this message translates to:
  /// **'LOSE'**
  String get lose;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'PUSH'**
  String get push;

  /// No description provided for @bust.
  ///
  /// In en, this message translates to:
  /// **'BUST!'**
  String get bust;

  /// No description provided for @bustMsg.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of chips.\nLeave the table and come back to play again.'**
  String get bustMsg;

  /// No description provided for @leaveTable.
  ///
  /// In en, this message translates to:
  /// **'LEAVE TABLE'**
  String get leaveTable;

  /// No description provided for @slotInfo.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot}  •  Bet: \${bet}  •  Chips: \${chips}'**
  String slotInfo(int slot, int bet, int chips);

  /// No description provided for @preflop.
  ///
  /// In en, this message translates to:
  /// **'PRE-FLOP'**
  String get preflop;

  /// No description provided for @flop.
  ///
  /// In en, this message translates to:
  /// **'FLOP'**
  String get flop;

  /// No description provided for @turn.
  ///
  /// In en, this message translates to:
  /// **'TURN'**
  String get turn;

  /// No description provided for @river.
  ///
  /// In en, this message translates to:
  /// **'RIVER'**
  String get river;

  /// No description provided for @showdown.
  ///
  /// In en, this message translates to:
  /// **'SHOWDOWN'**
  String get showdown;

  /// No description provided for @fold.
  ///
  /// In en, this message translates to:
  /// **'FOLD'**
  String get fold;

  /// No description provided for @checkAction.
  ///
  /// In en, this message translates to:
  /// **'CHECK'**
  String get checkAction;

  /// No description provided for @callBtn.
  ///
  /// In en, this message translates to:
  /// **'CALL'**
  String get callBtn;

  /// No description provided for @maxBet.
  ///
  /// In en, this message translates to:
  /// **'MAX BET'**
  String get maxBet;

  /// No description provided for @twoBB.
  ///
  /// In en, this message translates to:
  /// **'2× BB'**
  String get twoBB;

  /// No description provided for @raiseBtn.
  ///
  /// In en, this message translates to:
  /// **'RAISE'**
  String get raiseBtn;

  /// No description provided for @raiseLabel.
  ///
  /// In en, this message translates to:
  /// **'RAISE'**
  String get raiseLabel;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// No description provided for @nextHand.
  ///
  /// In en, this message translates to:
  /// **'NEXT HAND'**
  String get nextHand;

  /// No description provided for @bustLeave.
  ///
  /// In en, this message translates to:
  /// **'BUST — LEAVE TABLE'**
  String get bustLeave;

  /// No description provided for @youWin.
  ///
  /// In en, this message translates to:
  /// **'YOU WIN! — NEW GAME'**
  String get youWin;

  /// No description provided for @opponents.
  ///
  /// In en, this message translates to:
  /// **'NUMBER OF OPPONENTS'**
  String get opponents;

  /// No description provided for @aiDifficulty.
  ///
  /// In en, this message translates to:
  /// **'AI DIFFICULTY'**
  String get aiDifficulty;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get startGame;

  /// No description provided for @botSingular.
  ///
  /// In en, this message translates to:
  /// **'bot'**
  String get botSingular;

  /// No description provided for @botPlural.
  ///
  /// In en, this message translates to:
  /// **'bots'**
  String get botPlural;

  /// No description provided for @easyLabel.
  ///
  /// In en, this message translates to:
  /// **'EASY'**
  String get easyLabel;

  /// No description provided for @mediumLabel.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get mediumLabel;

  /// No description provided for @hardLabel.
  ///
  /// In en, this message translates to:
  /// **'HARD'**
  String get hardLabel;

  /// No description provided for @masterLabel.
  ///
  /// In en, this message translates to:
  /// **'MASTER'**
  String get masterLabel;

  /// No description provided for @easyDesc.
  ///
  /// In en, this message translates to:
  /// **'Beginner bots — they barely know the rules.'**
  String get easyDesc;

  /// No description provided for @mediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Solid players with decent strategy.'**
  String get mediumDesc;

  /// No description provided for @hardDesc.
  ///
  /// In en, this message translates to:
  /// **'Card-counters winning ~60-70% of the time.'**
  String get hardDesc;

  /// No description provided for @masterDesc.
  ///
  /// In en, this message translates to:
  /// **'They see your cards. Good luck.'**
  String get masterDesc;

  /// No description provided for @potLabel.
  ///
  /// In en, this message translates to:
  /// **'POT'**
  String get potLabel;

  /// No description provided for @betLabel.
  ///
  /// In en, this message translates to:
  /// **'BET'**
  String get betLabel;

  /// No description provided for @actionFold.
  ///
  /// In en, this message translates to:
  /// **'Folded'**
  String get actionFold;

  /// No description provided for @actionCheck.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get actionCheck;

  /// No description provided for @actionCall.
  ///
  /// In en, this message translates to:
  /// **'Called'**
  String get actionCall;

  /// No description provided for @actionRaise.
  ///
  /// In en, this message translates to:
  /// **'Raised'**
  String get actionRaise;

  /// No description provided for @actionAllIn.
  ///
  /// In en, this message translates to:
  /// **'All In'**
  String get actionAllIn;

  /// No description provided for @handHighCard.
  ///
  /// In en, this message translates to:
  /// **'High Card'**
  String get handHighCard;

  /// No description provided for @handOnePair.
  ///
  /// In en, this message translates to:
  /// **'One Pair'**
  String get handOnePair;

  /// No description provided for @handTwoPair.
  ///
  /// In en, this message translates to:
  /// **'Two Pair'**
  String get handTwoPair;

  /// No description provided for @handThreeOfAKind.
  ///
  /// In en, this message translates to:
  /// **'Three of a Kind'**
  String get handThreeOfAKind;

  /// No description provided for @handStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get handStraight;

  /// No description provided for @handFlush.
  ///
  /// In en, this message translates to:
  /// **'Flush'**
  String get handFlush;

  /// No description provided for @handFullHouse.
  ///
  /// In en, this message translates to:
  /// **'Full House'**
  String get handFullHouse;

  /// No description provided for @handFourOfAKind.
  ///
  /// In en, this message translates to:
  /// **'Four of a Kind'**
  String get handFourOfAKind;

  /// No description provided for @handStraightFlush.
  ///
  /// In en, this message translates to:
  /// **'Straight Flush'**
  String get handStraightFlush;

  /// No description provided for @handRoyalFlush.
  ///
  /// In en, this message translates to:
  /// **'Royal Flush'**
  String get handRoyalFlush;

  /// No description provided for @logWins.
  ///
  /// In en, this message translates to:
  /// **'{name} wins \${amount}'**
  String logWins(String name, int amount);

  /// No description provided for @logWinsWith.
  ///
  /// In en, this message translates to:
  /// **'{name} wins \${amount} with {handName}'**
  String logWinsWith(String name, int amount, String handName);

  /// No description provided for @logSplit.
  ///
  /// In en, this message translates to:
  /// **'Split \${amount} between {names}'**
  String logSplit(int amount, String names);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
