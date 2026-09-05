import '../entities/payment_transaction.dart';

abstract class PaymentsRepository {
  Future<PaymentTransactionEntity> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  });

  Future<bool> verifyPayment(String reference);
}
