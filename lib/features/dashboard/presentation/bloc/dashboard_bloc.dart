import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_data.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase _getDashboardDataUseCase;

  DashboardBloc({
    required GetDashboardDataUseCase getDashboardDataUseCase,
  })  : _getDashboardDataUseCase = getDashboardDataUseCase,
        super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<ToggleRetailWholesaleMode>(_onToggleRetailWholesaleMode);
    on<ChangeDeliveryLocation>(_onChangeDeliveryLocation);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final categories = await _getDashboardDataUseCase.getCategories();
      final telemetry = await _getDashboardDataUseCase.getHubTelemetry();
      emit(state.copyWith(
        status: DashboardStatus.loaded,
        categories: categories,
        telemetry: telemetry,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleRetailWholesaleMode(
      ToggleRetailWholesaleMode event, Emitter<DashboardState> emit) {
    emit(state.copyWith(isWholesaleMode: event.isWholesale));
  }

  void _onChangeDeliveryLocation(
      ChangeDeliveryLocation event, Emitter<DashboardState> emit) {
    emit(state.copyWith(deliveryLocation: event.location));
  }
}
