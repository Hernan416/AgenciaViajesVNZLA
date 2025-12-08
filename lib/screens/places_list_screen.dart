import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';
import '../utils/constants.dart'; // Para colores
import 'place_detail_screen.dart';

class PlacesListScreen extends StatelessWidget {
  final Category category;

  const PlacesListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final future = Supabase.instance.client
        .from('places')
        .select()
        .eq('category_id', category.id);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay lugares disponibles.", style: GoogleFonts.poppins()));
          }

          final places = snapshot.data!.map((e) => Place.fromMap(e)).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final place = places[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place))
                ),
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // IMAGEN DE FONDO
                        // IMAGEN DE FONDO (Híbrida: Internet o Local)
                        Positioned.fill(
                          child: place.thumbnailUrl.startsWith('http')
                              ? Image.network(
                                  place.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => Container(color: Colors.grey[300]),
                                )
                              : Image.asset(
                                  place.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => Container(
                                    color: Colors.grey[300], 
                                    child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                                  ),
                                ),
                        ),
                        // DEGRADADO OSCURO
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8)
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // TEXTO
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: kSecondaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    place.address,
                                    style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.9)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // RATING
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: kSecondaryColor, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  place.rating.toString(),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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