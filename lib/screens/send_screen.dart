import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../core/context/app_context.dart';
import '../utils/ln_address.dart';
import '../widgets/navigation_button.dart';
import '../utils/notification_utils.dart';
import 'detection_screen.dart';
import 'ln_address_screen.dart';

// Send screen state types
enum InputType { lightningAddress, lightningInvoice }

// Result type using Either pattern
typedef SendResult = Either<String, void>;

// Pure input type detection
Option<Either<LightningAddress, String>> detectInputType(String input) {
  // Handle lightning: prefix
  if (input.startsWith('lightning:')) {
    return detectInputType(input.substring(10));
  }

  // Lightning Invoice
  if (input.startsWith('lnbc')) {
    return some(right(input));
  }

  // Lightning Address - use our centralized validation
  return LightningAddress.create(input).fold(
    (_) => none<Either<LightningAddress, String>>(), // Invalid format
    (lightningAddress) => some(
      left(lightningAddress),
    ), // Valid Lightning Address - put on Left side
  );
}

// Pure UI building functions
Widget _buildQrScanner(
  MobileScannerController controller,
  void Function(BarcodeCapture) onDetect,
) => Padding(
  padding: const EdgeInsets.all(16.0),
  child: LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.maxWidth;
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: MobileScanner(controller: controller, onDetect: onDetect),
        ),
      );
    },
  ),
);

Widget _buildPasteButton(VoidCallback? onPaste) => ElevatedButton.icon(
  onPressed: onPaste,
  icon: const Icon(Icons.paste, size: 24),
  label: const Text('Paste from Clipboard'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

class SendScreen extends StatefulWidget {
  final AppContext appContext;
  final List<String> lightningAddresses;

  const SendScreen({
    super.key,
    required this.appContext,
    required this.lightningAddresses,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processInput(barcodes.first.rawValue!);
    }
  }

  Future<void> _processInput(String input) async {
    detectInputType(input).fold(
      () => _showError('Invalid Lightning address or invoice format'),
      (detectedData) async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => DetectionScreen(
                  detectedData: detectedData,
                  appContext: widget.appContext,
                ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    NotificationUtils.showError(message);
  }

  void _showLightningAddressScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => LightningAddressScreen(
              appContext: widget.appContext,
              availableAddresses: widget.lightningAddresses,
            ),
      ),
    );
  }

  Future<void> _handleClipboardPaste() async {
    final result =
        await TaskEither.tryCatch(
              () => Clipboard.getData(Clipboard.kTextPlain),
              (error, stackTrace) => 'Clipboard access error: $error',
            )
            .flatMap(
              (clipboardData) => TaskEither.fromOption(
                Option.fromNullable(
                  clipboardData?.text,
                ).filter((text) => text.isNotEmpty),
                () => 'Clipboard is empty',
              ),
            )
            .run();

    result.fold(_showError, _processInput);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            _buildQrScanner(_controller, _onDetect),

            _buildPasteButton(_handleClipboardPaste),

            const Spacer(),

            NavigationButton(
              text: 'Send to Lightning Address',
              onPressed: _showLightningAddressScreen,
            ),
          ],
        ),
      ),
    ),
  );
}
