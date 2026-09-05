import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// Un logro: algo que se desbloquea solo, mirando lo que ya hay guardado.
/// No se persiste nada; se calcula al vuelo desde los datos reales.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  /// Progreso hacia el logro (0.0 a 1.0). 1.0 cuando está conseguido.
  final double progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.progress,
  });
}

/// Datos mínimos necesarios para calcular los logros.
class AchievementStats {
  final int foods;
  final int streak;
  final int loggedDays;
  final int plannedWeeks;
  final int photos;
  final int daysProteinMet;
  final int perfectWeeks;

  const AchievementStats({
    required this.foods,
    required this.streak,
    required this.loggedDays,
    required this.plannedWeeks,
    required this.photos,
    required this.daysProteinMet,
    required this.perfectWeeks,
  });
}

/// Calcula la lista de logros. Los conseguidos van primero.
///
/// El id de cada logro es su clave estable; el título y la descripción salen de
/// [t], porque cambian con el idioma.
List<Achievement> computeAchievements(
  AchievementStats s, {
  AppStrings t = const AppStrings(),
}) {
  Achievement byCount(String id, IconData icon, int value, int goal) {
    return Achievement(
      id: id,
      title: t.achievementTitle(id),
      description: t.achievementDescription(id),
      icon: icon,
      unlocked: value >= goal,
      progress: goal <= 0 ? 0 : (value / goal).clamp(0.0, 1.0),
    );
  }

  final list = <Achievement>[
    byCount('cocinero', Icons.restaurant_menu, s.foods, 10),
    byCount('chef', Icons.local_dining, s.foods, 50),
    byCount('constante', Icons.event_note, s.loggedDays, 7),
    byCount('veterano', Icons.workspace_premium, s.loggedDays, 100),
    byCount('racha7', Icons.local_fire_department, s.streak, 7),
    byCount('racha30', Icons.whatshot, s.streak, 30),
    byCount('planificador', Icons.calendar_month, s.plannedWeeks, 4),
    byCount('fotografo', Icons.photo_camera, s.photos, 5),
    byCount('proteico', Icons.egg_alt, s.daysProteinMet, 30),
    byCount('semanaperfecta', Icons.verified, s.perfectWeeks, 1),
  ];

  list.sort((a, b) {
    if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
    return b.progress.compareTo(a.progress);
  });
  return list;
}
