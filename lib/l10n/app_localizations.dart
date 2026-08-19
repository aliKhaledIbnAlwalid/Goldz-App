import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Goldz'**
  String get appName;

  /// No description provided for @liveMarket.
  ///
  /// In en, this message translates to:
  /// **'LIVE MARKET'**
  String get liveMarket;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(Object name);

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @karats.
  ///
  /// In en, this message translates to:
  /// **'Karats'**
  String get karats;

  /// No description provided for @purities.
  ///
  /// In en, this message translates to:
  /// **'Purities'**
  String get purities;

  /// No description provided for @rates.
  ///
  /// In en, this message translates to:
  /// **'Rates'**
  String get rates;

  /// No description provided for @otherKarats.
  ///
  /// In en, this message translates to:
  /// **'Other Karats'**
  String get otherKarats;

  /// No description provided for @otherPurities.
  ///
  /// In en, this message translates to:
  /// **'Other Purities'**
  String get otherPurities;

  /// No description provided for @otherRates.
  ///
  /// In en, this message translates to:
  /// **'Other Rates'**
  String get otherRates;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'VIEW DETAILS'**
  String get viewDetails;

  /// No description provided for @perGram.
  ///
  /// In en, this message translates to:
  /// **'{code} / Gram'**
  String perGram(Object code);

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'{code} per unit'**
  String perUnit(Object code);

  /// No description provided for @noChangeData.
  ///
  /// In en, this message translates to:
  /// **'no change data yet'**
  String get noChangeData;

  /// No description provided for @globalOunce.
  ///
  /// In en, this message translates to:
  /// **'Global Ounce'**
  String get globalOunce;

  /// No description provided for @localOunce.
  ///
  /// In en, this message translates to:
  /// **'Local Ounce'**
  String get localOunce;

  /// No description provided for @goldPound.
  ///
  /// In en, this message translates to:
  /// **'Gold Pound'**
  String get goldPound;

  /// No description provided for @usdRate.
  ///
  /// In en, this message translates to:
  /// **'USD Rate'**
  String get usdRate;

  /// No description provided for @sterling100g.
  ///
  /// In en, this message translates to:
  /// **'Sterling 100g'**
  String get sterling100g;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// No description provided for @euro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get euro;

  /// No description provided for @britishPound.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get britishPound;

  /// No description provided for @saudiRiyal.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get saudiRiyal;

  /// No description provided for @allTitle.
  ///
  /// In en, this message translates to:
  /// **'All {category}'**
  String allTitle(Object category);

  /// No description provided for @highestPurity.
  ///
  /// In en, this message translates to:
  /// **'Highest Purity'**
  String get highestPurity;

  /// No description provided for @mostTraded.
  ///
  /// In en, this message translates to:
  /// **'Most Traded'**
  String get mostTraded;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @valuationCalculator.
  ///
  /// In en, this message translates to:
  /// **'Valuation Calculator'**
  String get valuationCalculator;

  /// No description provided for @valuationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate your asset\'s current market worth.'**
  String get valuationSubtitle;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weight;

  /// No description provided for @purityKarat.
  ///
  /// In en, this message translates to:
  /// **'PURITY (KARAT)'**
  String get purityKarat;

  /// No description provided for @estimatedValue.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED VALUE'**
  String get estimatedValue;

  /// No description provided for @pricePerGram.
  ///
  /// In en, this message translates to:
  /// **'Price per gram'**
  String get pricePerGram;

  /// No description provided for @purity.
  ///
  /// In en, this message translates to:
  /// **'Purity'**
  String get purity;

  /// No description provided for @karatWithPercent.
  ///
  /// In en, this message translates to:
  /// **'{karat} Karat · {percent}%'**
  String karatWithPercent(Object karat, Object percent);

  /// No description provided for @calculatorDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Values are estimates based on live market spot prices. Actual transactional values may vary depending on local dealer premiums, manufacturing fees, and physical condition.'**
  String get calculatorDisclaimer;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live gold prices in Egypt — sign in to continue'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track gold prices and save your favorites'**
  String get createAccountSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get forgotPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordTooShort;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @allPrices.
  ///
  /// In en, this message translates to:
  /// **'All Prices'**
  String get allPrices;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @priceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get priceAlerts;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get signOut;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guestSession.
  ///
  /// In en, this message translates to:
  /// **'Guest session'**
  String get guestSession;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency;

  /// No description provided for @currencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prices will be converted instantly'**
  String get currencySubtitle;

  /// No description provided for @couldNotLoadPrices.
  ///
  /// In en, this message translates to:
  /// **'Could not load prices'**
  String get couldNotLoadPrices;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection. We need to be online to fetch the latest market data.'**
  String get offlineMessage;

  /// No description provided for @showingSavedPrices.
  ///
  /// In en, this message translates to:
  /// **'Showing saved prices — you may be offline'**
  String get showingSavedPrices;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @updatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {time} · prices are indicative'**
  String updatedAgo(Object time);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(Object count);

  /// No description provided for @descRawGold.
  ///
  /// In en, this message translates to:
  /// **'RAW GOLD'**
  String get descRawGold;

  /// No description provided for @descStandard.
  ///
  /// In en, this message translates to:
  /// **'STANDARD'**
  String get descStandard;

  /// No description provided for @descPopularJewelry.
  ///
  /// In en, this message translates to:
  /// **'POPULAR JEWELRY'**
  String get descPopularJewelry;

  /// No description provided for @descFineJewelry.
  ///
  /// In en, this message translates to:
  /// **'FINE JEWELRY'**
  String get descFineJewelry;

  /// No description provided for @descAlloy.
  ///
  /// In en, this message translates to:
  /// **'ALLOY'**
  String get descAlloy;

  /// No description provided for @descLowAlloy.
  ///
  /// In en, this message translates to:
  /// **'LOW ALLOY'**
  String get descLowAlloy;

  /// No description provided for @descBudgetAlloy.
  ///
  /// In en, this message translates to:
  /// **'BUDGET ALLOY'**
  String get descBudgetAlloy;

  /// No description provided for @descMinimumPurity.
  ///
  /// In en, this message translates to:
  /// **'MINIMUM PURITY'**
  String get descMinimumPurity;

  /// No description provided for @descFineSilver.
  ///
  /// In en, this message translates to:
  /// **'FINE SILVER'**
  String get descFineSilver;

  /// No description provided for @descBritannia.
  ///
  /// In en, this message translates to:
  /// **'BRITANNIA'**
  String get descBritannia;

  /// No description provided for @descSterling.
  ///
  /// In en, this message translates to:
  /// **'STERLING'**
  String get descSterling;

  /// No description provided for @descLowGrade.
  ///
  /// In en, this message translates to:
  /// **'LOW GRADE'**
  String get descLowGrade;

  /// No description provided for @descExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'EXCHANGE RATE'**
  String get descExchangeRate;

  /// No description provided for @karatLabel.
  ///
  /// In en, this message translates to:
  /// **'Karat {k}'**
  String karatLabel(Object k);

  /// No description provided for @silverLabel.
  ///
  /// In en, this message translates to:
  /// **'Silver {p}'**
  String silverLabel(Object p);

  /// No description provided for @noDataFor.
  ///
  /// In en, this message translates to:
  /// **'No {category} data available.'**
  String noDataFor(Object category);

  /// No description provided for @nothingToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get nothingToShow;

  /// No description provided for @pricesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prices unavailable — try again later.'**
  String get pricesUnavailable;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset it.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @resetEmailSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, we\'ve sent a reset link. Check your spam folder too.'**
  String get resetEmailSentBody;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToLogin;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
