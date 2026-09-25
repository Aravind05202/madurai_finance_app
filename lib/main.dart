import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaduraiFinanceApp());
}

class MaduraiFinanceApp extends StatelessWidget {
  const MaduraiFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Madurai Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: AppColors.deepGreen,
            onPrimary: Colors.white,
            primaryContainer: AppColors.primary,
            onPrimaryContainer: Colors.white,
            secondary: AppColors.gold,
            onSecondary: Colors.white,
            secondaryContainer: AppColors.goldLight,
            onSecondaryContainer: AppColors.deepGreen,
            tertiary: AppColors.green,
            onTertiary: Colors.white,
            tertiaryContainer: AppColors.mint,
            onTertiaryContainer: AppColors.deepGreen,
            surface: AppColors.card,
            onSurface: AppColors.textDark,
            error: AppColors.danger,
            onError: Colors.white,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.deepGreen,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: AppColors.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

