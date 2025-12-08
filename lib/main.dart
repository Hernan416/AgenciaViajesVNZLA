import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 2. Verificar sesión manual guardada
  final prefs = await SharedPreferences.getInstance();
  final hasSession = prefs.containsKey('userId');

  runApp(MyApp(isLoggedIn: hasSession));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margarita Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, // MODO CLARO OBLIGATORIO
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      // Si hay sesión guardada, va al Home, si no al Login
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}