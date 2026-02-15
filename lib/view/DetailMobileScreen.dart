import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/controller/DetailController.dart';
import 'package:insanity_labs/controller/FavController.dart';
import 'package:insanity_labs/model/MovieModel.dart';
import 'package:insanity_labs/model/MovieDetailModel.dart';
import 'package:insanity_labs/widget/ErrorView.dart';
import 'package:insanity_labs/widget/Loading.dart';

class DetailMobileScreen extends StatelessWidget {
  final MovieModel movie;

  const DetailMobileScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DetailController(service: context.read())..add(Open(movie.id ?? '')),
      child: const _DetailMobileView(),
    );
  }
}

class _DetailMobileView extends StatelessWidget {
  const _DetailMobileView();

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavController>().state;

    return Scaffold(
      body: BlocBuilder<DetailController, DetailState>(
        builder: (context, state) {
          if (state is DetailLoading || state is DetailInitial) {
            return const Center(child: Loader());
          }

          if (state is DetailError) {
            return ErrorView(
              message: state.message,
              onTap: () {
                final current = context.read<DetailController>().state;
                if (current is DetailLoaded) {
                  context
                      .read<DetailController>()
                      .add(Open(current.movie.id ?? ''));
                }
              },
            );
          }

          if (state is DetailLoaded) {
            final movie = state.movie;
            final isFav = fav is FavLoaded ? fav.has(movie.id ?? '') : false;

            final ratings = (movie.ratings ?? const <RatingModel>[])
                .where(
                  (e) =>
                      ((e.source ?? '').trim().isNotEmpty) &&
                      ((e.value ?? '').trim().isNotEmpty) &&
                      (e.value ?? '').trim() != 'N/A',
                )
                .toList();

            final genres = (movie.genre ?? '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            return Stack(
              children: [
                SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: movie.poster ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) {
                      return Container(color: const Color(0xFF1D1D1D));
                    },
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                if (isFav) {
                                  context
                                      .read<FavController>()
                                      .add(Remove(movie.id ?? ''));
                                } else {
                                  context.read<FavController>().add(
                                        Add(
                                          MovieModel(
                                            id: movie.id,
                                            title: movie.title,
                                            year: movie.year,
                                            poster: movie.poster,
                                            type: 'movie',
                                          ),
                                        ),
                                      );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav
                                      ? const Color(0xFFE53935)
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            movie.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${movie.year ?? ''}  •  ${movie.rated ?? ''}  •  ${movie.runtime ?? ''}  •  IMDB ${movie.imdbRating ?? ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: genres
                                      .map(
                                        (e) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F4F4),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: Colors.black
                                                  .withValues(alpha: 0.06),
                                            ),
                                          ),
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 18),
                                _title('SCORES'),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _score(
                                        'IMDB',
                                        movie.imdbRating ?? '',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _score(
                                        'ROTTEN',
                                        movie.ratingBy('Rotten Tomatoes'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _score(
                                        'META',
                                        movie.ratingBy('Metacritic'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _title('PLOT'),
                                const SizedBox(height: 8),
                                Text(
                                  movie.plot ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: Colors.black.withValues(alpha: 0.76),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _title('CAST'),
                                const SizedBox(height: 8),
                                Text(
                                  movie.actors ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: Colors.black.withValues(alpha: 0.76),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _title('DETAILS'),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      if ((movie.title ?? '').trim().isNotEmpty &&
                                          (movie.title ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Title',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.title ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.year ?? '').trim().isNotEmpty &&
                                          (movie.year ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Year',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.year ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.type ?? '').trim().isNotEmpty &&
                                          (movie.type ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Type',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.type ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.rated ?? '').trim().isNotEmpty &&
                                          (movie.rated ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Rated',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.rated ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.released ?? '').trim().isNotEmpty &&
                                          (movie.released ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Released',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.released ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.runtime ?? '').trim().isNotEmpty &&
                                          (movie.runtime ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Runtime',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.runtime ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.genre ?? '').trim().isNotEmpty &&
                                          (movie.genre ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Genre',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.genre ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.director ?? '').trim().isNotEmpty &&
                                          (movie.director ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Director',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.director ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.writer ?? '').trim().isNotEmpty &&
                                          (movie.writer ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Writer',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.writer ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.language ?? '').trim().isNotEmpty &&
                                          (movie.language ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Language',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.language ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.country ?? '').trim().isNotEmpty &&
                                          (movie.country ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Country',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.country ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.awards ?? '').trim().isNotEmpty &&
                                          (movie.awards ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Awards',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.awards ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.metascore ?? '').trim().isNotEmpty &&
                                          (movie.metascore ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Metascore',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.metascore ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.imdbRating ?? '').trim().isNotEmpty &&
                                          (movie.imdbRating ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'IMDB Rating',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.imdbRating ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.imdbVotes ?? '').trim().isNotEmpty &&
                                          (movie.imdbVotes ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'IMDB Votes',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.imdbVotes ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.totalSeasons ?? '').trim().isNotEmpty &&
                                          (movie.totalSeasons ?? '').trim() !=
                                              'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'Total Seasons',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.totalSeasons ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if ((movie.id ?? '').trim().isNotEmpty &&
                                          (movie.id ?? '').trim() != 'N/A')
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                child: Text(
                                                  'IMDB ID',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  (movie.id ?? '').trim(),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _title('RATINGS'),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      if (ratings.isEmpty)
                                        Text(
                                          '-',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else
                                        ...ratings.map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 110,
                                                  child: Text(
                                                    (e.source ?? '').trim(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black
                                                          .withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    (e.value ?? '').trim(),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _score(String name, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
