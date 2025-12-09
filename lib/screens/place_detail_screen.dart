import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/place_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final _peopleCtrl = TextEditingController(text: '1');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isBooking = false;
  
  // VARIABLES DE DATOS
  List<Map<String, dynamic>> _amenities = [];
  List<Map<String, dynamic>> _rooms = [];
  Map<String, dynamic>? _contactInfo; 
  int? _selectedRoomTypeId;
  
  // VARIABLE NUEVA: ESTADO DE FAVORITO
  bool _isFavorite = false; 

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _checkFavoriteStatus(); // <-- VERIFICAR SI YA ES FAVORITO
  }

  void _loadDetails() async {
    final client = Supabase.instance.client;
    final amenitiesData = await client.from('place_amenities').select('amenities(*)').eq('place_id', widget.place.id);
    final roomsData = await client.from('hotel_rooms').select('*, room_types(*)').eq('place_id', widget.place.id);
    final contactData = await client.from('place_contacts').select().eq('place_id', widget.place.id).maybeSingle();

    if (mounted) {
      setState(() {
        _amenities = List<Map<String, dynamic>>.from(amenitiesData);
        _rooms = List<Map<String, dynamic>>.from(roomsData);
        _contactInfo = contactData;
      });
    }
  }

  // Lógica para verificar si ya le di like
  void _checkFavoriteStatus() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return;

    final data = await Supabase.instance.client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('place_id', widget.place.id)
        .maybeSingle();

    if (mounted && data != null) {
      setState(() => _isFavorite = true);
    }
  }

  // Lógica para dar like / dislike
  void _toggleFavorite() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión para guardar favoritos')));
      return;
    }

    setState(() => _isFavorite = !_isFavorite); // Cambio visual inmediato (Optimista)

    try {
      if (_isFavorite) {
        // AGREGAR FAVORITO
        await Supabase.instance.client.from('favorites').insert({
          'user_id': userId,
          'place_id': widget.place.id,
        });
      } else {
        // ELIMINAR FAVORITO
        await Supabase.instance.client.from('favorites').delete()
          .eq('user_id', userId)
          .eq('place_id', widget.place.id);
      }
    } catch (e) {
      // Si falla, revertimos el cambio visual
      if (mounted) setState(() => _isFavorite = !_isFavorite);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar favorito')));
    }
  }

  Future<void> _makeReservation() async {
    if (_rooms.isNotEmpty && _selectedRoomTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona un tipo de habitación')));
      return;
    }
    setState(() => _isBooking = true);
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('bookings').insert({
        'user_id': userId,
        'place_id': widget.place.id,
        'booking_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'people_count': int.parse(_peopleCtrl.text),
        'status_id': 1, 
        'room_type_id': _selectedRoomTypeId, 
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Reserva creada! 🌴')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: widget.place.thumbnailUrl.startsWith('http')
                      ? Image.network(widget.place.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey))
                      : Image.asset(widget.place.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey)),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // --- NUEVO BOTÓN DE FAVORITO ---
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
              ],
            ),
            
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(widget.place.name, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: kTextColor)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(widget.place.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.place.address, style: GoogleFonts.poppins(color: Colors.grey[700])),
                      ],
                    ),
                    
                    if (_contactInfo != null) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (_contactInfo!['phone'] != null)
                            Expanded(child: _ContactChip(icon: Icons.phone, text: _contactInfo!['phone'])),
                          if (_contactInfo!['phone'] != null && _contactInfo!['instagram'] != null)
                             const SizedBox(width: 10),
                          if (_contactInfo!['instagram'] != null)
                            Expanded(child: _ContactChip(icon: Icons.camera_alt, text: _contactInfo!['instagram'], color: Colors.purple)),
                        ],
                      )
                    ],

                    if (_amenities.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text("Lo que ofrece", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: _amenities.map((item) => Chip(
                            avatar: Icon(getIconFromKey(item['amenities']['icon_key']), size: 18, color: kPrimaryColor),
                            label: Text(item['amenities']['name'], style: GoogleFonts.poppins(fontSize: 12)),
                            backgroundColor: Colors.white, side: BorderSide.none, elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          )).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text("Descripción", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.place.description, style: GoogleFonts.poppins(color: Colors.grey[600], height: 1.5)),
                    const SizedBox(height: 30),
                    
                    // CARD RESERVA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reserva tu visita", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (_rooms.isNotEmpty) ...[
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Tipo de Habitación', prefixIcon: Icon(Icons.bed_outlined), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                              value: _selectedRoomTypeId, isExpanded: true,
                              items: _rooms.map((r) => DropdownMenuItem<int>(value: r['room_types']['id'], child: Text("${r['room_types']['name']} (\$${r['price_per_night']})", style: GoogleFonts.poppins(fontSize: 14)))).toList(),
                              onChanged: (v) => setState(() => _selectedRoomTypeId = v),
                            ),
                            const SizedBox(height: 16),
                          ],
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(color: kBackgroundColor, borderRadius: BorderRadius.circular(16)),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}", style: GoogleFonts.poppins()), const Icon(Icons.calendar_today, size: 20, color: kPrimaryColor)]),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(controller: _peopleCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad de Personas', prefixIcon: Icon(Icons.people_outline), fillColor: kBackgroundColor)),
                          const SizedBox(height: 20),
                          SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: _isBooking ? null : _makeReservation, child: _isBooking ? const CircularProgressIndicator(color: Colors.white) : const Text("CONFIRMAR RESERVA"))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para los contactos
class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _ContactChip({required this.icon, required this.text, this.color = kPrimaryColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))]),
    );
  }
}