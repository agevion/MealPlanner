import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/openfoodfacts_service.dart';
import '../l10n/l10n.dart';
import '../models/food.dart';
import '../models/meal_slot.dart';
import '../widgets/portion_picker_dialog.dart';
import 'add_food_screen.dart';

/// Escáner de código de barras. Al leer un producto consulta OpenFoodFacts y
/// abre el formulario de comida prerrellenado. Pensado para productos envasados
/// (preentrenos, bebidas, comidas preparadas…).
class ScanFoodScreen extends StatefulWidget {
  /// Si es true, en vez de abrir el formulario de comida nueva, devuelve el
  /// producto escaneado (`ScannedProduct`) al cerrar. Se usa para añadir
  /// ingredientes a un plato compuesto.
  final bool asComponent;

  const ScanFoodScreen({super.key, this.asComponent = false});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    // Principalmente códigos de barras de producto (EAN/UPC/Code128/ITF) y, como
    // extra, también QR por si algún producto lo trae.
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.itf14,
      BarcodeFormat.qrCode,
    ],
  );
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code.isEmpty) return;

    final t = context.t;
    setState(() => _busy = true);
    await _controller.stop();

    final product = await OpenFoodFactsService.fetchByBarcode(code, t: t);
    if (!mounted) return;

    if (product == null) {
      await _showMessage(t.productNotFoundTitle, t.productNotFoundBody(code));
      _resume();
      return;
    }

    if (widget.asComponent) {
      Navigator.pop(context, product);
      return;
    }

    // Antes de crear el plato, elegimos la porción real (gramos o raciones) para
    // que las macros no sean las de "100 g en crudo" sin más.
    final component = await PortionPickerDialog.show(context, product);
    if (!mounted) return;
    if (component == null) {
      _resume();
      return;
    }

    final food = Food(
      name: component.name,
      ingredients: product.food.name,
      slots: const {MealSlot.snack},
      kcal: component.totalKcal,
      protein: component.totalProtein,
    );

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(
          prefill: food,
          prefillNote: t.scannedProductNote(t.productBasis(product.basis)),
        ),
      ),
    );
  }

  Future<void> _resume() async {
    if (!mounted) return;
    setState(() => _busy = false);
    await _controller.start();
  }

  Future<void> _showMessage(String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.keepScanning),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.asComponent ? t.scanIngredientTitle : t.scanProductTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined),
            tooltip: t.switchCamera,
            onPressed: () => _controller.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: t.flash,
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Marco guía
          Container(
            width: 240,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                t.aimAtBarcode,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    t.searchingProduct,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
