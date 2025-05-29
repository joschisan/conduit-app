import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../core/context/app_context.dart';
import '../utils/api_utils.dart' as api_utils;
import '../widgets/amount_field.dart';
import '../widgets/async_action_button.dart';
import '../utils/receive_state.dart';
import 'display_invoice_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final AppContext appContext;

  const CreateInvoiceScreen({Key? key, required this.appContext})
    : super(key: key);

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReceiveFormData _formData = const ReceiveFormData(
    amount: '',
    description: '',
  );

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    setState(() {
      _formData = ReceiveFormData(
        amount: _amountController.text,
        description: _descriptionController.text,
      );
    });
  }

  void _navigateToDisplay(InvoiceResult result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => DisplayInvoiceScreen(
              invoice: result.invoice,
              amount: result.amount,
              description: result.description,
            ),
      ),
    );
  }

  Future<Either<String, Unit>> _handleGenerateInvoice() async {
    _updateFormData();

    return validateReceiveForm(_formData).fold(
      (error) => Future.value(left(error)),
      (validData) async {
        final amount = int.parse(validData.amount);

        final result =
            await api_utils
                .createInvoice(widget.appContext, amount, validData.description)
                .map(
                  (invoice) => InvoiceResult(
                    invoice: invoice,
                    amount: amount,
                    description: validData.description,
                  ),
                )
                .run();

        return result.map((invoiceResult) {
          _navigateToDisplay(invoiceResult);
          return unit;
        });
      },
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AmountField(
          controller: _amountController,
          minAmount: 1,
          maxAmount: 100000000,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            counterText: '',
            helperText: 'Max 50 characters',
          ),
          minLines: 1,
          maxLines: 3,
          maxLength: 50,
          onChanged: (_) => _updateFormData(),
        ),
        const Spacer(),
        _buildGenerateButton(),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return AsyncActionButton(
      text: 'Generate Invoice',
      onPressed: _handleGenerateInvoice,
    );
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
          child: _buildForm(),
        ),
      ),
    );
  }
}
