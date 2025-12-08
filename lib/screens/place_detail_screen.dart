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

  Future<void> _makeReservation() async {
    setState(() => _isBooking = true);
    final userId = await AuthService.getCurrentUserId();
    
    if (userId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de sesión')));
      return;
    }

    try {
      await Supabase.instance.client.from('bookings').insert({
        'user_id': userId,
        'place_id': widget.place.id,
        'booking_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'people_count': int.parse(_peopleCtrl.text),
        'status_id': 1,
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
            // HEADER CON IMAGEN Y BOTÓN ATRÁS
            Stack(
              children: [
                widget.place.thumbnailUrl.startsWith('http')
                      ? Image.network(
                          widget.place.thumbnailUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 300, color: Colors.grey),
                        )
                      : Image.asset(
                          widget.place.thumbnailUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            color: Colors.grey,
                            child: const Center(child: Text("Imagen no encontrada")),
                          ),
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
              ],
            ),
            
            // CONTENIDO BLANCO REDONDEADO HACIA ARRIBA
            Transform.translate(
              offset: const Offset(0, -30), // Sube el contenedor sobre la imagen
              child: Container(
                decoration: const BoxDecoration(
                  color: kBackgroundColor, // Fondo de la app
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
                          child: Text(
                            widget.place.name, 
                            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: kTextColor)
                          ),
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
                    const SizedBox(height: 20),
                    Text("Descripción", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      widget.place.description, 
                      style: GoogleFonts.poppins(color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    
                    // TARJETA DE RESERVA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reserva tu visita", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context, 
                                initialDate: _selectedDate, 
                                firstDate: DateTime.now(), 
                                lastDate: DateTime.now().add(const Duration(days: 365))
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}"),
                                  const Icon(Icons.calendar_today, size: 20, color: kPrimaryColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _peopleCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad de Personas', 
                              prefixIcon: Icon(Icons.people_outline),
                              fillColor: kBackgroundColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isBooking ? null : _makeReservation,
                              child: _isBooking 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("CONFIRMAR RESERVA"),
                            ),
                          )
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