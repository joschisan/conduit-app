import 'package:flutter/material.dart';
import '../widgets/async_action_button.dart';
import '../core/context/app_context.dart';
import '../models/decoded_invoice.dart';
import '../utils/api_utils.dart' as api_utils;
import '../utils/notification_utils.dart';
import 'package:fpdart/fpdart.dart' hide State;

// Pure UI building functions
Widget _buildPaymentIcon() => Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    color: Colors.deepPurple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(30),
  ),
  child: const Icon(Icons.arrow_upward, size: 40, color: Colors.deepPurple),
);

Widget _buildLightningAddressDisplay(Option<String> lightningAddress) {
  return lightningAddress.fold(
    () => const SizedBox.shrink(), // None case - show nothing
    (address) => Column(
      children: [
        Text(
          address,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}

Widget _buildAmountDisplay(String amountText) => Text(
  amountText,
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
);

Widget _buildDetailRow(String label, String value) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    Flexible(
      child: Text(
        value,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.right,
      ),
    ),
  ],
);

Widget _buildInvoiceDetails(
  BuildContext context,
  DecodedInvoice invoice,
  bool displayDescription,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        _buildDetailRow('Fee:', invoice.formattedFee),
        const SizedBox(height: 16),
        if (displayDescription && invoice.hasDescription) ...[
          _buildDetailRow('Description:', invoice.description),
          const SizedBox(height: 16),
        ],
        _buildDetailRow('Expires in:', invoice.formattedExpiry),
      ],
    ),
  );
}

class PayInvoiceScreen extends StatelessWidget {
  final DecodedInvoice decodedInvoice;
  final bool displayDescription;
  final String rawInvoice;
  final AppContext appContext;
  final Option<String> lightningAddress;

  const PayInvoiceScreen({
    Key? key,
    required this.decodedInvoice,
    required this.displayDescription,
    required this.rawInvoice,
    required this.appContext,
    this.lightningAddress = const None(),
  }) : super(key: key);

  Future<Either<String, Unit>> _payInvoice(BuildContext context) async {
    final result =
        await api_utils
            .payInvoice(appContext, rawInvoice, lightningAddress)
            .run();

    return result.map((_) {
      if (context.mounted) {
        Navigator.of(context);
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
                    _buildLightningAddressDisplay(lightningAddress),
                    _buildPaymentIcon(),
                    const SizedBox(height: 24),
                    _buildAmountDisplay(decodedInvoice.formattedAmount),
                    const SizedBox(height: 24),
                    _buildInvoiceDetails(
                      context,
                      decodedInvoice,
                      displayDescription,
                    ),
                  ],
                ),
              ),
              AsyncActionButton(
                text: 'Pay Invoice',
                onPressed: () => _payInvoice(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
