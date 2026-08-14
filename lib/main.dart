import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/core/cashe/hive_boxes.dart';
import 'package:goldz/features/auth/presentation/login_screen.dart';
import 'package:goldz/features/splash/screens/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/currency/currency_cubit.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/gold_prices/presentation/cubit/market_cubit.dart';
import 'features/gold_prices/presentation/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // Hive must be ready BEFORE DI, because the box is injected.
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
        // Start fetching immediately so prices are ready by the time
        // the splash animation finishes.
        BlocProvider(create: (_) => sl<MarketCubit>()..load()),
      ],
      child: MaterialApp(
        title: 'Goldz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (_) => const AnimatedSplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}