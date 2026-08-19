// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'جولدز';

  @override
  String get liveMarket => 'السوق المباشر';

  @override
  String greeting(Object name) {
    return 'أهلاً $name';
  }

  @override
  String get gold => 'ذهب';

  @override
  String get silver => 'فضة';

  @override
  String get currency => 'عملات';

  @override
  String get karats => 'العيارات';

  @override
  String get purities => 'النقاوة';

  @override
  String get rates => 'الأسعار';

  @override
  String get otherKarats => 'عيارات أخرى';

  @override
  String get otherPurities => 'نقاوات أخرى';

  @override
  String get otherRates => 'أسعار أخرى';

  @override
  String get live => 'مباشر';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String perGram(Object code) {
    return '$code / جرام';
  }

  @override
  String perUnit(Object code) {
    return '$code للوحدة';
  }

  @override
  String get noChangeData => 'لا توجد بيانات تغيّر بعد';

  @override
  String get globalOunce => 'الأوقية العالمية';

  @override
  String get localOunce => 'الأوقية المحلية';

  @override
  String get goldPound => 'الجنيه الذهب';

  @override
  String get usdRate => 'سعر الدولار';

  @override
  String get sterling100g => 'استرليني ١٠٠ جم';

  @override
  String get usDollar => 'الدولار الأمريكي';

  @override
  String get euro => 'اليورو';

  @override
  String get britishPound => 'الجنيه الإسترليني';

  @override
  String get saudiRiyal => 'الريال السعودي';

  @override
  String allTitle(Object category) {
    return 'كل $category';
  }

  @override
  String get highestPurity => 'الأعلى نقاءً';

  @override
  String get mostTraded => 'الأكثر تداولاً';

  @override
  String get calculator => 'الحاسبة';

  @override
  String get valuationCalculator => 'حاسبة التقييم';

  @override
  String get valuationSubtitle => 'احسب القيمة السوقية الحالية لممتلكاتك.';

  @override
  String get weight => 'الوزن';

  @override
  String get purityKarat => 'العيار';

  @override
  String get estimatedValue => 'القيمة التقديرية';

  @override
  String get pricePerGram => 'سعر الجرام';

  @override
  String get purity => 'العيار';

  @override
  String karatWithPercent(Object karat, Object percent) {
    return 'عيار $karat · $percent٪';
  }

  @override
  String get calculatorDisclaimer =>
      'القيم تقديرية بناءً على أسعار السوق اللحظية. القيمة الفعلية قد تختلف حسب هامش التاجر والمصنعية وحالة القطعة.';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInSubtitle => 'أسعار الذهب في مصر — سجّل الدخول للمتابعة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get or => 'أو';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get createAccountSubtitle => 'تابع أسعار الذهب واحفظ مفضلاتك';

  @override
  String get forgotPassword => 'نسيتها؟';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordTooShort => '٦ أحرف على الأقل';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get nameTooShort => 'الاسم يجب أن يكون ٣ أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get settings => 'الإعدادات';

  @override
  String get market => 'السوق';

  @override
  String get allPrices => 'كل الأسعار';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get priceAlerts => 'تنبيهات الأسعار';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get guest => 'زائر';

  @override
  String get guestSession => 'جلسة زائر';

  @override
  String get displayCurrency => 'عملة العرض';

  @override
  String get currencySubtitle => 'سيتم تحويل الأسعار فوراً';

  @override
  String get couldNotLoadPrices => 'تعذّر تحميل الأسعار';

  @override
  String get offlineMessage =>
      'تحقق من اتصالك بالإنترنت. نحتاج للاتصال لجلب أحدث بيانات السوق.';

  @override
  String get showingSavedPrices => 'نعرض أسعاراً محفوظة — قد تكون غير متصل';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get retry => 'إعادة';

  @override
  String updatedAgo(Object time) {
    return 'آخر تحديث $time · الأسعار استرشادية';
  }

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(Object count) {
    return 'منذ $count د';
  }

  @override
  String hoursAgo(Object count) {
    return 'منذ $count س';
  }

  @override
  String daysAgo(Object count) {
    return 'منذ $count ي';
  }

  @override
  String get descRawGold => 'ذهب خام';

  @override
  String get descStandard => 'قياسي';

  @override
  String get descPopularJewelry => 'مجوهرات شائعة';

  @override
  String get descFineJewelry => 'مجوهرات فاخرة';

  @override
  String get descAlloy => 'سبيكة';

  @override
  String get descLowAlloy => 'سبيكة منخفضة';

  @override
  String get descBudgetAlloy => 'سبيكة اقتصادية';

  @override
  String get descMinimumPurity => 'أقل نقاء';

  @override
  String get descFineSilver => 'فضة نقية';

  @override
  String get descBritannia => 'بريتانيا';

  @override
  String get descSterling => 'استرليني';

  @override
  String get descLowGrade => 'درجة منخفضة';

  @override
  String get descExchangeRate => 'سعر الصرف';

  @override
  String karatLabel(Object k) {
    return 'عيار $k';
  }

  @override
  String silverLabel(Object p) {
    return 'فضة $p';
  }

  @override
  String noDataFor(Object category) {
    return 'لا توجد بيانات $category.';
  }

  @override
  String get nothingToShow => 'لا يوجد ما يُعرض بعد.';

  @override
  String get pricesUnavailable => 'الأسعار غير متاحة — حاول لاحقاً.';
}
