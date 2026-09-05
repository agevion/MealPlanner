import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/meal_slot.dart';
import '../state/diary_provider.dart';
import '../state/gym_provider.dart';
import 'gym_profile_screen.dart';
import 'today_screen.dart';

/// Punto de entrada del Modo Gym. En estas primeras fases permite activar el
/// modo y elegir el objetivo. El resto (macros por plato, comidas del día,
/// registro y gamificación) se irá construyendo encima de esto.
class GymModeScreen extends StatelessWidget {
  const GymModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center),
            const SizedBox(width: 8),
            Text(t.gymModeTitle),
          ],
        ),
      ),
      body: Consumer<GymProvider>(
        builder: (context, gym, _) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.viewPaddingOf(context).bottom),
            children: [
              if (!gym.enabled) const _IntroCard(),
              Card(
                clipBehavior: Clip.antiAlias,
                child: SwitchListTile(
                  secondary: const Icon(Icons.fitness_center),
                  title: Text(t.enableGymMode),
                  subtitle: Text(t.enableGymModeSubtitle),
                  value: gym.enabled,
                  onChanged: gym.setEnabled,
                ),
              ),
              if (gym.enabled) ...[
                const SizedBox(height: 16),
                const _TodayCard(),
                const SizedBox(height: 20),
                Text(
                  t.yourGoal,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  t.yourGoalSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final goal in GymGoal.values)
                  _GoalCard(
                    goal: goal,
                    selected: gym.goal == goal,
                    onTap: () => gym.setGoal(goal),
                  ),
                if (gym.goal != null) _TargetsSection(gym: gym),
                _MealsConfig(gym: gym),
                const SizedBox(height: 20),
                const _StreakCard(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.fitness_center,
                size: 36, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.t.gymIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GymGoal goal;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(goal.icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t.gymGoal(goal),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(context.t.gymGoalDescription(goal),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sección de objetivos calculados. Muestra kcal + proteína del objetivo
/// actual, o invita a completar el perfil / poner cifras propias.
class _TargetsSection extends StatelessWidget {
  final GymProvider gym;
  const _TargetsSection({required this.gym});

  bool get _custom => gym.goal == GymGoal.custom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final kcal = gym.targetKcal;
    final protein = gym.targetProtein;
    final hasTargets = kcal != null && protein != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          t.yourTargets,
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (hasTargets)
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TargetMetric(
                          label: t.calories,
                          value: '$kcal',
                          unit: t.kcalPerDay),
                      const SizedBox(width: 12),
                      _TargetMetric(
                          label: t.protein,
                          value: '$protein',
                          unit: t.gramsPerDay),
                    ],
                  ),
                  if (gym.tdee != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      t.estimatedExpenditure(gym.tdee!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _custom
                          ? t.setYourOwnFigures
                          : t.completeProfileToCalculate,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _custom ? _editCustom(context) : _editProfile(context),
            icon: Icon(_custom ? Icons.tune : Icons.person_outline),
            label: Text(
              _custom
                  ? t.adjustFigures
                  : (gym.hasProfile ? t.editProfile : t.completeProfile),
            ),
          ),
        ),
      ],
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GymProfileScreen()),
    );
  }

  void _editCustom(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _CustomTargetsDialog(gym: gym),
    );
  }
}

class _TargetMetric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _TargetMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(unit, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTargetsDialog extends StatefulWidget {
  final GymProvider gym;
  const _CustomTargetsDialog({required this.gym});

  @override
  State<_CustomTargetsDialog> createState() => _CustomTargetsDialogState();
}

class _CustomTargetsDialogState extends State<_CustomTargetsDialog> {
  late final TextEditingController _kcal;
  late final TextEditingController _protein;

  @override
  void initState() {
    super.initState();
    final k = widget.gym.targetKcal;
    final p = widget.gym.targetProtein;
    _kcal = TextEditingController(text: k != null ? '$k' : '');
    _protein = TextEditingController(text: p != null ? '$p' : '');
  }

  @override
  void dispose() {
    _kcal.dispose();
    _protein.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.yourFigures),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _kcal,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: t.calories,
              suffixText: t.kcalPerDay,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _protein,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: t.protein,
              suffixText: t.gramsPerDay,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.gym.setCustomTargets(
              kcal: int.tryParse(_kcal.text),
              protein: int.tryParse(_protein.text),
            );
            Navigator.pop(context);
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}

/// Acceso al registro diario ("Hoy").
class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final onColor = theme.colorScheme.onPrimaryContainer;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        leading: Icon(Icons.today, color: onColor),
        title: Text(
          t.todaysLog,
          style: TextStyle(fontWeight: FontWeight.bold, color: onColor),
        ),
        subtitle: Text(
          t.todaysLogSubtitle,
          style: TextStyle(color: onColor),
        ),
        trailing: Icon(Icons.chevron_right, color: onColor),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TodayScreen()),
        ),
      ),
    );
  }
}

/// Configuración de las tomas del día (cuántas comidas planificar).
class _MealsConfig extends StatelessWidget {
  final GymProvider gym;
  const _MealsConfig({required this.gym});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          t.mealsPerDay,
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(t.mealsPerDaySubtitle, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final slot in MealSlot.values)
              FilterChip(
                label: Text(t.mealSlot(slot)),
                avatar: Icon(slot.icon, size: 18),
                selected: gym.mealSlots.contains(slot),
                onSelected: (_) => gym.toggleMealSlot(slot),
              ),
          ],
        ),
      ],
    );
  }
}

/// Racha de días cumpliendo el objetivo de proteína, leída del registro real.
class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final gym = context.watch<GymProvider>();
    final diary = context.watch<DiaryProvider>();
    final target = gym.targetProtein;
    final streak = diary.proteinStreak(target);
    final summary = diary.summary(7, target);

    return Card(
      color: streak > 0
          ? theme.colorScheme.tertiaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              streak > 0
                  ? Icons.local_fire_department
                  : Icons.local_fire_department_outlined,
              size: 36,
              color: streak > 0
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak > 0 ? t.daysInARow(streak) : t.noStreakYet,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: streak > 0
                          ? theme.colorScheme.onTertiaryContainer
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    target == null
                        ? t.setTargetToCount
                        : summary.days == 0
                            ? t.logToStartStreak
                            : t.last7Days(summary.metProtein, summary.days),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: streak > 0
                          ? theme.colorScheme.onTertiaryContainer
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
