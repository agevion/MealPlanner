import 'package:flutter/material.dart';

import '../data/home_widget_service.dart';
import '../l10n/l10n.dart';
import '../widgets/home_widget_faces.dart';

/// Los widgets de la pantalla de inicio, explicados y con vista previa.
///
/// La previsualización no es un dibujo de mentira: es exactamente el mismo
/// widget de Flutter que se exporta como imagen al widget de Android, con tus
/// datos de hoy. Lo que ves aquí es lo que vas a tener fuera.
class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final service = HomeWidgetService.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.widgetsTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 24 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          Text(
            HomeWidgetService.supported ? t.widgetsIntro : t.widgetOnlyAndroid,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _WidgetCard(
            kind: HomeWidgetKind.today,
            title: t.widgetTodayTitle,
            description: t.widgetTodayDescription,
            preview: TodayFace(
              data: service.todayData(),
              scheme: theme.colorScheme,
              t: t,
            ),
            service: service,
          ),
          _WidgetCard(
            kind: HomeWidgetKind.nextMeal,
            title: t.widgetNextTitle,
            description: t.widgetNextDescription,
            preview: NextMealFace(
              data: service.nextMealData(),
              scheme: theme.colorScheme,
              t: t,
            ),
            service: service,
          ),
          _WidgetCard(
            kind: HomeWidgetKind.shopping,
            title: t.widgetShoppingTitle,
            description: t.widgetShoppingDescription,
            preview: ShoppingFace(
              data: service.shoppingData(t),
              scheme: theme.colorScheme,
              t: t,
            ),
            service: service,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.widgetsRefreshNote,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  final HomeWidgetKind kind;
  final String title;
  final String description;
  final Widget preview;
  final HomeWidgetService service;

  const _WidgetCard({
    required this.kind,
    required this.title,
    required this.description,
    required this.preview,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 14),
            // La cara se dibuja siempre a su tamaño lógico; aquí se encoge para
            // que quepa en el ancho que haya.
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: preview,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: HomeWidgetService.supported
                    ? () => _add(context)
                    : null,
                icon: const Icon(Icons.add_to_home_screen),
                label: Text(t.addToHomeScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.t.widgetPinUnsupported;
    if (await service.pin(kind)) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
      ));
  }
}
