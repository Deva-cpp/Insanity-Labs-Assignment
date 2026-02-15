import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/model/MovieModel.dart';
import 'package:insanity_labs/service/MovieService.dart';

abstract class FavEvent {}

class Load extends FavEvent {}

class Add extends FavEvent {
  final MovieModel movie;
  Add(this.movie);
}

class Remove extends FavEvent {
  final String id;
  Remove(this.id);
}

abstract class FavState {}

class FavInitial extends FavState {}

class FavLoaded extends FavState {
  final List<MovieModel> movies;
  FavLoaded(this.movies);

  bool has(String id) {
    return movies.any((e) => e.id == id);
  }
}

class FavController extends Bloc<FavEvent, FavState> {
  final MovieService service;

  FavController({required this.service})
      : super(FavInitial()) {
    on<Load>(_loadFav);
    on<Add>(_addFav);
    on<Remove>(_removeFav);
  }

  Future<void> _loadFav(
      Load event, Emitter<FavState> emit) async {
    List<MovieModel> list = await _getFavList();
    emit(FavLoaded(list));
  }

  Future<void> _addFav(
      Add event, Emitter<FavState> emit) async {
    final current = state is FavLoaded ? (state as FavLoaded).movies : <MovieModel>[];
    if (current.any((e) => e.id == event.movie.id)) return;

    List<MovieModel> updated = [event.movie, ...current];

    await _saveFavList(updated);

    emit(FavLoaded(updated));
  }

  Future<void> _removeFav(
      Remove event, Emitter<FavState> emit) async {
    final current = state is FavLoaded ? (state as FavLoaded).movies : <MovieModel>[];

    List<MovieModel> updated =
        current.where((e) => e.id != event.id).toList();

    await _saveFavList(updated);

    emit(FavLoaded(updated));
  }

  Future<List<MovieModel>> _getFavList() async {
    List<String> raw =
        await service.getFavMovieStrings();

    return raw
        .map((e) =>
            MovieModel.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> _saveFavList(
      List<MovieModel> list) async {
    List<String> data =
        list.map((e) => jsonEncode(e.toJson())).toList();

    await service.saveFavMovieStrings(data);
  }
}