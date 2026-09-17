import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/achievements.dart';
import '../l10n/l10n.dart';
import '../state/diary_provider.dart';
import '../state/gym_provider.dart';
import '../state/meal_provider.dart';

/// Estadísticas: cómo te ha ido de verdad. Medias de kcal y proteína, días
/// cumplidos, racha, evolución del peso y tus platos más repetidos.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _range = 30;

  @override
  Widget build(BuildContext context) {
    final diary = context.watch<DiaryProvider>();
    final gym = context.watch<GymProvider>();
    final meals = context.watch<MealProvider>();
    final theme = Theme.of(context);
    final t = context.t;

    final target = gym.targetProtein;
    final summary = diary.summary(_range, target);
    final streak = diary.proteinStreak(target);
    final weights = diary.weightTrend();
    final usage = meals.foodUsageCounts();
    final top = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.statisticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: t.exportCsv,
            onPressed: () =>
                Share.share(diary.toCsv(t: t), subject: t.csvSubject),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final days in const [7, 30, 90])
                ButtonSegment(value: days, label: Text(t.daysRange(days))),
            ],
            selected: {_range},
            onSelectionChanged: (s) => setState(() => _range = s.first),
          ),
          const SizedBox(height: 16),
          if (summary.days == 0)
            const _Empty()
          else ...[
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '${summary.avgKcal}',
                    unit: t.kcal,
                    label: t.avgPerDay,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.egg_outlined,
                    value: '${summary.avgProtein}',
                    unit: t.gramShort,
                    label: t.avgProtein,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available_outlined,
                    value: '${summary.metProtein}/${summary.days}',
                    unit: '',
                    label: t.daysMeetingProtein,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.whatshot_outlined,
                    value: '$streak',
                    unit: t.daysUnit,
                    label: t.currentStreak,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _WeeklyReport(summary: summary, target: target),
          ],
          const SizedBox(height: 24),
          Text(
            t.yourWeight,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (weights.length < 2)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.weightNeedsTwoDays),
              ),
            )
          else ...[
            _WeightChart(points: weights),
            Builder(
              builder: (context) {
                final suggestion = gym.suggestKcalAdjustment(
                  diary.weightChangePerWeek(),
                  t: t,
                );
                if (suggestion == null) return const SizedBox.shrink();
                return Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_graph,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                suggestion.reason,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.tonal(
                            onPressed: () {
                              gym
                                ..setGoal(GymGoal.custom)
                                ..setCustomTargets(
                                  kcal: suggestion.newKcal,
                                  protein: gym.targetProtein,
                                );
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t.targetAdjusted(suggestion.newKcal),
                                    ),
                                  ),
                                );
                            },
                            child: Text(t.adjustToKcal(suggestion.newKcal)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          Text(
            t.achievementsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _Achievements(
            stats: AchievementStats(
              foods: meals.foods.length,
              streak: streak,
              loggedDays: diary.loggedDates.length,
              plannedWeeks: meals.weeks.where((w) => w.hasMeals).length,
              photos: meals.foods.where((f) => f.photoPath.isNotEmpty).length,
              daysProteinMet: diary.summary(365, target).metProtein,
              perfectWeeks: meals.completeWeeks(gym.activeMealSlots),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.whatYouEatMost,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (top.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.nothingPlannedYet),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final e in top.take(8))
                    ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${e.value}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(e.key),
                      subtitle: Text(t.timesInYourWeeks(e.value)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Rejilla de logros. Los conseguidos se ven a color; el resto, con su barrita
/// de progreso para que se vea lo que falta.
class _Achievements extends StatelessWidget {
  final AchievementStats stats;
  const _Achievements({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final all = computeAchievements(stats, t: t);
    final unlocked = all.where((a) => a.unlocked).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                t.achievementsUnlocked(unlocked, all.length),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final a in all)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: a.unlocked
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        a.icon,
                        size: 18,
                        color: a.unlocked
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: a.unlocked ? FontWeight.bold : null,
                              color: a.unlocked
                                  ? null
                                  : theme.colorScheme.outline,
                            ),
                          ),
                          Text(a.description, style: theme.textTheme.bodySmall),
                          if (!a.unlocked) ...[
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: a.progress,
                                minHeight: 4,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (a.unlocked)
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 20,
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

class _WeeklyReport extends StatelessWidget {
  final ({int days, int avgKcal, int avgProtein, int metProtein}) summary;
  final int? target;
  const _WeeklyReport({required this.summary, required this.target});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    // Un comentario en cristiano, sin jerga.
    final String verdict;
    if (target == null) {
      verdict = t.verdictNoTarget;
    } else if (summary.days == 0) {
      verdict = t.verdictNoData;
    } else {
      final ratio = summary.metProtein / summary.days;
      if (ratio >= 0.85) {
        verdict = t.verdictGreat;
      } else if (ratio >= 0.5) {
        verdict = t.verdictOk;
      } else {
        verdict = t.verdictLow;
      }
    }

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                verdict,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(unit, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Gráfica de peso pintada a mano: puntos reales + línea de tendencia
/// (media de 7 días). Sin librerías externas.
class _WeightChart extends StatelessWidget {
  final List<({DateTime date, double kg})> points;
  const _WeightChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = points.first.kg;
    final last = points.last.kg;
    final diff = last - first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${last.toStringAsFixed(1)} kg',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: diff >= 0
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(context.t.sevenDayAverage, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: CustomPaint(
                size: Size.infinite,
                painter: _WeightPainter(
                  values: points.map((p) => p.kg).toList(),
                  color: theme.colorScheme.primary,
                  grid: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color grid;
  const _WeightPainter({
    required this.values,
    required this.color,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 0.5 ? 0.5 : maxV - minV;

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset pointAt(int i) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minV) / span) * size.height;
      return Offset(x, y.clamp(0, size.height));
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }

    // Relleno suave bajo la línea.
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.12));

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    final dot = Paint()..color = color;
    canvas.drawCircle(pointAt(values.length - 1), 4, dot);
  }

  @override
  bool shouldRepaint(_WeightPainter old) =>
      old.values != values || old.color != color;
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.query_stats,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(context.t.noLogsInPeriod, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
