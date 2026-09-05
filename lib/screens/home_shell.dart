import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/home_widget_service.dart';
import '../l10n/l10n.dart';
import '../state/gym_provider.dart';
import '../state/settings_provider.dart';
import 'food_list_screen.dart';
import 'more_screen.dart';
import 'planner_screen.dart';
import 'shopping_list_screen.dart';
import 'today_screen.dart';

/// Pestaña que hay que abrir por una petición de fuera (tocar un widget de la
/// pantalla de inicio). `main` la deja puesta y `HomeShell` la recoge, tanto si
/// la app arranca de cero como si ya estaba abierta.
final ValueNotifier<HomeTab?> homeTabRequest = ValueNotifier(null);

/// Esqueleto de la app: barra de navegación inferior fija con las cuatro cosas
/// que se usan a diario más un cajón de "Más".
///
/// Antes todo colgaba de una pantalla de inicio con tarjetas y cada cosa era un
/// `Navigator.push`: para pasar de la lista de la compra al registro había que
/// volver atrás dos veces. Con la barra, todo está a un toque.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int? _index;

  /// Pestañas que el usuario ya ha abierto. Las demás no se construyen.
  ///
  /// Un `IndexedStack` mantiene vivos a todos sus hijos, así que las cinco
  /// pantallas se reconstruían con cada cambio de cualquier provider aunque no
  /// se vieran — y la lista de la compra, que recalcula agrupaciones, lo hacía
  /// en cada toque del planificador. Construyéndolas solo al visitarlas se
  /// mantiene el estado de las visitadas sin pagar por las que no.
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    // Si la app se ha abierto desde un widget, la pestaña ya está pedida antes
    // de que exista esta pantalla: aquí basta con dejarla puesta.
    _index = _takeTabRequest()?.index;
    homeTabRequest.addListener(_onTabRequested);
  }

  @override
  void dispose() {
    homeTabRequest.removeListener(_onTabRequested);
    super.dispose();
  }

  /// Recoge la pestaña pedida y la consume: si vuelves a tocar el mismo widget,
  /// el `ValueNotifier` tiene que ver un cambio de valor para avisar otra vez.
  HomeTab? _takeTabRequest() {
    final tab = homeTabRequest.value;
    if (tab != null) homeTabRequest.value = null;
    return tab;
  }

  void _onTabRequested() {
    final tab = _takeTabRequest();
    if (tab == null) return;
    setState(() => _index = tab.index);
  }

  static const _screens = [
    TodayScreen(),
    PlannerScreen(),
    FoodListScreen(),
    ShoppingListScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final gymEnabled = context.watch<GymProvider>().enabled;
    final t = context.t;

    // La primera pestaña depende de para qué usas la app: si llevas el Modo Gym
    // sueles entrar a registrar; si no, a mirar la semana.
    _index ??= settings.startTab ?? (gymEnabled ? 0 : 1);
    final index = _index!.clamp(0, _screens.length - 1);
    _visited.add(index);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          for (var i = 0; i < _screens.length; i++)
            _visited.contains(i) ? _screens[i] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        // Con la interfaz limpia solo se lee el nombre de la pestaña en la que
        // estás: los iconos ya se reconocen y la barra pesa menos.
        labelBehavior: settings.cleanMode
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: t.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: t.tabWeek,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu),
            label: t.tabMeals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: t.tabShopping,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: t.tabMore,
          ),
        ],
      ),
    );
  }
}
