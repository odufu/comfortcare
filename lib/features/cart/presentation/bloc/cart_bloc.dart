import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/manage_cart.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ManageCartUseCase _manageCartUseCase;

  CartBloc({required ManageCartUseCase manageCartUseCase})
      : _manageCartUseCase = manageCartUseCase,
        super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<AttachPrescriptionEvent>(_onAttachPrescription);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await _manageCartUseCase.getItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      await _manageCartUseCase.addItem(event.product, event.quantity);
      final items = await _manageCartUseCase.getItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCartItemQuantity(
      UpdateCartItemQuantity event, Emitter<CartState> emit) async {
    try {
      await _manageCartUseCase.updateQuantity(event.productId, event.quantity);
      final items = await _manageCartUseCase.getItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveCartItem(
      RemoveCartItem event, Emitter<CartState> emit) async {
    try {
      await _manageCartUseCase.removeItem(event.productId);
      final items = await _manageCartUseCase.getItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAttachPrescription(
      AttachPrescriptionEvent event, Emitter<CartState> emit) async {
    try {
      await _manageCartUseCase.attachPrescription(event.productId);
      final items = await _manageCartUseCase.getItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      await _manageCartUseCase.clear();
      emit(state.copyWith(status: CartStatus.loaded, items: const []));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }
}
