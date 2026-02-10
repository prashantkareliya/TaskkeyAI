import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/repositories/coin_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final CoinRepository _repository;

  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<FetchCoins>(_onFetchCoins);
    on<LoadMoreCoins>(
      _onLoadMoreCoins,
      transformer: (events, mapper) => events.throttleTime(const Duration(milliseconds: 500)).switchMap(mapper),
    );
    on<SearchCoins>(_onSearchCoins);
  }

  Future<void> _onFetchCoins(FetchCoins event, Emitter<DashboardState> emit) async {
    if (event.isRefresh) {
      emit(state.copyWith(status: DashboardStatus.loading, page: 1, hasReachedMax: false));
    } else {
      if (state.status == DashboardStatus.initial) {
        emit(state.copyWith(status: DashboardStatus.loading));
      }
    }

    try {
      final coins = await _repository.getCoins(page: 1);
      emit(state.copyWith(
        status: DashboardStatus.success,
        coins: coins,
        filteredCoins: coins,
        page: 1,
        hasReachedMax: coins.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreCoins(LoadMoreCoins event, Emitter<DashboardState> emit) async {
    if (state.hasReachedMax || state.status == DashboardStatus.loadingMore) return;

    emit(state.copyWith(status: DashboardStatus.loadingMore));

    try {
      final nextPage = state.page + 1;
      final coins = await _repository.getCoins(page: nextPage);
      
      if (coins.isEmpty) {
        emit(state.copyWith(status: DashboardStatus.success, hasReachedMax: true));
      } else {
        final allCoins = List.of(state.coins)..addAll(coins);
        emit(state.copyWith(
          status: DashboardStatus.success,
          coins: allCoins,
          filteredCoins: allCoins, // Reset filter when loading more for simplicity, or we could re-apply filter
          page: nextPage,
          hasReachedMax: coins.length < 20,
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onSearchCoins(SearchCoins event, Emitter<DashboardState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredCoins: state.coins));
      return;
    }

    final filtered = state.coins.where((coin) {
      return coin.name.toLowerCase().contains(event.query.toLowerCase()) ||
          coin.symbol.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    emit(state.copyWith(filteredCoins: filtered));
  }
}
