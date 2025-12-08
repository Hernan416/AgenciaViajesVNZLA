import 'package:flutter/material.dart';

// REEMPLAZA ESTO CON TUS CREDENCIALES REALES DE SUPABASE
const supabaseUrl = 'https://lavkaxojvdwukzafqkuq.supabase.co'; 
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhdmtheG9qdmR3dWt6YWZxa3VxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NDQ4NzAsImV4cCI6MjA4MDAyMDg3MH0.XLO_4XtNXvlACNnWDornOWUPdDrg7zN_dkZxVhdO8qg';

// Mapeo de iconos que vienen de la BD (texto) a Iconos de Flutter
IconData getIconFromKey(String key) {
  switch (key) {
    case 'restaurant': return Icons.restaurant;
    case 'hotel': return Icons.hotel;
    case 'beach_access': return Icons.beach_access;
    case 'museum': return Icons.museum;
    case 'wifi': return Icons.wifi;
    case 'pool': return Icons.pool;
    case 'local_parking': return Icons.local_parking;
    case 'water': return Icons.water;
    case 'ac_unit': return Icons.ac_unit;
    default: return Icons.place;
  }
}