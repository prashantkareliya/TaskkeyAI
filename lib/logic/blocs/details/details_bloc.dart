import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/coin_repository.dart';
import 'details_event.dart';
import 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final CoinRepository _repository;

  DetailsBloc(this._repository) : super(const DetailsState()) {
    on<FetchCoinDetail>(_onFetchCoinDetail);
  }

  Future<void> _onFetchCoinDetail(FetchCoinDetail event, Emitter<DetailsState> emit) async {
    emit(state.copyWith(status: DetailsStatus.loading));

    try {
      final detail = await _repository.getCoinDetail(event.id);
      emit(state.copyWith(status: DetailsStatus.success, coinDetail: detail));
    } catch (e) {
      emit(state.copyWith(status: DetailsStatus.failure, errorMessage: e.toString()));
    }
  }
}
