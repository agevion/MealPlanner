import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/meal_slot.dart';
import 'kcal_ring.dart';

/// Las "caras" de los widgets de la pantalla de inicio.
///
/// Un widget de Android se dibuja con `RemoteViews`, que solo entiende un
/// puñado de vistas de sistema: nada de anillos de progreso, tipografías de la
/// app ni colores del tema elegido. En vez de pelearse con XML, aquí se dibuja
/// la tarjeta con Flutter y se exporta como PNG (`HomeWidget.renderFlutterWidget`);
/// el layout de Android es solo un `ImageView`. Así el widget sale exactamente
/// igual que la app, con su tema de color y su modo oscuro.
///
/// Regla importante para todo este fichero: **no se puede heredar nada del
/// árbol de widgets**. El render pasa por un `PipelineOwner` aparte, sin
/// `MaterialApp` encima, así que no hay `Theme`, ni `DefaultTextStyle`, ni
/// `IconTheme`, ni `Localizations`. Cada `Text` lleva su `style` completo con
/// color, cada `Icon` su `size` y su `color`, y los textos traducidos llegan
/// por parámetro en un [AppStrings].

/// Tamaños lógicos con los que se renderiza cada cara. La imagen se escala
/// después al hueco real del widget, así que lo que importa es la proporción.
const Size kTodayFaceSize = Size(340, 158);
const Size kNextMealFaceSize = Size(340, 110);
const Size kShoppingFaceSize = Size(176, 176);

/// Datos del widget "Hoy".
class TodayFaceData {
  final int kcal;
  final int protein;
  final int? targetKcal;
  final int? targetProtein;
  final int water;
  final int streak;

  const TodayFaceData({
    required this.kcal,
    required this.protein,
    required this.targetKcal,
    required this.targetProtein,
    required this.water,
    required this.streak,
  });
}

/// Datos del widget "Lo siguiente". [slot] nulo = no hay nada planificado.
class NextMealFaceData {
  final MealSlot? slot;
  final String? name;
  final int? kcal;
  final int? protein;
  final MealSlot? thenSlot;
  final String? thenName;

  const NextMealFaceData({
    this.slot,
    this.name,
    this.kcal,
    this.protein,
    this.thenSlot,
    this.thenName,
  });
}

/// Datos del widget de la compra.
class ShoppingFaceData {
  final int pending;
  final int total;

  /// Los primeros pendientes, ya recortados a los que caben.
  final List<String> preview;

  const ShoppingFaceData({
    required this.pending,
    required this.total,
    required this.preview,
  });
}

// ---------------------------------------------------------------------------
// Caras
// ---------------------------------------------------------------------------

class TodayFace extends StatelessWidget {
  final TodayFaceData data;
  final ColorScheme scheme;
  final AppStrings t;

