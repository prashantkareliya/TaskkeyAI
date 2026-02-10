import 'package:flutter_test/flutter_test.dart';
import 'package:practical_keyai/data/models/coin_detail.dart';

void main() {
  group('CoinDetail Logic Tests', () {
    test('Volatility Score should be calculated correctly', () {
      const detail = CoinDetail(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        description: '',
        image: '',
        currentPrice: 50000,
        marketCap: 1000000000,
        marketCapRank: 1,
        high24h: 51000,
        low24h: 49000,
        priceChange7d: 10.0,
        priceChange30d: -20.0,
        sparkline: [],
      );

      // (|10| + |-20|) / 2 = 30 / 2 = 15
      expect(detail.volatilityScore, 15.0);
    });

    test('Volatility Score should handle zero changes', () {
      const detail = CoinDetail(
        id: 'stable',
        symbol: 'USDT',
        name: 'Tether',
        description: '',
        image: '',
        currentPrice: 1,
        marketCap: 1000000,
        marketCapRank: 3,
        high24h: 1.01,
        low24h: 0.99,
        priceChange7d: 0.0,
        priceChange30d: 0.0,
        sparkline: [],
      );

      expect(detail.volatilityScore, 0.0);
    });
  });
}
