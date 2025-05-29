import 'package:flutter/material.dart';
import '../widgets/qr_code_with_copy.dart';

// Pure UI composition
Widget _buildInvoiceContent(BuildContext context, String invoice, int amount) =>
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, color: Colors.deepPurple, size: 48),
            const SizedBox(width: 8),
            Text(
              '$amount sats',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        QrCodeWithCopy(
          data: invoice,
          copyMessage: 'Invoice copied to clipboard',
        ),
        const Spacer(),
      ],
    );

class DisplayInvoiceScreen extends StatelessWidget {
  final String invoice;
  final int amount;

  const DisplayInvoiceScreen._({
    super.key,
    required this.invoice,
    required this.amount,
  });

  // Factory constructor for backward compatibility
  factory DisplayInvoiceScreen({
    Key? key,
    required String invoice,
    required int amount,
    required String description,
  }) => DisplayInvoiceScreen._(key: key, invoice: invoice, amount: amount);

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
        child: SizedBox.expand(
          child: _buildInvoiceContent(context, invoice, amount),
        ),
      ),
    ),
  );
}
