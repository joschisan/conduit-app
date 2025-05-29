import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:intl/intl.dart';
import '../core/context/app_context.dart';
import '../models/payment.dart';
import '../screens/receive_screen.dart';
import '../screens/send_screen.dart';
import '../utils/notification_utils.dart';
import '../utils/event_utils.dart';

// Pure helper functions with functional programming patterns
IconData getStatusIcon(Payment payment) => switch (payment) {
  _ when payment.isIncoming => Icons.arrow_downward,
  _ when payment.isSuccess => Icons.arrow_upward,
  _ when payment.isFailed => Icons.close,
  _ => Icons.help,
};

// Functional time formatting with pattern matching on duration
String formatTime(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  return switch (difference) {
    _ when difference.inMinutes < 1 => 'Now',
    _ when difference.inMinutes < 60 => '${difference.inMinutes}m ago',
    _ when difference.inHours < 24 => '${difference.inHours}h ago',
    _ => '${difference.inDays}d ago',
  };
}

// Functional composition for balance display with Option pattern matching
Widget buildBalance(fp.Option<int> balanceSats) => balanceSats.fold(
  () => const SizedBox(
    height: 48,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
      ),
    ),
  ),
  (balance) => RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: NumberFormat('#,###').format(balance),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const TextSpan(
          text: 'sats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    ),
  ),
);

// Higher-order function for creating table rows
TableRow buildTableRow(String label, String value) => TableRow(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(value, style: const TextStyle()),
    ),
  ],
);

// Pure function for payment tile with functional composition
Widget buildPaymentTile(Payment payment) => Card(
  margin: const EdgeInsets.symmetric(vertical: 4.0),
  child: ListTile(
    contentPadding: const EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    leading: CircleAvatar(
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      child:
          payment.isPending
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Icon(
                getStatusIcon(payment),
                color: Colors.deepPurple,
                size: 26,
              ),
    ),
    title:
        payment.isIncoming
            ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${payment.displayAmount} sats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
            : Text(
              '${payment.displayAmount} sats',
              style: TextStyle(
                color: payment.isFailed ? Colors.grey : Colors.white,
                fontSize: 16,
              ),
            ),
    trailing: Text(
      formatTime(payment.createdAt),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
  ),
);

// Higher-order function for creating action buttons
Widget buildActionButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  EdgeInsets? padding,
}) => Expanded(
  child: Padding(
    padding: padding ?? EdgeInsets.zero,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ),
);

// Navigation functions as pure actions
void navigateToReceive(BuildContext context, AppContext appContext) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReceiveScreen(appContext: appContext)),
    );

void navigateToSend(BuildContext context, AppContext appContext) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SendScreen(appContext: appContext)),
    );

// Functional composition for action buttons
Widget buildActionButtons(BuildContext context, AppContext appContext) => Row(
  children: [
    buildActionButton(
      label: 'Receive',
      icon: Icons.arrow_downward,
      padding: const EdgeInsets.only(right: 6.0),
      onPressed: () => navigateToReceive(context, appContext),
    ),
    buildActionButton(
      label: 'Send',
      icon: Icons.arrow_upward,
      padding: const EdgeInsets.only(left: 6.0),
      onPressed: () => navigateToSend(context, appContext),
    ),
  ],
);

// Pure side effect handler with functional composition
void handleNotification(String message) {
  NotificationUtils.showInfo(message);
}

void handleError(String error) {
  NotificationUtils.showError(error);
}

class HomeScreen extends StatefulWidget {
  final AppContext appContext;

  const HomeScreen({Key? key, required this.appContext}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Direct state variables instead of HomeState class
  fp.Option<int> _balanceSats = const fp.None();
  List<Payment> _payments = const [];

  @override
  void initState() {
    super.initState();

    // Safely access widget properties
    final appContext = widget.appContext;
    final baseUrl = appContext.baseUrl;
    final token = appContext.token;

    // Use the EventFlux connection
    connectEventStream(baseUrl, token, (eventData) {
      // Parse and handle events using the pure functions
      parseAndHandleEvent(
        eventData,
        _handleBalanceUpdate,
        _handlePaymentUpdate,
        _handleNotification,
      ).fold(
        (error) {
          print('Failed to parse event: $error: $eventData');
        },
        (_) {}, // Success case - nothing to do
      );
    });
  }

  // Pure state update functions - now directly updating state variables
  void _handleBalanceUpdate(int balanceMsat) {
    setState(() {
      _balanceSats = fp.Some((balanceMsat / 1000).round());
    });
  }

  void _handlePaymentUpdate({
    required String id,
    required int amountMsat,
    required String status,
    required int createdAt,
    required String paymentType,
  }) {
    final payment = Payment(
      paymentHash: id,
      amountMsat: amountMsat,
      status: status,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
      paymentType: paymentType,
    );

    setState(() {
      _payments = _addToPaymentsList(_payments, payment);
    });
  }

  void _handleNotification(String message) => handleNotification(message);

  // Pure function to add/update payment in list (moved from home_state.dart)
  List<Payment> _addToPaymentsList(List<Payment> current, Payment newPayment) {
    final existingIndex = current.indexWhere(
      (p) => p.paymentHash == newPayment.paymentHash,
    );

    if (existingIndex != -1) {
      // Replace existing payment
      return current
          .asMap()
          .entries
          .map((entry) => entry.key == existingIndex ? newPayment : entry.value)
          .toList();
    } else {
      // Add new payment to front
      return [newPayment, ...current];
    }
  }

  @override
  void dispose() {
    disconnectEventStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildBalance(_balanceSats),
              const SizedBox(height: 24),
              buildActionButtons(context, widget.appContext),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _payments.length,
                  itemBuilder: (_, index) => buildPaymentTile(_payments[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
