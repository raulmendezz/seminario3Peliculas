class Actor {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  Actor({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }

  String get heroTag => 'actor-$id';

  String get fullProfilePath {
    if (profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$profilePath';
  }
}

class ActorDetails {
  final int id;
  final String name;
  final String biography;
  final String birthday;
  final String deathday;
  final String placeOfBirth;
  final String knownForDepartment;
  final double popularity;
  final String profilePath;
  final List<String> alsoKnownAs;

  ActorDetails({
    required this.id,
    required this.name,
    required this.biography,
    required this.birthday,
    required this.deathday,
    required this.placeOfBirth,
    required this.knownForDepartment,
    required this.popularity,
    required this.profilePath,
    required this.alsoKnownAs,
  });

  factory ActorDetails.fromJson(Map<String, dynamic> json) {
    return ActorDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      biography: json['biography'] ?? '',
      birthday: json['birthday'] ?? '',
      deathday: json['deathday'] ?? '',
      placeOfBirth: json['place_of_birth'] ?? '',
      knownForDepartment: json['known_for_department'] ?? '',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      profilePath: json['profile_path'] ?? '',
      alsoKnownAs: List<String>.from(json['also_known_as'] ?? []),
    );
  }

  String get fullProfilePath {
    if (profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$profilePath';
  }

  int? get age {
    if (birthday.isEmpty) return null;
    final birth = DateTime.tryParse(birthday);
    if (birth == null) return null;
    final end = deathday.isNotEmpty
        ? DateTime.tryParse(deathday) ?? DateTime.now()
        : DateTime.now();
    var years = end.year - birth.year;
    if (end.month < birth.month ||
        (end.month == birth.month && end.day < birth.day)) {
      years--;
    }
    return years;
  }
}
