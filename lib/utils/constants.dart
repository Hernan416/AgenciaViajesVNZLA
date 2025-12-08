import 'package:flutter/material.dart';

// REEMPLAZA ESTO CON TUS CREDENCIALES REALES DE SUPABASE
const supabaseUrl = 'TU_URL_DE_SUPABASE'; 
const supabaseAnonKey = 'TU_ANON_KEY_DE_SUPABASE';

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