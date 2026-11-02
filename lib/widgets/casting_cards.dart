import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas_seminario3raul/models/actor.dart';
import 'package:peliculas_seminario3raul/providers/movies_provider.dart';

class CastingCards extends StatelessWidget {
  final int movieId;

  const CastingCards({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder<List<Actor>>(
      future: moviesProvider.getMovieCast(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final actors = snapshot.data ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 30),
          width: double.infinity,
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actors.length,
            itemBuilder: (_, index) {
              return _ActorCard(actor: actors[index]);
            },
          ),
        );
      },
    );
  }
}

class _ActorCard extends StatelessWidget {
  final Actor actor;

  const _ActorCard({required this.actor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, 'actor', arguments: actor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 110,
        child: Column(
          children: [
            Hero(
              tag: actor.heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'),
                  image: actor.fullProfilePath.isNotEmpty
                      ? NetworkImage(actor.fullProfilePath) as ImageProvider
                      : const AssetImage('assets/no-image.jpg'),
                  height: 140,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              actor.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              actor.character,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
