import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  Future<List<Map<String, dynamic>>>? _futureBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    final userId = await AuthService.getCurrentUserId();
    
    if (userId != null) {
      setState(() {
        // CAMBIO CLAVE: Agregamos 'room_types(*)' a la consulta
        _futureBookings = Supabase.instance.client
            .from('bookings')
            .select('*, places(*), room_types(*)') 
            .eq('user_id', userId)
            .order('booking_date', ascending: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text("Mis Reservaciones")),
      body: _futureBookings == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureBookings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text("Aún no tienes reservas", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final bookings = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final place = booking['places'];
                    final roomType = booking['room_types']; // Esto puede ser null (si es restaurante)
                    final date = DateTime.parse(booking['booking_date']);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // FILA SUPERIOR: IMAGEN Y DATOS BÁSICOS
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // IMAGEN REDONDEADA
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: place['thumbnail_url'].toString().startsWith('http')
                                        ? Image.network(place['thumbnail_url'], fit: BoxFit.cover)
                                        : Image.asset(place['thumbnail_url'], fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // INFO PRINCIPAL
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place['name'],
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      // FECHA
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_month, size: 14, color: kPrimaryColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(date),
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                      // PERSONAS
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.people, size: 14, color: kPrimaryColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${booking['people_count']} personas",
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // SI HAY HABITACIÓN, MOSTRAR DETALLE ABAJO
                            if (roomType != null) ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kSecondaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: const Icon(Icons.bed, size: 18, color: Colors.orange),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Habitación",
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        roomType['name'], // AQUÍ SE MUESTRA "Matrimonial", "Individual", etc.
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ]
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