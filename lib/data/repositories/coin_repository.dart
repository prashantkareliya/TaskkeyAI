import '../api/coin_api_service.dart';
import '../models/coin.dart';
import '../models/coin_detail.dart';

class CoinRepository {
  final CoinApiService _apiService;

  CoinRepository(this._apiService);

  Future<List<Coin>> getCoins({int page = 1}) async {
    return await _apiService.getCoins(page: page);
  }

  Future<CoinDetail> getCoinDetail(String id) async {
    return await _apiService.getCoinDetail(id);
  }
}
