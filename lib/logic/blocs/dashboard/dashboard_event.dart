import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchCoins extends DashboardEvent {
  final bool isRefresh;
  const FetchCoins({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchCoins extends DashboardEvent {
  final String query;
  const SearchCoins(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreCoins extends DashboardEvent {}