  const TodayFace({
    super.key,
    required this.data,
    required this.scheme,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final hasTargets = data.targetKcal != null && data.targetProtein != null;
    return _FaceCard(
      size: kTodayFaceSize,
      scheme: scheme,
      header: _FaceHeader(
        icon: Icons.today_outlined,
        label: t.widgetTodayTitle,
        scheme: scheme,
        trailing: _headerExtra(),
      ),
      child: hasTargets ? _withTargets() : _withoutTargets(),
    );
  }

  /// A la derecha de la cabecera: la racha si la hay, y el agua del día. Son
  /// las dos cosas que se miran de reojo sin abrir nada.
  Widget? _headerExtra() {
    final bits = <Widget>[
      if (data.streak > 0)
        _IconValue(
          icon: Icons.local_fire_department,
          text: '${data.streak}',
          color: scheme.tertiary,
        ),
      if (data.water > 0)
        _IconValue(
          icon: Icons.local_drink_outlined,
          text: '${data.water}',
          color: scheme.primary,
        ),
    ];
    if (bits.isEmpty) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < bits.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          bits[i],
        ],
      ],
    );
  }

  Widget _withTargets() {
    final target = data.targetKcal!;
    final ratio = target > 0 ? data.kcal / target : 0.0;
    final over = data.kcal > target;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 86,
          height: 86,
          child: CustomPaint(
            painter: RingPainter(
              ratio: ratio,
              color: ratio > 1.1 ? scheme.error : scheme.primary,
              background: scheme.surfaceContainerHighest,
              stroke: 9,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${data.kcal}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '/$target',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    t.protein,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${data.protein} / ${data.targetProtein} ${t.gramShort}',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _MiniBar(
                ratio: data.targetProtein! > 0
                    ? data.protein / data.targetProtein!
                    : 0,
                color: scheme.tertiary,
                background: scheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 12),
              Text(
                over
                    ? t.kcalOver(data.kcal - target)
                    : t.kcalLeft(target - data.kcal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: over ? scheme.error : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sin Modo Gym no hay objetivos que enseñar: se queda en lo comido hoy.
  Widget _withoutTargets() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${data.kcal}',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: scheme.primary,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          t.macros(data.kcal, data.protein),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class NextMealFace extends StatelessWidget {
  final NextMealFaceData data;
  final ColorScheme scheme;
  final AppStrings t;

  const NextMealFace({
    super.key,
    required this.data,
    required this.scheme,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final slot = data.slot;
    return _FaceCard(
      size: kNextMealFaceSize,
      scheme: scheme,
      header: _FaceHeader(
        icon: slot?.icon ?? Icons.event_busy_outlined,
        label: slot == null ? t.widgetNextTitle : t.mealSlot(slot),
        scheme: scheme,
        trailing: data.thenSlot == null
            ? null
            : _IconValue(
                icon: data.thenSlot!.icon,
                text: data.thenName ?? '',
                color: scheme.onSurfaceVariant,
                maxWidth: 120,
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name ?? t.widgetNoPlan,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: data.name == null
                  ? scheme.onSurfaceVariant
                  : scheme.onSurface,
              height: 1.1,
            ),
          ),
          if (data.kcal != null && data.protein != null) ...[
            const SizedBox(height: 3),
            Text(
              t.macros(data.kcal!, data.protein!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class ShoppingFace extends StatelessWidget {
  final ShoppingFaceData data;
  final ColorScheme scheme;
  final AppStrings t;

  const ShoppingFace({
    super.key,
    required this.data,
    required this.scheme,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final done = data.pending == 0 && data.total > 0;
    return _FaceCard(
      size: kShoppingFaceSize,
      scheme: scheme,
      header: _FaceHeader(
        icon: Icons.shopping_cart_outlined,
        label: t.tabShopping,
        scheme: scheme,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            done || data.total == 0
                ? (done ? t.widgetAllBought : t.widgetNoPlan)
                : t.widgetItemsLeft(data.pending),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: done ? scheme.primary : scheme.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in data.preview)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 5, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Piezas comunes
// ---------------------------------------------------------------------------

/// El marco de todas las caras: fondo redondeado con el color del tema.
///
/// El borde lo pinta la propia imagen porque el `ImageView` de Android es
/// rectangular: si el fondo lo pusiera el layout nativo no seguiría el tema de
/// color elegido en la app.
class _FaceCard extends StatelessWidget {
  final Size size;
  final ColorScheme scheme;
  final Widget header;
  final Widget child;

  const _FaceCard({
    required this.size,
    required this.scheme,
    required this.header,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 6),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final Widget? trailing;

  const _FaceHeader({
    required this.icon,
    required this.label,
    required this.scheme,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: scheme.primary),
        const SizedBox(width: 5),
        // El título se lleva el hueco que sobra y se recorta si hace falta; lo
        // de la derecha ya viene con su ancho máximo puesto.
        Expanded(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: scheme.primary,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _IconValue extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final double? maxWidth;

  const _IconValue({
    required this.icon,
    required this.text,
    required this.color,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        if (maxWidth == null)
          label
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: label,
          ),
      ],
    );
  }
}

/// Barra de progreso a mano: `LinearProgressIndicator` es un widget animado y
/// lee del `Theme`, y aquí solo hace falta un rectángulo pintado una vez.
class _MiniBar extends StatelessWidget {
  final double ratio;
  final Color color;
  final Color background;

  const _MiniBar({
    required this.ratio,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      width: double.infinity,
      child: CustomPaint(
        painter: _MiniBarPainter(
          ratio: ratio,
          color: color,
          background: background,
        ),
      ),
    );
  }
}

class _MiniBarPainter extends CustomPainter {
  final double ratio;
  final Color color;
  final Color background;

  const _MiniBarPainter({
    required this.ratio,
    required this.color,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = background,
    );
    final width = size.width * ratio.clamp(0.0, 1.0);
    if (width <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width.clamp(size.height, size.width), size.height),
        radius,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_MiniBarPainter old) =>
      old.ratio != ratio || old.color != color || old.background != background;
}
