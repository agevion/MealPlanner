import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda los ajustes del asistente de IA (Gemini): la clave de API que pone
/// cada usuario y el nombre del modelo a usar. Va aparte del resto de ajustes
/// para no mezclar la nutrición con la apariencia. La clave se guarda solo en el
/// dispositivo (SharedPreferences), no se comparte con nadie más que Google.
class AiProvider extends ChangeNotifier {
  static const _kApiKey = 'ai_gemini_api_key';
  static const _kModel = 'ai_gemini_model';

  /// Modelo por defecto: rápido, barato y con visión (analiza fotos).
  static const String defaultModel = 'gemini-2.5-flash';

  SharedPreferences? _prefs;

  String _apiKey = '';
  String _model = defaultModel;

  String get apiKey => _apiKey;
  String get model => _model.isEmpty ? defaultModel : _model;

  /// True cuando hay clave: solo entonces se ofrece la estimación con IA.
  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs!.getString(_kApiKey) ?? '';
    _model = _prefs!.getString(_kModel) ?? defaultModel;
    notifyListeners();
  }

  void setApiKey(String value) {
    final v = value.trim();
    if (v == _apiKey) return;
    _apiKey = v;
    if (v.isEmpty) {
      _prefs?.remove(_kApiKey);
    } else {
      _prefs?.setString(_kApiKey, v);
    }
    notifyListeners();
  }

  void setModel(String value) {
    final v = value.trim().isEmpty ? defaultModel : value.trim();
    if (v == _model) return;
    _model = v;
    _prefs?.setString(_kModel, v);
    notifyListeners();
  }
}
