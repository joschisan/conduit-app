import 'package:flutter/material.dart';
import '../core/context/app_context.dart';
import '../widgets/qr_code_with_copy.dart';
import '../widgets/navigation_button.dart';
import 'create_invoice_screen.dart';

// Pure UI composition
Widget _buildReceiveContent(
  BuildContext context,
  String lightningAddress,
  VoidCallback onCreateInvoice,
) => Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      lightningAddress,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
    QrCodeWithCopy(
      data: lightningAddress,
      copyMessage: 'Lightning address copied to clipboard',
    ),
    const Spacer(),
    NavigationButton(text: 'Create Invoice', onPressed: onCreateInvoice),
  ],
);

class ReceiveScreen extends StatelessWidget {
  final AppContext appContext;

  const ReceiveScreen({super.key, required this.appContext});

  void _navigateToCreateInvoice(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateInvoiceScreen(appContext: appContext),
      ),
    );
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
        child: _buildReceiveContent(
          context,
          appContext.lightningAddress.fullAddress,
          () => _navigateToCreateInvoice(context),
        ),
      ),
    ),
  );
}
