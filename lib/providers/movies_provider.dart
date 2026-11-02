import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_seminario3raul/models/actor.dart';
import 'package:peliculas_seminario3raul/models/movie.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = '2d88bd7db1cbafa46649b4069cd2e52b';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Actor>> movieCast = {};
  Map<int, ActorDetails> actorDetails = {};
  Map<int, List<Movie>> actorMovies = {};

  int _popularPage = 0;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<List<Movie>> _getMovies(String endpoint, {Map<String, String>? extraParams}) async {
    final params = {
      'api_key': _apiKey,
      'language': _language,
      ...?extraParams,
    };

    final url = Uri.https(_baseUrl, endpoint, params);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((movie) => Movie.fromJson(movie)).toList();
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return [];
  }

  Future<void> getOnDisplayMovies() async {
    onDisplayMovies = await _getMovies('/3/movie/now_playing');
    notifyListeners();
  }

  Future<void> getPopularMovies() async {
    _popularPage++;
    final newMovies = await _getMovies(
      '/3/movie/popular',
      extraParams: {'page': '$_popularPage'},
    );
    popularMovies = [...popularMovies, ...newMovies];
    notifyListeners();
  }

  Future<List<Movie>> searchMovies(String query) async {
    return await _getMovies('/3/search/movie', extraParams: {'query': query});
  }

  Future<List<Actor>> getMovieCast(int movieId) async {
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;

    final url = Uri.https(_baseUrl, '/3/movie/$movieId/credits', {
      'api_key': _apiKey,
      'language': _language,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List cast = data['cast'] ?? [];
        final actors = cast
            .where((a) => a['profile_path'] != null)
            .take(20)
            .map((a) => Actor.fromJson(a))
            .toList();
        movieCast[movieId] = actors;
        return actors;
      }
    } catch (e) {
      debugPrint('Error cargando cast: $e');
    }
    return [];
  }

  Future<ActorDetails?> getActorDetails(int actorId) async {
    if (actorDetails.containsKey(actorId)) return actorDetails[actorId];

    final url = Uri.https(_baseUrl, '/3/person/$actorId', {
      'api_key': _apiKey,
      'language': _language,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final details = ActorDetails.fromJson(json.decode(response.body));
        actorDetails[actorId] = details;
        return details;
      }
    } catch (e) {
      debugPrint('Error cargando actor: $e');
    }
    return null;
  }

  Future<List<Movie>> getActorMovies(int actorId) async {
    if (actorMovies.containsKey(actorId)) return actorMovies[actorId]!;

    final url = Uri.https(_baseUrl, '/3/person/$actorId/movie_credits', {
      'api_key': _apiKey,
      'language': _language,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List cast = data['cast'] ?? [];
        final movies = cast
            .where((m) => m['poster_path'] != null)
            .map((m) => Movie.fromJson(m))
            .toList()
          ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        final topMovies = movies.take(15).toList();
        actorMovies[actorId] = topMovies;
        return topMovies;
      }
    } catch (e) {
      debugPrint('Error cargando películas del actor: $e');
    }
    return [];
  }
}
