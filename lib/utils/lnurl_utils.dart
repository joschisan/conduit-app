import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'dart:convert';
import '../models/lnurl_pay_info.dart';
import 'ln_address.dart';
import 'fp_utils.dart';

/// Fetches and parses LNURL-pay information for a Lightning Address
/// Returns TaskEither<String, LnurlPayInfo> where:
/// - Left contains error message
/// - Right contains parsed LnurlPayInfo
TaskEither<String, LnurlPayInfo> getLnurlPayInfo(
  LightningAddress lightningAddress,
) {
  return safeTask(
        () => http.get(
          Uri.parse(lightningAddress.lnurlEndpoint),
          headers: {'Content-Type': 'application/json'},
        ),
      )
      .filter(
        (r) => r.statusCode == 200,
        (r) => 'Failed to fetch LNURL-pay info: HTTP ${r.statusCode}',
      )
      .flatMap((r) => safe(() => jsonDecode(r.body) as Map<String, dynamic>))
      .filter(
        (data) => data['tag'] == 'payRequest',
        (data) => 'Invalid LNURL-pay endpoint: missing or invalid tag',
      )
      .flatMap(
        (jsonData) => TaskEither.fromEither(LnurlPayInfo.fromJson(jsonData)),
      );
}

/// Gets a Lightning invoice from an LNURL-pay callback URL
/// Returns TaskEither<String, String> where:
/// - Left contains error message
/// - Right contains Lightning invoice
TaskEither<String, String> getLnurlPayInvoice(
  String callbackUrl,
  int amountMsat,
) {
  final Map<String, String> queryParameters = {'amount': amountMsat.toString()};
  final headers = {'Content-Type': 'application/json'};

  return safe(
        () => Uri.parse(callbackUrl).replace(queryParameters: queryParameters),
      )
      .flatMap((uri) => safeTask(() => http.get(uri, headers: headers)))
      .filter(
        (r) => r.statusCode == 200,
        (r) => 'Failed to get LNURL-pay invoice: HTTP ${r.statusCode}',
      )
      .flatMap((r) => safe(() => jsonDecode(r.body) as Map<String, dynamic>))
      .flatMap((data) => safe(() => data['pr'].toString()));
}
