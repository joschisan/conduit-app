import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:eventflux/eventflux.dart';

/// Pure function for event parsing with functional error handling
Either<String, void> parseAndHandleEvent(
  String? eventData,
  void Function(int) onBalanceUpdate,
  void Function({
    required String id,
    required int amountMsat,
    required String status,
    required int createdAt,
    required String paymentType,
    required Option<String> lightningAddress,
  })
  onPaymentUpdate,
  void Function(String) onNotification,
) {
  return Either.tryCatch(
    () => jsonDecode(eventData ?? '') as Map<String, dynamic>,
    (error, _) => 'JSON decode error: $error',
  ).flatMap(
    (data) => Either.tryCatch(
      () => data['variant'] as String,
      (error, _) => 'Missing variant field: $error',
    ).flatMap((variant) {
      switch (variant) {
        case 'Balance':
          return Either.tryCatch(
            () => onBalanceUpdate(data['msat'] as int),
            (error, _) => 'Balance parsing error: $error',
          );
        case 'Payment':
          return Either.tryCatch(
            () => onPaymentUpdate(
              id: data['id'] as String,
              amountMsat: data['amount_msat'] as int,
              status: data['status'] as String,
              createdAt: data['created_at'] as int,
              paymentType: data['payment_type'] as String,
              lightningAddress: Option.fromNullable(data['lightning_address'] as String?),
            ),
            (error, _) => 'Payment parsing error: $error',
          );
        case 'Notification':
          return Either.tryCatch(
            () => onNotification(data['message'] as String),
            (error, _) => 'Notification parsing error: $error',
          );
        default:
          return left('Unknown event variant: $variant');
      }
    }),
  );
}

/// Connect to event stream using EventFlux 2.2.1
void connectEventStream(
  String baseUrl,
  String token,
  void Function(String) handleData,
) {
  EventFlux.instance.connect(
    EventFluxConnectionType.get,
    '$baseUrl/user/events',
    header: {'Authorization': 'Bearer $token', 'Accept': 'text/event-stream'},
    onSuccessCallback: (EventFluxResponse? response) {
      print('EventFlux connection successful');

      response?.stream?.listen((event) {
        // Convert EventFluxData to String and handle
        print('EventFlux data: ${event.data}');

        handleData(event.data ?? '');
      });
    },
    onError: (error) {
      print('EventFlux connection error: ${error.message}');
    },
    autoReconnect: true,
    reconnectConfig: ReconnectConfig(
      mode: ReconnectMode.linear,
      interval: Duration(seconds: 3),
      maxAttempts: -1, // Infinite retries
      onReconnect: () {
        print('EventFlux reconnecting...');
      },
    ),
  );
}

/// Disconnect from EventFlux
void disconnectEventStream() {
  EventFlux.instance.disconnect();
}
