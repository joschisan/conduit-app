class Payment {
  final String paymentHash;
  final int amountMsat;
  final String status;
  final DateTime createdAt;
  final String paymentType;

  Payment({
    required this.paymentHash,
    required this.amountMsat,
    required this.status,
    required this.createdAt,
    required this.paymentType,
  });

  // Helper getters
  int get amountSats => (amountMsat / 1000).round();
  bool get isIncoming => paymentType == "receive";
  bool get isOutgoing => paymentType == "send";
  bool get isPending => status.toLowerCase() == "pending";
  bool get isSuccess => status.toLowerCase() == "successful";
  bool get isFailed => status.toLowerCase() == "failed";

  String get displayAmount => '${isIncoming ? '+' : '-'}${amountSats}';
}
