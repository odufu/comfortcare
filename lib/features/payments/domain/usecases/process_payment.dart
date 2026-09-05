import '../entities/payment_transaction.dart';
import '../repositories/payments_repository.dart';

class ProcessPaymentUseCase {
  final PaymentsRepository _repository;

  ProcessPaymentUseCase(this._repository);

  Future<PaymentTransactionEntity> call({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  }) {
    return _repository.processPayment(
      orderId: orderId,
      amount: amount,
      method: method,
    );
  }
}
