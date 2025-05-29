import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final int? minAmount;
  final int? maxAmount;
  final String? Function(String?)? validator;
  final bool autofocus;
  final String? labelText;
  final String? hintText;

  const AmountField({
    Key? key,
    required this.controller,
    this.minAmount,
    this.maxAmount,
    this.validator,
    this.autofocus = false,
    this.labelText,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText ?? 'Amount (sats)',
        hintText: hintText,
        prefixIcon: const Icon(Icons.bolt),
        border: const OutlineInputBorder(),
        helperText: _buildHelperText(),
      ),
      keyboardType: TextInputType.number,
      autofocus: autofocus,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator ?? _defaultValidator,
    );
  }

  String? _buildHelperText() {
    if (minAmount != null && maxAmount != null) {
      return 'Min: $minAmount sats - Max: $maxAmount sats';
    } else if (minAmount != null) {
      return 'Min: $minAmount sats';
    } else if (maxAmount != null) {
      return 'Max: $maxAmount sats';
    }
    return null;
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final amount = int.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (minAmount != null && amount < minAmount!) {
      return 'Amount must be at least $minAmount sats';
    }
    if (maxAmount != null && amount > maxAmount!) {
      return 'Amount must be at most $maxAmount sats';
    }
    return null;
  }
}
