import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/controller/NetworkController.dart';
import 'package:insanity_labs/view/FavMobileScreen.dart';
import 'package:insanity_labs/view/SearchMobileScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final _searchNavKey = GlobalKey<NavigatorState>();
  final _favNavKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get _currentKey {
    return index == 0 ? _searchNavKey : _favNavKey;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final nav = _currentKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
          return;
        }

        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<NetworkController, bool>(
                builder: (context, online) {
                  if (online) return const SizedBox();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    color: Colors.yellow,
                    child: const Text(
                      'No internet connection',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: [
                    Navigator(
                      key: _searchNavKey,
                      onGenerateRoute: (_) {
                        return MaterialPageRoute(
                          builder: (_) => const SearchMobileScreen(),
                        );
                      },
                    ),
                    Navigator(
                      key: _favNavKey,
                      onGenerateRoute: (_) {
                        return MaterialPageRoute(
                          builder: (_) => const FavMobileScreen(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            setState(() {
              index = i;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
