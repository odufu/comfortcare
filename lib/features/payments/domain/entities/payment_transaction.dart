import 'package:equatable/equatable.dart';

enum PaymentMethod {
  gateway, // Paystack / Flutterwave (Cards, Bank Transfer, USSD)
  wallet, // ComfortCare Health Wallet
  bankTransfer, // Direct Clinical Account Transfer
  cashOnDelivery, // Abuja Metro Cash / POS on Delivery
}

enum PaymentStatus {
  pending,
  authorized,
  successful,
  failed,
  reversed,
}

class PaymentTransactionEntity extends Equatable {
  final String transactionId;
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String reference;
  final DateTime timestamp;

  const PaymentTransactionEntity({
    required this.transactionId,
    required this.orderId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.successful,
    required this.reference,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        transactionId,
        orderId,
        amount,
        method,
        status,
        reference,
        timestamp,
      ];
}
