import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../utils/theme.dart';
import '../../../models/product_model.dart';
import '../../../config/supabase_config.dart';

class ProductScanScreen extends StatefulWidget {
  const ProductScanScreen({super.key});

  @override
  State<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  late MobileScannerController controller;
  bool _isScanning = true;
  ScanResultModel? _scanResult;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_off : Icons.flash_on,
            ),
            onPressed: () {
              controller.toggleTorch();
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && _isScanning) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _processScanData(code);
                }
              }
            },
          ),
          
          // Scanning Overlay
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(true, true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(true, false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(false, true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(false, false),
                  ),
                ],
              ),
            ),
          ),
          
          // Scanning Indicator
          if (_isScanning)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Scanning for product code...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Manual Entry Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _showManualEntryDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Code Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: AppTheme.primaryColor, width: 4) : BorderSide.none,
          left: isLeft ? BorderSide(color: AppTheme.primaryColor, width: 4) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: AppTheme.primaryColor, width: 4) : BorderSide.none,
          right: !isLeft ? BorderSide(color: AppTheme.primaryColor, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  void _processScanData(String? code) {
    if (code == null || code.isEmpty) return;
    
    setState(() {
      _isScanning = false;
    });
    
    controller.stop();
    
    // Simulate product verification
    _verifyProduct(code);
  }

  void _verifyProduct(String code) {
    // Mock scan result
    final scanResult = ScanResultModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      company: 'ABC Fertilizers',
      product: 'NPK 10:26:26',
      batchNumber: code,
      authenticityScore: 85.0,
      issues: [],
      recommendation: 'Authentic',
      geoLocation: 'Pune, Maharashtra',
      timestamp: DateTime.now().toIso8601String(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _scanResult = scanResult;
    });

    _showResultDialog(scanResult);
  }

  void _showResultDialog(ScanResultModel result) {
    final isAuthentic = result.authenticityScore > 80;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isAuthentic ? Icons.check_circle : Icons.warning,
              color: isAuthentic ? AppTheme.successColor : AppTheme.errorColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(result.recommendation),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow('Company:', result.company),
              _buildResultRow('Product:', result.product),
              _buildResultRow('Batch:', result.batchNumber),
              _buildResultRow('Score:', '${result.authenticityScore}%'),
              const SizedBox(height: 16),
              if (result.issues.isNotEmpty) ...[
                Text(
                  'Issues Found:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                ),
                const SizedBox(height: 8),
                ...result.issues.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(issue)),
                        ],
                      ),
                    )),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Product verified as authentic'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
              controller.start();
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, result);
            },
            child: const Text('Use This Product'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Product Code'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Product/Batch Code',
            hintText: 'Enter code manually',
            prefixIcon: Icon(Icons.keyboard),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.pop(context);
                _processScanData(textController.text);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
