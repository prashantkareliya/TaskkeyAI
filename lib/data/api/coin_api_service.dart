import 'package:dio/dio.dart';
import '../models/coin.dart';
import '../models/coin_detail.dart';

class CoinApiService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  CoinApiService(this._dio);

  Future<List<Coin>> getCoins({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': perPage,
          'page': page,
          'sparkline': false,
        },
      );
      return (response.data as List).map((json) => Coin.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CoinDetail> getCoinDetail(String id) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/coins/$id',
        queryParameters: {
          'localization': false,
          'tickers': false,
          'market_data': true,
          'community_data': false,
          'developer_data': false,
          'sparkline': true,
        },
      );
      return CoinDetail.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
