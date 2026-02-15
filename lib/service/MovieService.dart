import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieService {
  static const String baseUrl = "https://www.omdbapi.com/";
  static const String favKey = "fav_movies";

  String get apiKey {
    return dotenv.get("OMDB_KEY", fallback: "").trim();
  }

  bool get hasKey {
    return apiKey.isNotEmpty;
  }

  Future<http.Response> getRequest({
    required Map<String, dynamic> query,
  }) {
    final uri = Uri.https('www.omdbapi.com', '/', {
      for (final entry in query.entries)
        entry.key: entry.value?.toString() ?? '',
    });

    return http.get(uri);
  }

  /// search movie list
  Future<http.Response> searchMovie({
    required String text,
    String page = "1",
    String? type,
    String? year,
  }) async {
    final queryParam = <String, dynamic>{
      "apikey": apiKey,
      "s": text,
      "page": page,
    };

    final t = (type ?? '').trim();
    if (t.isNotEmpty) {
      queryParam['type'] = t;
    }

    final y = (year ?? '').trim();
    if (y.isNotEmpty) {
      queryParam['y'] = y;
    }

    return getRequest(query: queryParam);
  }

  /// get single movie detail
  Future<http.Response> getMovieDetail({
    required String movieId,
  }) async {
    final queryParam = <String, dynamic>{
      "apikey": apiKey,
      "i": movieId,
      "plot": "full",
    };

    return getRequest(query: queryParam);
  }

  /// get fav list
  Future<List<String>> getFavMovieStrings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getStringList(favKey) ?? [];
  }

  /// save fav list
  Future<void> saveFavMovieStrings(List<String> list) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList(favKey, list);
  }

  /// clear fav list
  Future<void> clearFavMovie() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(favKey);
  }
}