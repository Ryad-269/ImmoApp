import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_property_screen.dart';
import 'screens/owner_dashboard_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmoDakar',
      initialRoute: '/',

      theme: ThemeData(
        primarySwatch: Colors.blue,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          secondary: const Color(0xFFF5A623),
        ),
        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        // Boutons principaux (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5A623),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Boutons secondaires (OutlinedButton)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E3C72),
            side: const BorderSide(color: Color(0xFF1E3C72)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Champs de texte
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1E3C72)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/add-property': (context) => AddPropertyScreen(),
        '/dashboard': (context) => OwnerDashboardScreen(),
      },
    );
  }
}
