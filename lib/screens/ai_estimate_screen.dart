import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/gemini_service.dart';
import '../l10n/l10n.dart';
import '../models/ai_estimate.dart';
import '../state/ai_provider.dart';
import 'settings_screen.dart';

/// Estima las macros de una comida con IA (Gemini) a partir de una descripción
/// escrita y/o una foto del plato. Es el camino "super cómodo": no hace falta
/// pesar ni buscar nada, describes lo que has comido y la IA propone kcal y
/// proteína aproximadas que luego confirmas o ajustas.
///
/// Devuelve un [AiEstimate] al cerrarse (o null si se cancela).
class AiEstimateScreen extends StatefulWidget {
  /// Texto inicial (p. ej. el nombre del plato que ya escribió el usuario).
  final String initialText;
  const AiEstimateScreen({super.key, this.initialText = ''});

  @override
  State<AiEstimateScreen> createState() => _AiEstimateScreenState();
}

class _AiEstimateScreenState extends State<AiEstimateScreen> {
  late final TextEditingController _descCtrl;
  Uint8List? _imageBytes;
  String _imageMime = 'image/jpeg';

  bool _loading = false;
  String? _error;
  AiEstimate? _result;

  // Controladores para poder ajustar el resultado antes de usarlo.
  final _nameCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _nameCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageMime = file.mimeType ?? 'image/jpeg';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.t.couldNotOpenImage);
      }
    }
  }

  Future<void> _estimate(AiProvider ai) async {
    final t = context.t;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final estimate = await GeminiService.estimate(
        apiKey: ai.apiKey,
        model: ai.model,
        description: _descCtrl.text,
        imageBytes: _imageBytes,
        imageMimeType: _imageMime,
        t: t,
      );
      if (!mounted) return;
      setState(() {
        _result = estimate;
        _nameCtrl.text = estimate.name.isEmpty
            ? _descCtrl.text.trim()
            : estimate.name;
        _kcalCtrl.text = '${estimate.kcal}';
        _proteinCtrl.text = '${estimate.protein}';
      });
    } on GeminiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _use() {
    final result = AiEstimate(
      name: _nameCtrl.text.trim(),
      kcal: int.tryParse(_kcalCtrl.text) ?? 0,
      protein: int.tryParse(_proteinCtrl.text) ?? 0,
      note: _result?.note ?? '',
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final theme = Theme.of(context);
    final t = context.t;

    return Scaffold(
      appBar: AppBar(title: Text(t.aiEstimateTitle)),
      body: !ai.isConfigured
          ? const _NotConfigured()
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 24 + MediaQuery.viewPaddingOf(context).bottom),
              children: [
                Text(t.aiEstimateIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: _descCtrl,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.descriptionLabel,
                    hintText: t.descriptionHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                ),
                const SizedBox(height: 12),
                _ImageSection(
                  imageBytes: _imageBytes,
                  onCamera: () => _pickImage(ImageSource.camera),
                  onGallery: () => _pickImage(ImageSource.gallery),
                  onRemove: () => setState(() => _imageBytes = null),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : () => _estimate(ai),
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: Text(_loading ? t.estimating : t.estimateMacros),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(text: _error!),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  Text(t.resultAdjustIt, style: theme.textTheme.titleSmall),
                  if (_result!.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_result!.note,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.outline)),
                  ],
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: t.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _kcalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.calories,
                            suffixText: t.kcal,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _proteinCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.protein,
                            suffixText: t.gramShort,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _use,
                    icon: const Icon(Icons.check),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    label: Text(t.useThisData),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  const _ImageSection({
    required this.imageBytes,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (imageBytes != null) {
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(imageBytes!,
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(t.photoAdded,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: t.removePhoto,
            onPressed: onRemove,
          ),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onCamera,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(t.photo),
        ),
        OutlinedButton.icon(
          onPressed: onGallery,
          icon: const Icon(Icons.image_outlined),
          label: Text(t.gallery),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

/// Se muestra cuando aún no hay clave de API configurada.
class _NotConfigured extends StatelessWidget {
  const _NotConfigured();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.key_off_outlined,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(t.missingGeminiKey, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              t.missingGeminiKeyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined),
              label: Text(t.goToSettings),
            ),
          ],
        ),
      ),
    );
  }
}
