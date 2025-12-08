import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // Iniciar Sesión Manualmente (SELECT a tabla users)
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password) // OJO: Comparación de texto plano (Solo educativo)
        .maybeSingle(); // Devuelve null si no encuentra coincidencia

    if (response != null) {
      await _saveSession(response['id'], response['full_name'], response['email']);
      return response;
    }
    return null;
  }

  // Registro Manual (INSERT a tabla users)
  static Future<bool> register(String email, String password, String fullName) async {
    try {
      await supabase.from('users').insert({
        'email': email,
        'password': password,
        'full_name': fullName,
      });
      return true;
    } catch (e) {
      return false; // Probablemente el email ya existe
    }
  }

  // Guardar datos en el teléfono
  static Future<void> _saveSession(int id, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  // Obtener ID del usuario actual
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Obtener Nombre del usuario actual
  static Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Usuario';
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}