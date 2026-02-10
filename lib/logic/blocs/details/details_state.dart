import 'package:equatable/equatable.dart';
import '../../../data/models/coin_detail.dart';

enum DetailsStatus { initial, loading, success, failure }

class DetailsState extends Equatable {
  final DetailsStatus status;
  final CoinDetail? coinDetail;
  final String errorMessage;

  const DetailsState({
    this.status = DetailsStatus.initial,
    this.coinDetail,
    this.errorMessage = '',
  });

  DetailsState copyWith({
    DetailsStatus? status,
    CoinDetail? coinDetail,
    String? errorMessage,
  }) {
    return DetailsState(
      status: status ?? this.status,
      coinDetail: coinDetail ?? this.coinDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, coinDetail, errorMessage];
}
