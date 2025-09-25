import 'song.dart';

class Album {
  final String id;
  final String title;
  final String artist;
  final String coverImage;
  final int year;
  final List<Song> songs;
  final String genre;
  final int duration; // Total duration in seconds
  
  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImage,
    required this.year,
    required this.songs,
    required this.genre,
    required this.duration,
  });

  // Calculate total duration from songs
  int get totalDuration {
    return songs.fold(0, (sum, song) => sum + _parseDuration(song.duration));
  }

  // Get formatted duration string
  String get formattedDuration {
    final minutes = totalDuration ~/ 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  // Parse duration string to seconds
  static int _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 0;
  }

  // Create album from API response
  factory Album.fromSpotify(Map<String, dynamic> json, List<Song> albumSongs) {
    final images = json['images'] as List<dynamic>? ?? [];
    String coverImage = '';
    
    if (images.isNotEmpty) {
      coverImage = images[0]['url'] ?? '';
    }

    return Album(
      id: json['id'] ?? '',
      title: json['name'] ?? 'Unknown Album',
      artist: json['artists']?.isNotEmpty == true 
          ? json['artists'][0]['name'] 
          : 'Unknown Artist',
      coverImage: coverImage,
      year: json['release_date'] != null 
          ? int.tryParse(json['release_date'].substring(0, 4)) ?? 0
          : 0,
      songs: albumSongs,
      genre: json['genres']?.isNotEmpty == true 
          ? json['genres'][0] 
          : 'Unknown',
      duration: 0, // Will be calculated from songs
    );
  }

  // Create from sample data
  factory Album.fromSongs({
    required String id,
    required String title,
    required String artist,
    required List<Song> songs,
    String? coverImage,
    int? year,
    String? genre,
  }) {
    return Album(
      id: id,
      title: title,
      artist: artist,
      coverImage: coverImage ?? (songs.isNotEmpty ? songs.first.image : ''),
      year: year ?? DateTime.now().year,
      songs: songs,
      genre: genre ?? 'Pop',
      duration: 0, // Will be calculated
    );
  }
}