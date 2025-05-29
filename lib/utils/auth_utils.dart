import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'dart:convert';
import 'account.dart';
import 'fp_utils.dart';

/// Login function with functional error handling
/// Returns TaskEither<String, String> where:
/// - Left contains error message
/// - Right contains authentication token
TaskEither<String, String> login(AccountCredentials credentials) {
  final baseUrl = credentials.lightningAddress.baseUrl;

  return safeTask(
        () => http.post(
          Uri.parse('$baseUrl/account/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': credentials.lightningAddress.username,
            'password': credentials.password,
          }),
        ),
      )
      .filter(
        (r) => r.statusCode == 200,
        (r) => 'Login failed: HTTP ${r.statusCode}',
      )
      .flatMap((r) => safe(() => jsonDecode(r.body) as Map<String, dynamic>))
      .flatMap((data) => safe(() => data['token'] as String));
}

/// Register function with functional error handling
/// Returns TaskEither<String, String> where:
/// - Left contains error message
/// - Right contains authentication token
TaskEither<String, String> register(AccountCredentials credentials) {
  final baseUrl = credentials.lightningAddress.baseUrl;

  return safeTask(
        () => http.post(
          Uri.parse('$baseUrl/account/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': credentials.lightningAddress.username,
            'password': credentials.password,
          }),
        ),
      )
      .filter(
        (r) => r.statusCode == 200,
        (r) => 'Registration failed: HTTP ${r.statusCode}',
      )
      .flatMap((r) => safe(() => jsonDecode(r.body) as Map<String, dynamic>))
      .flatMap((data) => safe(() => data['token'] as String));
}
