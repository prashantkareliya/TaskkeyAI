import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/viewed_coin.dart';
import '../../data/repositories/coin_repository.dart';
import '../../logic/blocs/details/details_bloc.dart';
import '../../logic/blocs/details/details_event.dart';
import '../../logic/blocs/details/details_state.dart';
import 'summary_screen.dart';

class DetailsScreen extends StatefulWidget {
  final String coinId;
  final String coinName;

  const DetailsScreen({super.key, required this.coinId, required this.coinName});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isDescriptionExpanded = false;
  String _selectedPeriod = 'Today';

  // Static formatters to avoid recreation on every build
  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _compactFormat = NumberFormat.compactCurrency(symbol: '\$');
  static final _simpleCurrencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  void _saveToViewed(BuildContext context, dynamic coin) {
    final box = Hive.box<ViewedCoin>('viewed_coins');
    final alreadyViewed = box.values.any((element) => element.id == coin.id);
    
    if (!alreadyViewed) {
      box.add(ViewedCoin(
        id: coin.id,
        name: coin.name,
        symbol: coin.symbol,
        currentPrice: coin.currentPrice,
        priceChangePercentage24h: coin.priceChange7d
      ));
    }

    if (box.length >= 3 && !ModalRoute.of(context)!.isCurrent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You have viewed 3 or more coins! Check the summary.'),
          action: SnackBarAction(
            label: 'Summary',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SummaryScreen()));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsBloc(context.read<CoinRepository>())..add(FetchCoinDetail(widget.coinId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.star_border, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocConsumer<DetailsBloc, DetailsState>(
          listener: (context, state) {
            if (state.status == DetailsStatus.success && state.coinDetail != null) {
              _saveToViewed(context, state.coinDetail);
            }
          },
          builder: (context, state) {
            if (state.status == DetailsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DetailsStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }

            if (state.status == DetailsStatus.success && state.coinDetail != null) {
              final coin = state.coinDetail!;
              final isPositive7d = coin.priceChange7d >= 0;
              final volColor = _getVolatilityColor(coin.volatilityScore);
              final priceChange7dValue = coin.currentPrice * (coin.priceChange7d / 100);

              // Pre-calculate spots for the chart to avoid mapping during paint
              final List<FlSpot> spots = coin.sparkline.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // Smoother scrolling
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(coin, isPositive7d, priceChange7dValue),
                    const SizedBox(height: 24),
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),
                    _buildChart(spots),
                    const SizedBox(height: 24),
                    _buildMarketStats(coin),
                    const SizedBox(height: 24),
                    _buildStatisticsGrid(coin, volColor),
                    const SizedBox(height: 24),
                    _buildDescription(coin),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic coin, bool isPositive7d, double priceChange7dValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9E5FFF), Color(0xFF4C6FFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CachedNetworkImage(
                  imageUrl: coin.image,
                  width: 32,
                  height: 32,
                  placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
              Text(
                _simpleCurrencyFormat.format(coin.currentPrice),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(coin.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(coin.symbol, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 18)),
                ],
              ),
              Row(
                children: [
                  Icon(isPositive7d ? Icons.trending_up : Icons.trending_down, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${isPositive7d ? '+' : ''}${coin.priceChange7d.toStringAsFixed(2)}%',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text('(${_currencyFormat.format(priceChange7dValue)})', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ['Today', '1 w', '1 m', '3 m', '1 y'].map((p) => _buildPeriodItem(p)).toList(),
      ),
    );
  }

  Widget _buildPeriodItem(String period) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          period,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildChart(List<FlSpot> spots) {
    return RepaintBoundary(
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1, dashArray: [5, 5]),
              getDrawingVerticalLine: (value) => const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1, dashArray: [5, 5]),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) => Text(_compactFormat.format(value), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value % 20 == 0) return Text('${value.toInt()}:00', style: const TextStyle(color: Colors.grey, fontSize: 10));
                    return const SizedBox();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF00C853),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: const Color(0xFF00C853).withOpacity(0.1)),
              ),
            ],
          ),
          duration: Duration.zero, // Disable internal animations for better performance
        ),
      ),
    );
  }

  Widget _buildMarketStats(dynamic coin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Market Cap Rank', '#${coin.marketCapRank}'),
        _buildStatItem('Market Cap', _compactFormat.format(coin.marketCap)),
      ],
    );
  }

  Widget _buildStatisticsGrid(dynamic coin, Color volColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildGridRow('24h High', _currencyFormat.format(coin.high24h), '24h Low', _currencyFormat.format(coin.low24h)),
          const Divider(),
          _buildGridRow('7d Change', '${coin.priceChange7d.toStringAsFixed(2)}%', '30d Change', '${coin.priceChange30d.toStringAsFixed(2)}%'),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildStatItem('Volatility Score', coin.volatilityScore.toStringAsFixed(2))),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: volColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(_getVolatilityLabel(coin.volatilityScore), style: TextStyle(color: volColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(dynamic coin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          coin.description,
          maxLines: _isDescriptionExpanded ? null : 4,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        if (coin.description.length > 200)
          TextButton(
            onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(_isDescriptionExpanded ? 'Read Less' : 'Read More'),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sell', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildGridRow(String l1, String v1, String l2, String v2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(l1, v1)),
          Expanded(child: _buildStatItem(l2, v2)),
        ],
      ),
    );
  }

  String _getVolatilityLabel(double score) {
    if (score < 5) return 'Low';
    if (score < 15) return 'Medium';
    return 'High';
  }

  Color _getVolatilityColor(double score) {
    if (score < 5) return Colors.green;
    if (score < 15) return Colors.orange;
    return Colors.red;
  }
}
