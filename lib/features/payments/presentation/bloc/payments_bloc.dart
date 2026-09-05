import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/process_payment.dart';
import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final ProcessPaymentUseCase _processPaymentUseCase;

  PaymentsBloc({required ProcessPaymentUseCase processPaymentUseCase})
      : _processPaymentUseCase = processPaymentUseCase,
        super(const PaymentsState()) {
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<AuthorizeAndPayEvent>(_onAuthorizeAndPay);
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethodEvent event, Emitter<PaymentsState> emit) {
    emit(state.copyWith(selectedMethod: event.method));
  }

  Future<void> _onAuthorizeAndPay(
      AuthorizeAndPayEvent event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(status: PaymentsStatus.processing, errorMessage: null));
    try {
      final tx = await _processPaymentUseCase(
        orderId: event.orderId,
        amount: event.amount,
        method: state.selectedMethod,
      );
      emit(state.copyWith(
        status: PaymentsStatus.authorized,
        transaction: tx,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
