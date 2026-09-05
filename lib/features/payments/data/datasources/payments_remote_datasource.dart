import 'package:uuid/uuid.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/payment_transaction.dart';
import '../models/payment_transaction_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<PaymentTransactionModel> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  });

  Future<bool> verifyPayment(String reference);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final _uuid = const Uuid();

  @override
  Future<PaymentTransactionModel> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  }) async {
    final client = SupabaseService.client;
    final txId = 'TX-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final ref = 'CC-PAY-${_uuid.v4().substring(0, 6).toUpperCase()}';

    final model = PaymentTransactionModel(
      transactionId: txId,
      orderId: orderId,
      amount: amount,
      method: method,
      status: PaymentStatus.successful,
      reference: ref,
      timestamp: DateTime.now(),
    );

    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('payments').insert(model.toJson());
        return model;
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 600));
    return model;
  }

  @override
  Future<bool> verifyPayment(String reference) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
