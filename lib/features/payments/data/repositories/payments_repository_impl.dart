import '../../domain/entities/payment_transaction.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaymentTransactionEntity> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  }) async {
    return _remoteDataSource.processPayment(
      orderId: orderId,
      amount: amount,
      method: method,
    );
  }

  @override
  Future<bool> verifyPayment(String reference) async {
    return _remoteDataSource.verifyPayment(reference);
  }
}
