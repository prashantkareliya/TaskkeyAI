import 'package:equatable/equatable.dart';

abstract class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCoinDetail extends DetailsEvent {
  final String id;
  const FetchCoinDetail(this.id);

  @override
  List<Object?> get props => [id];
}
