import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:insanity_labs/model/MovieModel.dart';
import 'package:insanity_labs/service/MovieService.dart';

abstract class SearchEvent {}

class Search extends SearchEvent {
  final String text;
  final String? type;
  final String? year;

  Search(
    this.text, {
    this.type,
    this.year,
  });
}

class Clear extends SearchEvent {}

class LoadMore extends SearchEvent {}

abstract class SearchState {}

class Initial extends SearchState {}

class Loading extends SearchState {}

class Loaded extends SearchState {
  final String text;
  final List<MovieModel> movies;
  final String? type;
  final String? year;
  final int page;
  final int totalResults;
  final bool hasMore;
  final bool isLoadingMore;

  Loaded({
    required this.text,
    required this.movies,
    required this.type,
    required this.year,
    required this.page,
    required this.totalResults,
    required this.hasMore,
    required this.isLoadingMore,
  });
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchController extends Bloc<SearchEvent, SearchState> {
  final MovieService service;

  SearchController({required this.service}) : super(Initial()) {
    on<Search>(_searchMovie);
    on<Clear>(_clearData);
    on<LoadMore>(_loadMore);
  }

  Future<void> _searchMovie(
      Search event, Emitter<SearchState> emit) async {
    String text = event.text.trim();
    final type = event.type;
    final year = event.year;

    if (text.isEmpty) {
      emit(Initial());
      return;
    }

    emit(Loading());

    try {
      final result = await _getMovies(
        text: text,
        page: 1,
        type: type,
        year: year,
      );
      final hasMore = result.totalResults > result.movies.length;
      emit(
        Loaded(
          text: text,
          movies: result.movies,
          type: type,
          year: year,
          page: 1,
          totalResults: result.totalResults,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _loadMore(LoadMore event, Emitter<SearchState> emit) async {
    final current = state;
    if (current is! Loaded) return;
    if (!current.hasMore) return;
    if (current.isLoadingMore) return;

    emit(
      Loaded(
        text: current.text,
        movies: current.movies,
        type: current.type,
        year: current.year,
        page: current.page,
        totalResults: current.totalResults,
        hasMore: current.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final nextPage = current.page + 1;
      final result = await _getMovies(
        text: current.text,
        page: nextPage,
        type: current.type,
        year: current.year,
      );
      final movies = <MovieModel>[...current.movies, ...result.movies];
      final hasMore = result.totalResults > movies.length;
      emit(
        Loaded(
          text: current.text,
          movies: movies,
          type: current.type,
          year: current.year,
          page: nextPage,
          totalResults: result.totalResults,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _clearData(Clear event, Emitter<SearchState> emit) {
    emit(Initial());
  }

  Future<_SearchResult> _getMovies({
    required String text,
    required int page,
    String? type,
    String? year,
  }) async {
    final http.Response response = await service.searchMovie(
      text: text,
      page: page.toString(),
      type: type,
      year: year,
    );

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw 'Request failed';
    }

    if (response.statusCode == 401) {
      throw (json['Error'] ?? '401 Unauthorized').toString();
    }

    if (response.statusCode != 200) {
      throw (json['Error'] ?? 'Request failed').toString();
    }

    if ((json["Response"] ?? "") != "True") {
      throw (json['Error'] ?? 'No movies found').toString();
    }

    final List list = (json["Search"] as List?) ?? [];
    final movies = list.map((e) => MovieModel.fromJson(e)).toList();
    final total = int.tryParse(json['totalResults']?.toString() ?? '') ?? 0;
    return _SearchResult(movies: movies, totalResults: total);
  }
}

class _SearchResult {
  final List<MovieModel> movies;
  final int totalResults;
  _SearchResult({required this.movies, required this.totalResults});
}