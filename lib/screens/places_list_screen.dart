import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';
import 'place_detail_screen.dart';

class PlacesListScreen extends StatelessWidget {
  final Category category;

  const PlacesListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Consulta a la tabla 'places' filtrando por category_id
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
            return const Center(child: Text("No hay lugares en esta categoría aún."));
          }

          final places = snapshot.data!.map((e) => Place.fromMap(e)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place))
                  ),
                  child: Column(
                    children: [
                      Image.network(
                        place.thumbnailUrl, 
                        height: 180, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(height: 180, color: Colors.grey),
                      ),
                      ListTile(
                        title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(place.address),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(place.rating.toString()),
                          ],
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
    );
  }
}