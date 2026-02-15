import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/controller/FavController.dart';
import 'package:insanity_labs/controller/NetworkController.dart';
import 'package:insanity_labs/controller/SearchController.dart';
import 'package:insanity_labs/service/MovieService.dart';
import 'package:insanity_labs/view/HomeScreen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MovieService>(
          create: (_) => MovieService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NetworkController>(
            create: (_) => NetworkController(),
          ),
          BlocProvider<SearchController>(
            create: (context) => SearchController(
              service: context.read<MovieService>(),
            ),
          ),
          BlocProvider<FavController>(
            create: (context) => FavController(
              service: context.read<MovieService>(),
            )..add(Load()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Movies",
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF111111),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}