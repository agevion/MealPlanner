import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/gym_provider.dart';

/// Mini-onboarding del Modo Gym: 4 datos (peso, altura, edad/sexo, actividad)
/// con los que se calculan los objetivos de kcal y proteína. Muestra una vista
/// previa en vivo mientras se rellena.
class GymProfileScreen extends StatefulWidget {
  const GymProfileScreen({super.key});

  @override
  State<GymProfileScreen> createState() => _GymProfileScreenState();
}

class _GymProfileScreenState extends State<GymProfileScreen> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _ageCtrl;
  late Sex _sex;
  late ActivityLevel _activity;

  @override
  void initState() {
    super.initState();
    final gym = context.read<GymProvider>();
    _weightCtrl = TextEditingController(
        text: gym.weightKg > 0 ? _trim(gym.weightKg) : '');
    _heightCtrl = TextEditingController(
        text: gym.heightCm > 0 ? _trim(gym.heightCm) : '');
    _ageCtrl = TextEditingController(text: gym.age > 0 ? '${gym.age}' : '');
    _sex = gym.sex;
    _activity = gym.activity;
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? '${v.round()}' : '$v';

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  double? get _weight => double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
  double? get _height => double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
  int? get _age => int.tryParse(_ageCtrl.text);

  bool get _isValid {
    final w = _weight, h = _height, a = _age;
    return w != null && w >= 30 && w <= 300 &&
        h != null && h >= 100 && h <= 250 &&
        a != null && a >= 12 && a <= 100;
  }

  void _save() {
    final t = context.t;
    if (!_isValid) {
      _snack(t.checkProfileData);
      return;
    }
    context.read<GymProvider>().saveProfile(
          weightKg: _weight!,
          heightCm: _height!,
          age: _age!,
          sex: _sex,
          activity: _activity,
        );
    _snack(t.profileSaved);
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<GymProvider>().goal ?? GymGoal.maintenance;
    final t = context.t;

    return Scaffold(
      appBar: AppBar(title: Text(t.yourProfile)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          Text(
            t.profileIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: _weightCtrl,
                  label: t.weight,
                  suffix: 'kg',
                  icon: Icons.monitor_weight_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: _heightCtrl,
                  label: t.height,
                  suffix: 'cm',
                  icon: Icons.height,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _NumberField(
            controller: _ageCtrl,
            label: t.age,
            suffix: t.years,
            icon: Icons.cake_outlined,
            integer: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text(t.sexTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Sex>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: Sex.male, label: Text(t.sex(Sex.male))),
                ButtonSegment(
                    value: Sex.female, label: Text(t.sex(Sex.female))),
              ],
              selected: {_sex},
              onSelectionChanged: (s) => setState(() => _sex = s.first),
            ),
          ),
          const SizedBox(height: 6),
          Text(t.sexNote, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          Text(t.activityLevel,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final level in ActivityLevel.values)
            _ActivityTile(
              level: level,
              selected: _activity == level,
              onTap: () => setState(() => _activity = level),
            ),
          const SizedBox(height: 20),
          _PreviewCard(
            goal: goal,
            weight: _weight,
            height: _height,
            age: _age,
            sex: _sex,
            activity: _activity,
            valid: _isValid,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            label: Text(t.saveProfile),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final bool integer;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.onChanged,
    this.integer = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType:
          TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityLevel level;
  final bool selected;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        title: Text(context.t.activity(level)),
        subtitle: Text(context.t.activityDescription(level)),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color:
              selected ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final GymGoal goal;
  final double? weight;
  final double? height;
  final int? age;
  final Sex sex;
  final ActivityLevel activity;
  final bool valid;

  const _PreviewCard({
    required this.goal,
    required this.weight,
    required this.height,
    required this.age,
    required this.sex,
    required this.activity,
    required this.valid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    if (!valid) {
      return Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.calculate_outlined,
                  color: theme.colorScheme.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.fillToSeeTargets,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final tdee = gymTdee(weight!, height!, age!, sex, activity);
    final kcal = goal == GymGoal.custom ? tdee : gymTargetKcal(tdee, goal);
    final protein = gymTargetProtein(weight!, goal);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.targetsForGoal(t.gymGoal(goal)),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                    label: t.calories, value: '$kcal', unit: t.kcalPerDay),
                const SizedBox(width: 12),
                _Metric(
                    label: t.protein,
                    value: '$protein',
                    unit: t.gramsPerDay),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${t.estimatedExpenditure(tdee)}. '
              '${goal == GymGoal.custom ? t.customFiguresNote : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _Metric({required this.label, required this.value, required this.unit});

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
