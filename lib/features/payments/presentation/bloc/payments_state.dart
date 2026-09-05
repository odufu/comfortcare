import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_transaction.dart';

enum PaymentsStatus { initial, processing, authorized, error }

class PaymentsState extends Equatable {
  final PaymentsStatus status;
  final PaymentMethod selectedMethod;
  final PaymentTransactionEntity? transaction;
  final String? errorMessage;

  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.selectedMethod = PaymentMethod.gateway,
    this.transaction,
    this.errorMessage,
  });

  PaymentsState copyWith({
    PaymentsStatus? status,
    PaymentMethod? selectedMethod,
    PaymentTransactionEntity? transaction,
    String? errorMessage,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedMethod, transaction, errorMessage];
}
