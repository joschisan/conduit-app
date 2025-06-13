import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'dart:convert';
import '../core/context/app_context.dart';
import '../models/decoded_invoice.dart';
import 'fp_utils.dart';

/// Get a quote for a Bolt11 Lightning invoice with functional error handling
/// Returns TaskEither<String, DecodedInvoice> where:
/// - Left contains error message
/// - Right contains decoded invoice with fee information
TaskEither<String, DecodedInvoice> quoteBolt11Invoice(
  AppContext appContext,
  String invoice,
) {
  return safeTask(
        () => http.post(
          Uri.parse('${appContext.baseUrl}/user/bolt11/quote'),
          headers: appContext.headers,
          body: jsonEncode({'invoice': invoice.trim()}),
        ),
      )
      .mapLeft((_) => 'Failed to connect to server')
      .flatMap(transformResponse)
      .flatMap((body) => safe(() => jsonDecode(body) as Map<String, dynamic>))
      .flatMap(
        (jsonData) => TaskEither.fromEither(DecodedInvoice.fromJson(jsonData)),
      );
}

/// Create a Lightning invoice with functional error handling
/// Returns TaskEither<String, String> where:
/// - Left contains error message
/// - Right contains invoice string
TaskEither<String, String> createInvoice(
  AppContext appContext,
  int amountSats,
  String description,
) {
  return safeTask(
        () => http.post(
          Uri.parse('${appContext.baseUrl}/user/bolt11/receive'),
          headers: appContext.headers,
          body: jsonEncode({
            'amount_msat': amountSats * 1000,
            'description': description.trim(),
            'expiry_secs': 3600,
          }),
        ),
      )
      .mapLeft((_) => 'Failed to connect to server')
      .flatMap(transformResponse)
      .flatMap((body) => safe(() => jsonDecode(body) as Map<String, dynamic>))
      .flatMap((data) => safe(() => data['invoice'] as String));
}

/// Pay a Lightning invoice with functional error handling
/// Returns TaskEither<String, Unit> where:
/// - Left contains error message
/// - Right contains unit (success)
TaskEither<String, Unit> payInvoice(
  AppContext appContext, 
  String invoice,
  Option<String> lightningAddress,
) {
  return safeTask(
        () => http.post(
          Uri.parse('${appContext.baseUrl}/user/bolt11/send'),
          headers: appContext.headers,
          body: jsonEncode({
            'invoice': invoice.trim(),
            ...lightningAddress.fold(
              () => <String, dynamic>{}, // None case - empty map
              (address) => {'lightning_address': address}, // Some case - include field
            ),
          }),
        ),
      )
      .mapLeft((_) => 'Failed to connect to server')
      .flatMap(transformResponse)
      .map((_) => unit);
}

TaskEither<String, String> transformResponse(http.Response response) {
      if (response.statusCode == 200) {
        return TaskEither.right(response.body);
      }
      
      // Map status codes to human readable messages
      switch (response.statusCode) {
        case 400:
          return TaskEither.left(response.body ?? 'Invalid request');
        case 401:
          return TaskEither.left('Session expired, please sign in again');
        case 429:
          return TaskEither.left('Too many requests, please try again later');
        default:
          return TaskEither.left('Something went wrong, please try again');
      }
}