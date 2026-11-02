import 'package:flutter/material.dart';
import 'package:peliculas_seminario3raul/models/movie.dart';
import 'package:peliculas_seminario3raul/providers/movies_provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  final MoviesProvider moviesProvider;
  MovieSearchDelegate({required this.moviesProvider})
      : super(searchFieldLabel: 'Buscar película...');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 100, color: Colors.black38),
            SizedBox(height: 20),
            Text('Busca una película', style: TextStyle(color: Colors.black38, fontSize: 18)),
          ],
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Movie>>(
      future: moviesProvider.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return const Center(
            child: Text('No se encontraron resultados'),
          );
        }

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'),
                  image: movie.fullPosterPath.isNotEmpty
                      ? NetworkImage(movie.fullPosterPath) as ImageProvider
                      : const AssetImage('assets/no-image.jpg'),
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(movie.title),
              subtitle: Text(
                movie.overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                close(context, null);
                Navigator.pushNamed(context, 'details', arguments: movie);
              },
            );
          },
        );
      },
    );
  }
}
