import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goldz/core/cashe/hive_boxes.dart';
import 'package:goldz/features/auth/presentation/login_screen.dart';
import 'package:goldz/features/splash/screens/animated_splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/currency/currency_cubit.dart';
import 'core/di/injection.dart';
import 'core/market_category/category_cubit.dart';
import 'core/settings/settings_cubit.dart';
import 'core/shell/shell_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/gold_prices/presentation/cubit/market_cubit.dart';
import 'features/shell/presentation/screens/main_shell.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // Hive must be ready before DI, because the box is injected.
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.market);

  await initDependencies();

  runApp(const GoldzApp());
}

class GoldzApp extends StatelessWidget {
  const GoldzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(create: (_) => sl<SettingsCubit>()),
        BlocProvider(create: (_) => ShellCubit()),
        BlocProvider(create: (_) => CategoryCubit()),
        // Starts fetching during the splash animation.
        BlocProvider(create: (_) => sl<MarketCubit>()..load()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Goldz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (_) => const AnimatedSplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}