/// Utilidades de texto compartidas. Se usan para cruzar lo que el usuario
/// escribe a mano (ingredientes de un plato, ítems de la compra) con los
/// nombres de la despensa, que casi nunca coinciden letra por letra:
/// "Pechuga de pollo" en la despensa vs "pollo" en el texto del plato.
library;

/// Caché de normalizaciones. Estas funciones se llaman muchísimo (la lista de
/// la compra cruza cada ingrediente contra toda la despensa en cada
/// reconstrucción), y siempre sobre el mismo puñado de textos. Sin caché se
/// nota en los fotogramas.
final Map<String, String> _normalizeCache = {};
final Map<String, Set<String>> _keywordsCache = {};

/// Si la caché se descontrola (nombres generados, pegar textos largos…) se
/// vacía en vez de crecer sin fin.
const int _kMaxCacheEntries = 2000;

/// Quita acentos y pasa a minúsculas, sin tocar la ñ (en español distingue
/// palabras: "año" no es "ano").
String normalizeText(String input) {
  final cached = _normalizeCache[input];
  if (cached != null) return cached;

  const from = 'áàäâãéèëêíìïîóòöôõúùüûçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÇ';
  const to = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  final buffer = StringBuffer();
  for (final rune in input.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final i = from.indexOf(char);
    buffer.write(i >= 0 ? to[i] : char);
  }
  final result = buffer.toString();

  if (_normalizeCache.length >= _kMaxCacheEntries) _normalizeCache.clear();
  _normalizeCache[input] = result;
  return result;
}

/// Palabras que no aportan nada al comparar ingredientes ("de", "en aceite"…).
const Set<String> _kStopWords = {
  'de', 'del', 'la', 'el', 'los', 'las', 'al', 'a', 'con', 'sin', 'y', 'en',
  'un', 'una', 'unos', 'unas', 'por', 'para',
};

/// Palabras significativas de un texto, normalizadas y sin relleno.
/// "Atún en lata (al natural)" → {atun, lata, natural}
Set<String> keywordsOf(String input) {
  final cached = _keywordsCache[input];
  if (cached != null) return cached;

  final cleaned = normalizeText(input).replaceAll(_kNonWord, ' ');
  final result = cleaned
      .split(' ')
      .map((w) => w.trim())
      .where((w) => w.length > 2 && !_kStopWords.contains(w))
      .toSet();

  if (_keywordsCache.length >= _kMaxCacheEntries) _keywordsCache.clear();
  _keywordsCache[input] = result;
  return result;
}

/// Compilada una sola vez: crearla en cada llamada era gasto puro.
final RegExp _kNonWord = RegExp(r'[^a-z0-9ñ ]');

/// ¿Se refieren [a] y [b] al mismo ingrediente? Es una comparación blanda:
/// coinciden si uno contiene al otro tras normalizar, o si comparten alguna
/// palabra significativa. Pensada para sesgar el azar y agrupar la compra, no
/// para decisiones críticas.
bool ingredientsMatch(String a, String b) {
  final na = normalizeText(a);
  final nb = normalizeText(b);
  if (na.isEmpty || nb.isEmpty) return false;
  if (na == nb) return true;
  if (na.contains(nb) || nb.contains(na)) return true;
  final ka = keywordsOf(a);
  final kb = keywordsOf(b);
  return ka.intersection(kb).isNotEmpty;
}

/// Separa el texto libre de ingredientes de un plato ("tomate, pasta, queso")
/// en sus partes, ya recortadas y sin vacíos.
List<String> splitIngredients(String text) => text
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

/// Primera letra en mayúscula, resto en minúscula. Para mostrar nombres
/// agrupados de forma consistente en la lista de la compra.
String capitalize(String input) {
  final t = input.trim();
  if (t.isEmpty) return t;
  return t[0].toUpperCase() + t.substring(1).toLowerCase();
}
