import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../models/place_model.dart';
import 'place_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<Place>>? _futureFavorites;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId != null) {
      setState(() {
        // Consulta relacional: Trae los favoritos del usuario Y los datos del lugar
        _futureFavorites = Supabase.instance.client
            .from('favorites')
            .select('places(*)') // Solo nos importa la info del lugar
            .eq('user_id', userId)
            .then((data) {
              // Convertimos la respuesta a una lista de objetos Place
              // La respuesta viene como: [{'places': {id: 1, name: ...}}, ...]
              return List<Map<String, dynamic>>.from(data)
                  .map((e) => Place.fromMap(e['places']))
                  .toList();
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text("Mis Favoritos ❤️")),
      body: _futureFavorites == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Place>>(
              future: _futureFavorites,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text("No tienes favoritos aún", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final places = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return GestureDetector(
                      onTap: () async {
                        // Navegar al detalle y recargar al volver (por si quita el like)
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
                        );
                        _loadFavorites(); // Recargar lista al volver
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            // FOTO
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                              child: SizedBox(
                                width: 120,
                                height: double.infinity,
                                child: place.thumbnailUrl.startsWith('http')
                                    ? Image.network(place.thumbnailUrl, fit: BoxFit.cover)
                                    : Image.asset(place.thumbnailUrl, fit: BoxFit.cover),
                              ),
                            ),
                            // INFO
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: kSecondaryColor),
                                        const SizedBox(width: 4),
                                        Text(place.rating.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                        const Spacer(),
                                        const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}