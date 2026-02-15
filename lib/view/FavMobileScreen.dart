import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/controller/FavController.dart';
import 'package:insanity_labs/model/MovieModel.dart';
import 'package:insanity_labs/view/DetailMobileScreen.dart';
import 'package:insanity_labs/widget/AppPage.dart';
import 'package:insanity_labs/widget/MovieCard.dart';

class FavMobileScreen extends StatelessWidget {
  const FavMobileScreen({super.key});

  void open(BuildContext context, MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMobileScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Favorites",
      child: BlocBuilder<FavController, FavState>(
        builder: (context, state) {
          if (state is! FavLoaded || state.movies.isEmpty) {
            return const Center(
              child: Text("No favorites"),
            );
          }

          return GridView.builder(
            itemCount: state.movies.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (_, i) {
              final movie = state.movies[i];

              return MovieCard(
                movie: movie,
                isFav: true,
                onTap: () => open(context, movie),
                onFav: () {
                  context
                      .read<FavController>()
                      .add(Remove(movie.id ?? ''));
                },
              );
            },
          );
        },
      ),
    );
  }
}