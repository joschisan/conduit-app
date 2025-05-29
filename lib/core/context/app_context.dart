import 'package:fpdart/fpdart.dart';
import '../../utils/ln_address.dart';

/// Application context that holds authenticated HTTP client and configuration
/// This context only exists when the user is logged in
class AppContext {
  final LightningAddress lightningAddress;
  final String token;

  AppContext({required this.lightningAddress, required this.token});

  /// Legacy getter for backward compatibility
  String get domain => lightningAddress.domain;

  /// Get the base URL with proper protocol
  String get baseUrl => lightningAddress.baseUrl;

  /// Public getter for headers (used by api_utils functions)
  Map<String, String> get headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
