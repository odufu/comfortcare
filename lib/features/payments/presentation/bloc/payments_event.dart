import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_transaction.dart';

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

class SelectPaymentMethodEvent extends PaymentsEvent {
  final PaymentMethod method;

  const SelectPaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class AuthorizeAndPayEvent extends PaymentsEvent {
  final String orderId;
  final double amount;

  const AuthorizeAndPayEvent({required this.orderId, required this.amount});

  @override
  List<Object?> get props => [orderId, amount];
}
