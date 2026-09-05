import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';

/// La ruleta de la cena: para cuando no sabes qué hacer y no quieres decidir.
/// Gira, se para en un plato y te deja ponerlo en el plan o registrarlo.
class RouletteScreen extends StatefulWidget {
  final MealSlot slot;
  const RouletteScreen({super.key, this.slot = MealSlot.dinner});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _rng = math.Random();

  List<Food> _pool = const [];
  Food? _winner;
  int _visibleIndex = 0;
  bool _onlyCookable = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(_tick);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mientras gira, va cambiando el nombre visible cada vez más despacio.
  void _tick() {
    if (_pool.isEmpty) return;
    final t = _controller.value;
    // Curva que empieza rápida y frena al final.
    final steps = (t * t * 40).floor();
    final index = steps % _pool.length;
    if (index != _visibleIndex) {
      setState(() => _visibleIndex = index);
      if (t < 0.9) HapticFeedback.selectionClick();
    }
    if (_controller.isCompleted) {
      HapticFeedback.heavyImpact();
      setState(() => _winner = _pool[_visibleIndex]);
    }
  }

  void _spin() {
    final provider = context.read<MealProvider>();
    var pool = provider.foods
        .where((f) => f.fitsSlot(widget.slot) && !f.isSnoozed)
        .toList();

    if (_onlyCookable) {
      final cookable = provider
          .cookableNow(context.read<PantryProvider>().items)
          .map((f) => f.name)
          .toSet();
      final filtered = pool.where((f) => cookable.contains(f.name)).toList();
      if (filtered.isNotEmpty) pool = filtered;
    }

    if (pool.isEmpty) {
      final t = context.t;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.noDishesFor(t.mealSlot(widget.slot)))),
      );
      return;
    }

    setState(() {
      _pool = pool..shuffle(_rng);
      _winner = null;
      _visibleIndex = 0;
    });
    _controller.forward(from: 0);
  }

  void _assignToday() {
    final provider = context.read<MealProvider>();
    final t = context.t;
    final winner = _winner;
    if (winner == null) return;
    final week = provider.activeWeek;
    final today = DateTime.now();
    // Si la semana activa es la de esta semana, usamos el día real; si no, el
    // lunes, que es lo menos sorprendente.
    final day = week.containsDate(today) ? today.weekday - 1 : 0;
    provider.setMeal(day, widget.slot, winner.name);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(t.assignedTo(
            winner.name, t.weekdays[day], t.mealSlot(widget.slot))),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final spinning = _controller.isAnimating;
    final label = _winner?.name ??
        (_pool.isEmpty ? t.whatsForDinner : _pool[_visibleIndex].name);

    return Scaffold(
      appBar: AppBar(title: Text(t.rouletteFor(t.mealSlot(widget.slot)))),
      // SafeArea abajo: sin esto el botón "Girar" se metía debajo de la barra
      // de gestos / botones del sistema.
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          children: [
            FilterChip(
              label: Text(t.onlyWithWhatIHave),
              selected: _onlyCookable,
              onSelected: (v) => setState(() => _onlyCookable = v),
            ),
            Expanded(
              child: Center(
                child: AnimatedScale(
                  scale: _winner != null ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 40),
                    decoration: BoxDecoration(
                      color: _winner != null
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _winner != null
                              ? Icons.celebration_outlined
                              : Icons.casino_outlined,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _winner != null
                                ? theme.colorScheme.onPrimaryContainer
                                : null,
                          ),
                        ),
                        if (_winner != null && _winner!.hasMacros) ...[
                          const SizedBox(height: 8),
                          Text(
                            t.macros(_winner!.kcal!, _winner!.protein!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_winner != null) ...[
              OutlinedButton.icon(
                onPressed: _assignToday,
                icon: const Icon(Icons.event_available_outlined),
                label: Text(t.putItInThePlan),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: spinning ? null : _spin,
                icon: const Icon(Icons.casino),
                label: Text(_winner == null ? t.spin : t.spinAgain),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
