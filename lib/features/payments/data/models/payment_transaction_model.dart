import '../../domain/entities/payment_transaction.dart';

class PaymentTransactionModel extends PaymentTransactionEntity {
  const PaymentTransactionModel({
    required super.transactionId,
    required super.orderId,
    required super.amount,
    required super.method,
    super.status = PaymentStatus.successful,
    required super.reference,
    required super.timestamp,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      transactionId: json['transaction_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: _methodFromString(json['method'] as String?),
      status: _statusFromString(json['status'] as String?),
      reference: json['reference'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'order_id': orderId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'reference': reference,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static PaymentMethod _methodFromString(String? method) {
    switch (method?.toLowerCase()) {
      case 'wallet':
        return PaymentMethod.wallet;
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'cashondelivery':
        return PaymentMethod.cashOnDelivery;
      default:
        return PaymentMethod.gateway;
    }
  }

  static PaymentStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'authorized':
        return PaymentStatus.authorized;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.successful;
    }
  }
}
