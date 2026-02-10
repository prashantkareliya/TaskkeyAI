import 'package:equatable/equatable.dart';

class CoinDetail extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String description;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double high24h;
  final double low24h;
  final double priceChange7d;
  final double priceChange30d;
  final List<double> sparkline;

  const CoinDetail({
    required this.id,
    required this.symbol,
    required this.name,
    required this.description,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.high24h,
    required this.low24h,
    required this.priceChange7d,
    required this.priceChange30d,
    required this.sparkline,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    final marketData = json['market_data'] ?? {};
    final sparklineData = marketData['sparkline_7d']?['price'] as List?;
    
    return CoinDetail(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: json['name'] ?? '',
      description: json['description']?['en'] ?? '',
      image: json['image']?['large'] ?? '',
      currentPrice: (marketData['current_price']?['usd'] ?? 0).toDouble(),
      marketCap: (marketData['market_cap']?['usd'] ?? 0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      high24h: (marketData['high_24h']?['usd'] ?? 0).toDouble(),
      low24h: (marketData['low_24h']?['usd'] ?? 0).toDouble(),
      priceChange7d: (marketData['price_change_percentage_7d'] ?? 0).toDouble(),
      priceChange30d: (marketData['price_change_percentage_30d'] ?? 0).toDouble(),
      sparkline: sparklineData?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }

  double get volatilityScore => (priceChange7d.abs() + priceChange30d.abs()) / 2;

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        description,
        image,
        currentPrice,
        marketCap,
        marketCapRank,
        high24h,
        low24h,
        priceChange7d,
        priceChange30d,
        sparkline,
      ];
}
