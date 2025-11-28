import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
// Import halaman hasil dan service
// import 'package:eatwise2/page/hasil.dart';
// import 'package:eatwise2/services/product_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedCode;

  // Warna tema
  static const Color _primaryColor = Color(0xFF388E3C);
  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Scan Produk',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Toggle flash
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.amber);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          // Switch camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
                    _handleBarcodeDetected(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),

          // Overlay dengan frame scan
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),

          // Instruksi
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Arahkan kamera ke barcode produk',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Tombol Pilih dari Galeri
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  // Tombol Galeri
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      'Pilih dari Galeri',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol Input Manual
                  OutlinedButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.keyboard),
                    label: Text(
                      'Input Barcode Manual',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // HANDLE BARCODE DETECTED
  // ============================================
  void _handleBarcodeDetected(String barcode) async {
    setState(() {
      _isProcessing = true;
      _lastScannedCode = barcode;
    });

    // Vibrate atau sound feedback (opsional)
    // HapticFeedback.mediumImpact();

    // Stop scanner sementara
    await cameraController.stop();

    // TODO: Fetch product dari API
    await _fetchProductAndNavigate(barcode);

    setState(() {
      _isProcessing = false;
    });
  }

  // ============================================
  // FETCH PRODUCT & NAVIGATE
  // ============================================
  Future<void> _fetchProductAndNavigate(String barcode) async {
    try {
      // TODO: Uncomment ini setelah ProductService dibuat
      // final product = await ProductService.getProductByBarcode(barcode);
      
      // Sementara pakai delay untuk simulasi
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulasi data (hapus ini nanti)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Barcode Detected!', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text('Barcode: $barcode\n\nIntegrasi dengan API akan dilakukan selanjutnya.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Kembali ke home
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      // NANTI: Navigate ke halaman hasil
      // if (product != null) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ReportScreen(productId: product.id),
      //     ),
      //   );
      // } else {
      //   _showProductNotFoundDialog(barcode);
      // }
      
    } catch (e) {
      _showErrorDialog('Gagal memuat data produk: $e');
    }
  }

  // ============================================
  // PICK IMAGE FROM GALLERY
  // ============================================
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isProcessing = true);

      // TODO: Implementasi OCR atau image recognition
      // Untuk sementara, tampilkan dialog bahwa fitur masih dalam pengembangan
      
      setState(() => _isProcessing = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Fitur Image Recognition', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: const Text('Fitur scan dari gambar masih dalam pengembangan.\n\nGunakan scan barcode atau input manual untuk sementara.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // ============================================
  // MANUAL INPUT DIALOG
  // ============================================
  void _showManualInputDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Input Barcode Manual', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nomor Barcode',
            hintText: 'Contoh: 8992761111111',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _handleBarcodeDetected(controller.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SHOW ERROR DIALOG
  // ============================================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cameraController.start(); // Restart scanner
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SHOW PRODUCT NOT FOUND DIALOG
  // ============================================
  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Produk Tidak Ditemukan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Barcode "$barcode" tidak ditemukan di database.\n\nAnda bisa menambahkan produk ini secara manual.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
            },
            child: const Text('Scan Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate ke form input produk manual
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Input Manual'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CUSTOM PAINTER: SCANNER OVERLAY
// ============================================
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
        ..fillType = PathFillType.evenOdd,
      backgroundPaint,
    );

    // Frame corners
    final Paint framePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double cornerLength = 40;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top)
        ..lineTo(left + cornerLength, top),
      framePaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top)
        ..lineTo(left + scanAreaSize, top)
        ..lineTo(left + scanAreaSize, top + cornerLength),
      framePaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerLength)
        ..lineTo(left, top + scanAreaSize)
        ..lineTo(left + cornerLength, top + scanAreaSize),
      framePaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize, top + scanAreaSize)
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
