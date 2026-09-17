import 'package:flutter/material.dart';

/// Un tema de color de la app. Cada tema se construye a partir de un color
/// "semilla" con `ColorScheme.fromSeed`, así que genera de forma coherente la
/// variante clara y la oscura en Material 3.
class AppTheme {
  /// Clave estable: es lo que se guarda en preferencias y con lo que
  /// `AppStrings.themeName` busca el nombre traducido.
  final String id;
  final Color seed;
  final IconData icon;

  const AppTheme({required this.id, required this.seed, required this.icon});
}

/// Catálogo de temas disponibles. El primero (teal) es el de la app original y
/// actúa como valor por defecto.
const List<AppTheme> kAppThemes = [
  AppTheme(id: 'teal', seed: Color(0xFF00796B), icon: Icons.spa_outlined),
  AppTheme(id: 'sunset', seed: Color(0xFFE64A19), icon: Icons.wb_twilight),
  AppTheme(
    id: 'grape',
    seed: Color(0xFF6A1B9A),
    icon: Icons.local_bar_outlined,
  ),
  AppTheme(id: 'ocean', seed: Color(0xFF0277BD), icon: Icons.waves),
  AppTheme(id: 'forest', seed: Color(0xFF2E7D32), icon: Icons.forest_outlined),
  AppTheme(id: 'ruby', seed: Color(0xFFC2185B), icon: Icons.favorite_outline),
  AppTheme(id: 'amber', seed: Color(0xFFFF8F00), icon: Icons.wb_sunny_outlined),
  AppTheme(
    id: 'midnight',
    seed: Color(0xFF303F9F),
    icon: Icons.nightlight_outlined,
  ),
  AppTheme(
    id: 'crimson',
    seed: Color(0xFFE02218),
    icon: Icons.local_fire_department,
  ),
];

/// Devuelve el tema con ese [id], o el primero del catálogo si no existe.
AppTheme appThemeById(String? id) =>
    kAppThemes.firstWhere((t) => t.id == id, orElse: () => kAppThemes.first);
