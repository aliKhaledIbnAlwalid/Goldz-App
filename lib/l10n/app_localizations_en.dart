// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Goldz';

  @override
  String get liveMarket => 'LIVE MARKET';

  @override
  String greeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get currency => 'Currency';

  @override
  String get karats => 'Karats';

  @override
  String get purities => 'Purities';

  @override
  String get rates => 'Rates';

  @override
  String get otherKarats => 'Other Karats';

  @override
  String get otherPurities => 'Other Purities';

  @override
  String get otherRates => 'Other Rates';

  @override
  String get live => 'LIVE';

  @override
  String get viewDetails => 'VIEW DETAILS';

  @override
  String perGram(Object code) {
    return '$code / Gram';
  }

  @override
  String perUnit(Object code) {
    return '$code per unit';
  }

  @override
  String get noChangeData => 'no change data yet';

  @override
  String get globalOunce => 'Global Ounce';

  @override
  String get localOunce => 'Local Ounce';

  @override
  String get goldPound => 'Gold Pound';

  @override
  String get usdRate => 'USD Rate';

  @override
  String get sterling100g => 'Sterling 100g';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'British Pound';

  @override
  String get saudiRiyal => 'Saudi Riyal';

  @override
  String allTitle(Object category) {
    return 'All $category';
  }

  @override
  String get highestPurity => 'Highest Purity';

  @override
  String get mostTraded => 'Most Traded';

  @override
  String get calculator => 'Calculator';

  @override
  String get valuationCalculator => 'Valuation Calculator';

  @override
  String get valuationSubtitle =>
      'Estimate your asset\'s current market worth.';

  @override
  String get weight => 'WEIGHT';

  @override
  String get purityKarat => 'PURITY (KARAT)';

  @override
  String get estimatedValue => 'ESTIMATED VALUE';

  @override
  String get pricePerGram => 'Price per gram';

  @override
  String get purity => 'Purity';

  @override
  String karatWithPercent(Object karat, Object percent) {
    return '$karat Karat · $percent%';
  }

  @override
  String get calculatorDisclaimer =>
      'Values are estimates based on live market spot prices. Actual transactional values may vary depending on local dealer premiums, manufacturing fees, and physical condition.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle =>
      'Live gold prices in Egypt — sign in to continue';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get or => 'OR';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get createAccountSubtitle =>
      'Track gold prices and save your favorites';

  @override
  String get forgotPassword => 'Forgot?';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Min 6 characters';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameTooShort => 'Name must be at least 3 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get settings => 'Settings';

  @override
  String get market => 'Market';

  @override
  String get allPrices => 'All Prices';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get priceAlerts => 'Price alerts';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get signOut => 'SIGN OUT';

  @override
  String get guest => 'Guest';

  @override
  String get guestSession => 'Guest session';

  @override
  String get displayCurrency => 'Display currency';

  @override
  String get currencySubtitle => 'Prices will be converted instantly';

  @override
  String get couldNotLoadPrices => 'Could not load prices';

  @override
  String get offlineMessage =>
      'Please check your internet connection. We need to be online to fetch the latest market data.';

  @override
  String get showingSavedPrices => 'Showing saved prices — you may be offline';

  @override
  String get tryAgain => 'TRY AGAIN';

  @override
  String get retry => 'Retry';

  @override
  String updatedAgo(Object time) {
    return 'Updated $time · prices are indicative';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String get descRawGold => 'RAW GOLD';

  @override
  String get descStandard => 'STANDARD';

  @override
  String get descPopularJewelry => 'POPULAR JEWELRY';

  @override
  String get descFineJewelry => 'FINE JEWELRY';

  @override
  String get descAlloy => 'ALLOY';

  @override
  String get descLowAlloy => 'LOW ALLOY';

  @override
  String get descBudgetAlloy => 'BUDGET ALLOY';

  @override
  String get descMinimumPurity => 'MINIMUM PURITY';

  @override
  String get descFineSilver => 'FINE SILVER';

  @override
  String get descBritannia => 'BRITANNIA';

  @override
  String get descSterling => 'STERLING';

  @override
  String get descLowGrade => 'LOW GRADE';

  @override
  String get descExchangeRate => 'EXCHANGE RATE';

  @override
  String karatLabel(Object k) {
    return 'Karat $k';
  }

  @override
  String silverLabel(Object p) {
    return 'Silver $p';
  }

  @override
  String noDataFor(Object category) {
    return 'No $category data available.';
  }

  @override
  String get nothingToShow => 'Nothing to show yet.';

  @override
  String get pricesUnavailable => 'Prices unavailable — try again later.';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordTitle => 'Forgot your password?';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset it.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String get resetEmailSentBody =>
      'If an account exists for that email, we\'ve sent a reset link. Check your spam folder too.';

  @override
  String get backToLogin => 'Back to sign in';
}
