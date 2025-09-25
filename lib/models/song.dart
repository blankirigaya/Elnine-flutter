// models/song.dart
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String image;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.image,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, artist: $artist, album: $album}';
  }
}

// Extended song model for API data
class ApiSong extends Song {
  final String? audioUrl;
  final String? previewUrl;
  final String? spotifyId;
  final String? artistId;
  final String? albumId;
  final int? popularity;
  final bool isExplicit;
  final List<String> genres;
  final DateTime? releaseDate;

  ApiSong({
    required super.id,
    required super.title,
    required super.artist,
    required super.album,
    required super.duration,
    required super.image,
    this.audioUrl,
    this.previewUrl,
    this.spotifyId,
    this.artistId,
    this.albumId,
    this.popularity,
    this.isExplicit = false,
    this.genres = const [],
    this.releaseDate,
  });

  // Convert to base Song object
  Song toSong() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      image: image,
    );
  }
}