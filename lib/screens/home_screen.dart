import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'bookings_screen.dart';
import 'places_list_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final name = await AuthService.getCurrentUserName();
    if (mounted) setState(() => userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('categories').stream(primaryKey: ['id']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Margarita Travel 🌴"),
        actions: [
          // BOTÓN DE FAVORITOS (NUEVO)
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
            tooltip: 'Mis Favoritos',
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const FavoritesScreen())
              );
            },
          ),

          // BOTÓN DE MIS RESERVAS
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: kPrimaryColor),
            tooltip: 'Mis Reservaciones',
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const BookingsScreen()) // <--- Necesitas importar este archivo arriba
              );
            },
          ),
          
          // BOTÓN DE CERRAR SESIÓN
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen()), 
                (r) => false
              );
            },
          ),
          const SizedBox(width: 10), // Espacio extra a la derecha
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Text(
              "Hola, $userName 👋\n¿Qué quieres descubrir?", 
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final categories = snapshot.data!.map((e) => Category.fromMap(e)).toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1 
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => PlacesListScreen(category: cat))
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(getIconFromKey(cat.iconKey), size: 32, color: kPrimaryColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              cat.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16, 
                                fontWeight: FontWeight.w600,
                                color: kTextColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}