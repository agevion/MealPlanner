// Tests del registro diario (DiaryProvider): totales por día, aislamiento entre
// días y borrado de entradas. No usan SharedPreferences (load() no se llama;
// _save es no-op sin prefs).

import 'package:flutter_test/flutter_test.dart';

import 'package:mealplanner_flutter/models/logged_item.dart';
import 'package:mealplanner_flutter/state/diary_provider.dart';

void main() {
  group('DiaryProvider', () {
    final hoy = DateTime(2026, 6, 17);
    final ayer = DateTime(2026, 6, 16);

    test('suma kcal y proteína del día', () {
      final d = DiaryProvider();
      d.addEntry(hoy, const LoggedItem(name: 'Pollo', kcal: 500, protein: 40));
      d.addEntry(hoy, const LoggedItem(name: 'Yogur', kcal: 200, protein: 10));
      expect(d.kcalFor(hoy), 700);
      expect(d.proteinFor(hoy), 50);
      expect(d.entriesFor(hoy).length, 2);
    });

    test('los días están aislados', () {
      final d = DiaryProvider();
      d.addEntry(hoy, const LoggedItem(name: 'Pollo', kcal: 500, protein: 40));
      expect(d.kcalFor(ayer), 0);
      expect(d.entriesFor(ayer), isEmpty);
    });

    test('borrar una entrada actualiza los totales', () {
      final d = DiaryProvider();
      d.addEntry(hoy, const LoggedItem(name: 'Pollo', kcal: 500, protein: 40));
      d.addEntry(hoy, const LoggedItem(name: 'Yogur', kcal: 200, protein: 10));
      d.removeEntryAt(hoy, 0);
      expect(d.kcalFor(hoy), 200);
      expect(d.entriesFor(hoy).single.name, 'Yogur');
    });

    test('addEntries añade varias de golpe', () {
      final d = DiaryProvider();
      d.addEntries(hoy, const [
        LoggedItem(name: 'A', kcal: 100, protein: 5),
        LoggedItem(name: 'B', kcal: 150, protein: 8),
      ]);
      expect(d.entriesFor(hoy).length, 2);
      expect(d.kcalFor(hoy), 250);
    });

    test('dateKey ignora la hora', () {
      expect(dateKey(DateTime(2026, 6, 17, 9, 30)),
          dateKey(DateTime(2026, 6, 17, 23, 59)));
    });
  });
}
