import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../core/context/app_context.dart';
import '../utils/lnurl_utils.dart';
import '../utils/ln_address.dart';
import '../utils/api_utils.dart' as api_utils;
import '../widgets/async_action_button.dart';
import 'pay_invoice_screen.dart';
import 'ln_amount_screen.dart';

class DetectionScreen extends StatefulWidget {
  final Either<LightningAddress, String>
  detectedData; // Left = lightning address, Right = invoice

  const DetectionScreen({
    super.key,
    required this.detectedData,
    required this.appContext,
  });

  final AppContext appContext;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  Widget _buildDetectionIcon() => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: Colors.deepPurple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(40),
    ),
    child: widget.detectedData.fold(
      (lightningAddress) =>
          const Icon(Icons.alternate_email, size: 40, color: Colors.deepPurple),
      (invoice) => const Icon(Icons.bolt, size: 40, color: Colors.deepPurple),
    ),
  );

  String get _detectionTitle => widget.detectedData.fold(
    (lightningAddress) => 'Detected Lightning Address',
    (invoice) => 'Detected Invoice',
  );

  Future<Either<String, Unit>> _handleContinue() async {
    return widget.detectedData.fold(
      (lightningAddress) => _processLightningAddress(lightningAddress),
      (invoice) => _processLightningInvoice(invoice),
    );
  }

  Future<Either<String, Unit>> _processLightningAddress(
    LightningAddress lightningAddress,
  ) async {
    final result = await getLnurlPayInfo(lightningAddress).run();

    return result.map((payInfo) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => LightningAmountScreen(
                  lightningAddress: lightningAddress,
                  payInfo: payInfo,
                  appContext: widget.appContext,
                ),
          ),
        );
      }
      return unit;
    });
  }

  Future<Either<String, Unit>> _processLightningInvoice(String invoice) async {
    final result =
        await api_utils.quoteBolt11Invoice(widget.appContext, invoice).run();

    return result.map((decodedInvoice) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => PayInvoiceScreen(
                  decodedInvoice: decodedInvoice,
                  displayDescription: true,
                  rawInvoice: invoice,
                  appContext: widget.appContext,
                  lightningAddress: none<String>(),
                ),
          ),
        );
      }
      return unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDetectionIcon(),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.detectedData.fold(
                          (lightningAddress) => lightningAddress.fullAddress,
                          (invoice) => invoice,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AsyncActionButton(text: 'Continue', onPressed: _handleContinue),
            ],
          ),
        ),
      ),
    );
  }
}
