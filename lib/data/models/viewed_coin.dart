import 'package:hive/hive.dart';

part 'viewed_coin.g.dart';

@HiveType(typeId: 0)
class ViewedCoin extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String symbol;
  
  @HiveField(3)
  final double currentPrice;
  
  @HiveField(4)
  final double priceChangePercentage24h;



  ViewedCoin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,  });
}
