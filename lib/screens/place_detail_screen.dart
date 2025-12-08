import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place_model.dart';
import '../services/auth_service.dart';

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
    
    // Obtener ID del usuario desde SharedPreferences
    final userId = await AuthService.getCurrentUserId();
    
    if (userId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de sesión')));
      return;
    }

    try {
      // INSERTAR EN LA TABLA BOOKINGS
      await Supabase.instance.client.from('bookings').insert({
        'user_id': userId,
        'place_id': widget.place.id,
        'booking_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'people_count': int.parse(_peopleCtrl.text),
        'status_id': 1, // Pendiente (ID 1 en DB)
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Reserva creada exitosamente!')));
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
      appBar: AppBar(title: Text(widget.place.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.place.thumbnailUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.place.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.place.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text("Reservar Visita", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Selector de Fecha
                  ListTile(
                    title: const Text("Fecha"),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context, 
                        initialDate: _selectedDate, 
                        firstDate: DateTime.now(), 
                        lastDate: DateTime.now().add(const Duration(days: 365))
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                  
                  // Cantidad de Personas
                  TextField(
                    controller: _peopleCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad de Personas', icon: Icon(Icons.people)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isBooking ? null : _makeReservation,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: _isBooking 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("CONFIRMAR RESERVA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}