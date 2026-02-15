import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:insanity_labs/model/MovieDetailModel.dart';
import 'package:insanity_labs/service/MovieService.dart';

abstract class DetailEvent {}

class Open extends DetailEvent {
  final String id;
  Open(this.id);
}

abstract class DetailState {}

class DetailInitial extends DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final MovieDetailModel movie;
  DetailLoaded(this.movie);
}

class DetailError extends DetailState {
  final String message;
  DetailError(this.message);
}

class DetailController extends Bloc<DetailEvent, DetailState> {
  final MovieService service;

  DetailController({required this.service})
      : super(DetailInitial()) {
    on<Open>(_openMovie);
  }

  Future<void> _openMovie(
      Open event, Emitter<DetailState> emit) async {

    emit(DetailLoading());

    try {
      final movie = await _getMovieDetail(event.id);
      emit(DetailLoaded(movie));
    } catch (e) {
      emit(DetailError(e.toString()));
    }
  }

  Future<MovieDetailModel> _getMovieDetail(String id) async {
    final http.Response response =
        await service.getMovieDetail(movieId: id);

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
      throw (json['Error'] ?? 'No detail found').toString();
    }

    return MovieDetailModel.fromJson(json);
  }
}