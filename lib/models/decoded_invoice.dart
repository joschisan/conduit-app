import 'package:fpdart/fpdart.dart';

class DecodedInvoice {
  final int amount; // in sats
  final int fee; // in sats
  final String description;
  final int expirySecs;

  const DecodedInvoice({
    required this.amount,
    required this.fee,
    required this.description,
    required this.expirySecs,
  });

  /// Parse JSON to DecodedInvoice with functional error handling
  /// Returns Either<String, DecodedInvoice> where:
  /// - Left contains error message
  /// - Right contains parsed DecodedInvoice
  static Either<String, DecodedInvoice> fromJson(Map<String, dynamic> json) {
    return Either.fromNullable(
          json['amount_msat'],
          () => 'Missing required field: amount_msat',
        )
        .flatMap(
          (value) =>
              value is num
                  ? Either.right(value)
                  : Either.left('Invalid amount_msat: must be a number'),
        )
        .flatMap(
          (amountMsat) => Either.fromNullable(
                json['fee_msat'],
                () => 'Missing required field: fee_msat',
              )
              .flatMap(
                (value) =>
                    value is num
                        ? Either.right(value)
                        : Either.left('Invalid fee_msat: must be a number'),
              )
              .flatMap(
                (feeMsat) => Either.fromNullable(
                      json['description'],
                      () => 'Missing required field: description',
                    )
                    .flatMap(
                      (value) =>
                          value is String
                              ? Either.right(value)
                              : Either.left('Invalid description: must be a string'),
                    )
                    .flatMap(
                      (description) => Either.fromNullable(
                            json['expiry_secs'],
                            () => 'Missing required field: expiry_secs',
                          )
                          .flatMap(
                            (value) =>
                                value is num
                                    ? Either.right(value.toInt())
                                    : Either.left(
                                      'Invalid expiry_secs: must be a number',
                                    ),
                          )
                          .map(
                            (expirySecs) => DecodedInvoice(
                              amount: amountMsat ~/ 1000, // Convert millisats to sats
                              fee: feeMsat ~/ 1000, // Convert millisats to sats
                              description: description,
                              expirySecs: expirySecs,
                            ),
                          ),
                    ),
              ),
        );
  }

  String get formattedAmount => '$amount sats';

  String get formattedFee => '$fee sats';

  bool get hasDescription => description.isNotEmpty;

  String get formattedExpiry => '$expirySecs seconds';
}
