import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas_seminario3raul/models/actor.dart';
import 'package:peliculas_seminario3raul/models/movie.dart';
import 'package:peliculas_seminario3raul/providers/movies_provider.dart';

class ActorScreen extends StatelessWidget {
  const ActorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Actor actor = ModalRoute.of(context)!.settings.arguments as Actor;
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      body: FutureBuilder<ActorDetails?>(
        future: moviesProvider.getActorDetails(actor.id),
        builder: (context, snapshot) {
          final details = snapshot.data;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _ActorAppBar(actor: actor, details: details),
              SliverToBoxAdapter(
                child: snapshot.connectionState == ConnectionState.waiting &&
                        details == null
                    ? const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _ActorBody(actor: actor, details: details),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActorAppBar extends StatelessWidget {
  final Actor actor;
  final ActorDetails? details;

  const _ActorAppBar({required this.actor, this.details});

  @override
  Widget build(BuildContext context) {
    final imagePath = details?.fullProfilePath.isNotEmpty == true
        ? details!.fullProfilePath
        : actor.fullProfilePath;

    return SliverAppBar(
      backgroundColor: Colors.indigo,
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          actor.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: actor.heroTag,
              child: imagePath.isNotEmpty
                  ? FadeInImage(
                      placeholder: const AssetImage('assets/no-image.jpg'),
                      image: NetworkImage(imagePath),
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/no-image.jpg', fit: BoxFit.cover),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.45, 1.0],
                  colors: [
                    Colors.black45,
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorBody extends StatelessWidget {
  final Actor actor;
  final ActorDetails? details;

  const _ActorBody({required this.actor, this.details});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (actor.character.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.theaters, color: Colors.indigo, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'En esta película: ${actor.character}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (details?.knownForDepartment.isNotEmpty == true)
                  _InfoChip(
                    icon: Icons.work_outline,
                    label: details!.knownForDepartment,
                  ),
                if (details?.birthday.isNotEmpty == true)
                  _InfoChip(
                    icon: Icons.cake_outlined,
                    label: details!.age != null
                        ? '${details!.birthday}  (${details!.age} años)'
                        : details!.birthday,
                  ),
                if (details?.placeOfBirth.isNotEmpty == true)
                  _InfoChip(
                    icon: Icons.place_outlined,
                    label: details!.placeOfBirth,
                  ),
                if (details != null)
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: 'Popularidad ${details!.popularity.toStringAsFixed(1)}',
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Biografía',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              (details?.biography.isNotEmpty == true)
                  ? details!.biography
                  : 'No hay biografía disponible en español.',
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
            if (details?.alsoKnownAs.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              const Text(
                'También conocido como',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                details!.alsoKnownAs.take(6).join('  ·  '),
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ],
            const SizedBox(height: 28),
            const Text(
              'Filmografía destacada',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ActorFilmography(actorId: actor.id),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.indigo),
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.indigo.shade100),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

class _ActorFilmography extends StatelessWidget {
  final int actorId;

  const _ActorFilmography({required this.actorId});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder<List<Movie>>(
      future: moviesProvider.getActorMovies(actorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final movies = snapshot.data ?? [];
        if (movies.isEmpty) {
          return const Text('No hay películas disponibles.');
        }

        return SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: movies.length,
            itemBuilder: (_, index) {
              final movie = movies[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 70)),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.85 + (0.15 * value.clamp(0, 1)),
                    child: Opacity(opacity: value.clamp(0, 1), child: child),
                  );
                },
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    'details',
                    arguments: movie,
                  ),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FadeInImage(
                            placeholder: const AssetImage('assets/no-image.jpg'),
                            image: movie.fullPosterPath.isNotEmpty
                                ? NetworkImage(movie.fullPosterPath)
                                    as ImageProvider
                                : const AssetImage('assets/no-image.jpg'),
                            height: 180,
                            width: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
