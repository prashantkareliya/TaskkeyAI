import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/viewed_coin.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Viewed Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<ViewedCoin>('viewed_coins').listenable(),
        builder: (context, Box<ViewedCoin> box, _) {
          final viewedCoins = box.values.toList();

          if (viewedCoins.isEmpty) {
            return const Center(child: Text('No coins viewed yet.'));
          }

          final avgPrice = viewedCoins.map((e) => e.currentPrice).reduce((a, b) => a + b) / viewedCoins.length;
          
          final bestPerformer = viewedCoins.reduce((a, b) => 
            a.priceChangePercentage24h > b.priceChangePercentage24h ? a : b);
          
          final worstPerformer = viewedCoins.reduce((a, b) => 
            a.priceChangePercentage24h < b.priceChangePercentage24h ? a : b);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard('Statistics', [
                  _buildStatRow('Total Viewed', viewedCoins.length.toString()),
                  _buildStatRow('Avg Price', '\$${avgPrice.toStringAsFixed(2)}'),
                ]),
                const SizedBox(height: 16),
                _buildSummaryCard('Performers (24h)', [
                  _buildStatRow('Best Performer', '${bestPerformer.name} (${bestPerformer.priceChangePercentage24h.toStringAsFixed(2)}%)'),
                  _buildStatRow('Worst Performer', '${worstPerformer.name} (${worstPerformer.priceChangePercentage24h.toStringAsFixed(2)}%)'),
                ]),
                const SizedBox(height: 24),
                const Text('Recently Viewed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: viewedCoins.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final coin = viewedCoins[viewedCoins.length - 1 - index]; // Show latest first
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(coin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(coin.symbol),
                        trailing: Text('\$${coin.currentPrice.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
