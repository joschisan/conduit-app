import 'package:fpdart/fpdart.dart' as fp;

// State types for receive screen
abstract class ReceiveState {
  const ReceiveState();
}

class IdleReceiveState extends ReceiveState {
  const IdleReceiveState();
}

class LoadingReceiveState extends ReceiveState {
  const LoadingReceiveState();
}

// Form data type
class ReceiveFormData {
  final String amount;
  final String description;

  const ReceiveFormData({required this.amount, required this.description});
}

// Invoice result type
class InvoiceResult {
  final String invoice;
  final int amount;
  final String description;

  const InvoiceResult({
    required this.invoice,
    required this.amount,
    required this.description,
  });
}

// Private validation functions
fp.Either<String, int> _validateAmount(String amount) {
  if (amount.isEmpty) {
    return fp.left('Amount is required');
  }

  final parsed = int.tryParse(amount);
  if (parsed == null) {
    return fp.left('Please enter a valid number');
  }

  if (parsed < 1) {
    return fp.left('Amount must be at least 1 sat');
  }

  if (parsed > 100000000) {
    return fp.left('Amount cannot exceed 100,000,000 sats');
  }

  return fp.right(parsed);
}

fp.Either<String, String> _validateDescription(String description) {
  if (description.length > 50) {
    return fp.left('Description cannot exceed 50 characters');
  }

  return fp.right(description);
}

// Public combined validation
fp.Either<String, ReceiveFormData> validateReceiveForm(
  ReceiveFormData formData,
) {
  return _validateAmount(formData.amount).flatMap(
    (amount) => _validateDescription(formData.description).map(
      (description) =>
          ReceiveFormData(amount: amount.toString(), description: description),
    ),
  );
}

// State transition functions
ReceiveState setIdle() => const IdleReceiveState();

ReceiveState setLoading() => const LoadingReceiveState();
