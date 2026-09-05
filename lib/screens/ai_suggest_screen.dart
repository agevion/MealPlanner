import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/gemini_service.dart';
import '../l10n/l10n.dart';
import '../models/ai_estimate.dart';
import '../state/ai_provider.dart';
import '../state/meal_provider.dart';
import '../state/pantry_provider.dart';

/// "Dame ideas": la IA propone platos nuevos según lo que le pidas y, si
/// quieres, usando lo que tienes en la despensa. Cada propuesta se revisa y se
/// añade al catálogo con un toque.
class AiSuggestScreen extends StatefulWidget {
  const AiSuggestScreen({super.key});

  @override
  State<AiSuggestScreen> createState() => _AiSuggestScreenState();
}

class _AiSuggestScreenState extends State<AiSuggestScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _usePantry = true;
  bool _loading = false;
  String? _error;
  List<AiSuggestion> _results = const [];
  final Set<String> _added = {};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final ai = context.read<AiProvider>();
    final pantry = context.read<PantryProvider>();
    final t = context.t;
    final request = _ctrl.text.trim();
    if (request.isEmpty) {
      setState(() => _error = t.writeWhatYouWant);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = const [];
    });

    try {
      // Si pide usar la despensa, mandamos lo que tiene en stock; si no tiene
      // nada marcado, mandamos toda la despensa como referencia.
      final available = _usePantry
          ? (pantry.inStock.isNotEmpty ? pantry.inStock : pantry.items)
              .map((i) => i.name)
              .toList()
          : const <String>[];

      final results = await GeminiService.suggestMeals(
        apiKey: ai.apiKey,
        model: ai.model,
        request: request,
        availableIngredients: available,
        t: t,
      );
      if (!mounted) return;
      setState(() => _results = results);
    } on GeminiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _add(AiSuggestion suggestion) {
    context.read<MealProvider>().addOrReplaceFood(suggestion.toFood());
    setState(() => _added.add(suggestion.name));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.t.addedToCatalog(suggestion.name)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final theme = Theme.of(context);
    final t = context.t;

    if (!ai.isConfigured) return const _NotConfigured();

    return Scaffold(
      appBar: AppBar(title: Text(t.giveIdeasTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          TextField(
            controller: _ctrl,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: t.whatDoYouFancy,
              hintText: t.whatDoYouFancyHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in t.ideaPresets)
                ActionChip(
                  label: Text(p),
                  onPressed: () => setState(() => _ctrl.text = p),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _usePantry,
            onChanged: (v) => setState(() => _usePantry = v),
            title: Text(t.usePantry),
            subtitle: Text(t.usePantrySubtitle),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _generate,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_loading ? t.thinking : t.proposeDishes),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                            color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              t.proposals,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(t.proposalsDisclaimer, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            for (final s in _results)
              _SuggestionCard(
                suggestion: s,
                added: _added.contains(s.name),
                onAdd: () => _add(s),
              ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final AiSuggestion suggestion;
  final bool added;
  final VoidCallback onAdd;

  const _SuggestionCard({
    required this.suggestion,
    required this.added,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: added ? null : onAdd,
                  icon: Icon(added ? Icons.check : Icons.add, size: 18),
                  label: Text(added ? t.added : t.add),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(suggestion.ingredients, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (suggestion.kcal > 0)
                  Chip(
                    avatar: const Icon(Icons.local_fire_department_outlined,
                        size: 16),
                    label: Text(t.kcalValue(suggestion.kcal)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (suggestion.protein > 0)
                  Chip(
                    avatar: const Icon(Icons.egg_outlined, size: 16),
                    label: Text('${suggestion.protein} ${t.gramShort}'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (suggestion.prepMinutes != null)
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text('${suggestion.prepMinutes} ${t.minutesShort}'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                for (final tag in suggestion.tags)
                  Chip(
                    label: Text(t.foodTag(tag)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            if (suggestion.recipe.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                suggestion.recipe,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotConfigured extends StatelessWidget {
  const _NotConfigured();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.giveIdeasTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome,
                  size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(t.aiSuggestNotConfigured, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
