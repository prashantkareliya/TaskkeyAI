import 'package:equatable/equatable.dart';
import '../../../data/models/coin.dart';

enum DashboardStatus { initial, loading, success, failure, loadingMore }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<Coin> coins;
  final List<Coin> filteredCoins;
  final bool hasReachedMax;
  final int page;
  final String errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.coins = const <Coin>[],
    this.filteredCoins = const <Coin>[],
    this.hasReachedMax = false,
    this.page = 1,
    this.errorMessage = '',
  });

  DashboardState copyWith({
    DashboardStatus? status,
    List<Coin>? coins,
    List<Coin>? filteredCoins,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      filteredCoins: filteredCoins ?? this.filteredCoins,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, coins, filteredCoins, hasReachedMax, page, errorMessage];
}
