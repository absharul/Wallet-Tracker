import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox('settings'); // Open settings box
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        // We can extend this to support system/light/dark tri-state later
        // or just map a string 'themeMode' to ThemeMode.
        final String themeModeString = box.get(
          'themeMode',
          defaultValue: 'System',
        );

        ThemeMode themeMode;
        switch (themeModeString) {
          case 'Light':
            themeMode = ThemeMode.light;
            break;
          case 'Dark':
            themeMode = ThemeMode.dark;
            break;
          case 'System':
          default:
            themeMode = ThemeMode.system;
        }

        return MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4), // Deep Purple
              brightness: Brightness.light,
              surface: const Color(0xFFFDFBFF),
            ),
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent, // Modern transparent app bar
              foregroundColor: Colors.black87,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorColor: const Color(0xFFEADDFF),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Color(0xFF21005D));
                }
                return const IconThemeData(color: Color(0xFF49454F));
              }),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD0BCFF),
              brightness: Brightness.dark,
              surface: const Color(0xFF141218),
            ),
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
                .apply(
                  bodyColor: const Color(0xFFE6E1E5),
                  displayColor: const Color(0xFFE6E1E5),
                ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
            ),
          ),
          themeMode: themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
