import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/diary_provider.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';
import '../state/settings_provider.dart';
import 'add_food_screen.dart';
import 'ai_suggest_screen.dart';
import 'gym_mode_screen.dart';
import 'pantry_screen.dart';
import 'roulette_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'widgets_screen.dart';

/// Cajón de "Más": todo lo que no se usa a diario pero tiene que estar a mano.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final meals = context.watch<MealProvider>();
    final diary = context.watch<DiaryProvider>();
    final theme = Theme.of(context);
    final t = context.t;

    return Scaffold(
      appBar: AppBar(title: Text(t.moreTitle)),
      body: ListView(
        padding: EdgeInsets.only(
            bottom: 24 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          // La tarjeta de cifras es decoración: lo primero que sobra cuando se
          // pide una pantalla despejada.
          if (!context.clean)
            _Summary(
              foods: meals.foods.length,
              weeks: meals.weeks.length,
              streak: diary.proteinStreak(gym.targetProtein),
            ),
          _SectionHeader(t.sectionYourFood),
          _Tile(
            icon: Icons.add_circle_outline,
            title: t.addMealTitle,
            subtitle: t.addMealSubtitle,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddFoodScreen())),
          ),
          _Tile(
            icon: Icons.kitchen_outlined,
            title: t.myIngredientsTitle,
            subtitle: t.myIngredientsSubtitle,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PantryScreen())),
          ),
          _Tile(
            icon: Icons.auto_awesome,
            title: t.giveIdeasTitle,
            subtitle: t.giveIdeasSubtitle,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AiSuggestScreen())),
          ),
          _Tile(
            icon: Icons.casino_outlined,
            title: t.rouletteTitle,
            subtitle: t.rouletteSubtitle,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RouletteScreen())),
          ),
          _SectionHeader(t.sectionProgress),
          _Tile(
            icon: Icons.insights_outlined,
            title: t.statsTitle,
            subtitle: t.statsSubtitle,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          _Tile(
            icon: Icons.fitness_center,
            title: t.gymModeTitle,
            subtitle: gym.enabled
                ? t.gymModeActive(
                    gym.goal == null ? t.gymModeNoGoal : t.gymGoal(gym.goal!))
                : t.gymModeSubtitle,
            trailing: gym.enabled
                ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary)
                : null,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GymModeScreen())),
          ),
          _SectionHeader(t.sectionApp),
          _Tile(
            icon: Icons.widgets_outlined,
            title: t.widgetsTitle,
            subtitle: t.widgetsSubtitle,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WidgetsScreen())),
          ),
          _Tile(
            icon: Icons.settings_outlined,
            title: t.settingsTitle,
            subtitle: t.settingsSubtitle,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int foods;
  final int weeks;
  final int streak;
  const _Summary({
    required this.foods,
    required this.weeks,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(value: '$foods', label: t.statDishes),
              _Stat(value: '$weeks', label: t.statWeeks),
              _Stat(value: '$streak', label: t.statStreak),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
