import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/api/coin_api_service.dart';
import 'data/models/viewed_coin.dart';
import 'data/repositories/coin_repository.dart';
import 'logic/blocs/dashboard/dashboard_bloc.dart';
import 'logic/blocs/dashboard/dashboard_event.dart';
import 'ui/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(ViewedCoinAdapter());
  await Hive.openBox<ViewedCoin>('viewed_coins');

  final dio = Dio();
  final apiService = CoinApiService(dio);
  final repository = CoinRepository(apiService);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final CoinRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DashboardBloc(repository)..add(const FetchCoins()),
          ),
        ],
        child: MaterialApp(
          title: 'Crypto Insight',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A00E0)),
            textTheme: GoogleFonts.openSansTextTheme(),
          ),
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
