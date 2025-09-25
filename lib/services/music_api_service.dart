// services/music_api_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';

// Enhanced Song model with API support
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

  factory ApiSong.fromSpotify(Map<String, dynamic> json) {
    final track = json['track'] ?? json;
    final album = track['album'] ?? {};
    final artists = track['artists'] as List<dynamic>? ?? [];
    final images = album['images'] as List<dynamic>? ?? [];

    return ApiSong(
      id: track['id']?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: track['name'] ?? 'Unknown Title',
      artist: artists.isNotEmpty ? artists[0]['name'] : 'Unknown Artist',
      album: album['name'] ?? 'Unknown Album',
      duration: _formatDuration(track['duration_ms'] ?? 0),
      image: images.isNotEmpty ? images[0]['url'] : '',
      audioUrl: track['preview_url'],
      previewUrl: track['preview_url'],
      spotifyId: track['id'],
      artistId: artists.isNotEmpty ? artists[0]['id'] : null,
      albumId: album['id'],
      popularity: track['popularity'],
      isExplicit: track['explicit'] ?? false,
      genres: [],
    );
  }

  factory ApiSong.fromLastFm(Map<String, dynamic> json) {
    final images = json['image'] as List<dynamic>? ?? [];
    String imageUrl = '';
    
    // Get largest image
    for (var img in images) {
      if (img['size'] == 'extralarge' || img['size'] == 'large') {
        imageUrl = img['#text'] ?? '';
        break;
      }
    }

    return ApiSong(
      id: json['mbid']?.hashCode ?? json['name'].hashCode,
      title: json['name'] ?? 'Unknown Title',
      artist: json['artist']?['name'] ?? json['artist'] ?? 'Unknown Artist',
      album: json['album']?['title'] ?? 'Unknown Album',
      duration: _formatDuration(int.tryParse(json['duration'] ?? '0') ?? 0),
      image: imageUrl,
      previewUrl: json['url'],
    );
  }

  factory ApiSong.fromDeezer(Map<String, dynamic> json) {
    return ApiSong(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist']?['name'] ?? 'Unknown Artist',
      album: json['album']?['title'] ?? 'Unknown Album',
      duration: _formatDuration((json['duration'] ?? 0) * 1000),
      image: json['album']?['cover_xl'] ?? json['artist']?['picture_xl'] ?? '',
      previewUrl: json['preview'],
    );
  }

  static String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}

// Music API Service
class MusicAPIService {
  static const String _spotifyBaseUrl = 'https://api.spotify.com/v1';
  static const String _lastFmBaseUrl = 'https://ws.audioscrobbler.com/2.0/';
  static const String _deezerBaseUrl = 'https://api.deezer.com';
  
  final http.Client _httpClient;
  String? _spotifyToken;
  final String? _lastFmApiKey;
  
  MusicAPIService({
    http.Client? httpClient,
    String? lastFmApiKey,
  }) : _httpClient = httpClient ?? http.Client(),
       _lastFmApiKey = lastFmApiKey;

  // Initialize Spotify client credentials
  Future<bool> initializeSpotify({
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
      final response = await _httpClient.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _spotifyToken = data['access_token'];
        return true;
      }
    } catch (e) {
      debugPrint('Failed to initialize Spotify: $e');
    }
    return false;
  }

  // Search songs across multiple providers
  Future<List<ApiSong>> searchSongs(String query, {
    int limit = 20,
    List<String> providers = const ['spotify', 'lastfm', 'deezer'],
  }) async {
    final List<ApiSong> allSongs = [];

    for (String provider in providers) {
      try {
        List<ApiSong> songs;
        switch (provider) {
          case 'spotify':
            if (_spotifyToken != null) {
              songs = await _searchSpotify(query, limit);
            } else {
              continue;
            }
            break;
          case 'lastfm':
            if (_lastFmApiKey != null) {
              songs = await _searchLastFm(query, limit);
            } else {
              continue;
            }
            break;
          case 'deezer':
            songs = await _searchDeezer(query, limit);
            break;
          default:
            continue;
        }
        allSongs.addAll(songs);
      } catch (e) {
        debugPrint('Error searching $provider: $e');
      }
    }

    // Remove duplicates based on title and artist
    final uniqueSongs = <String, ApiSong>{};
    for (var song in allSongs) {
      final key = '${song.title.toLowerCase()}-${song.artist.toLowerCase()}';
      if (!uniqueSongs.containsKey(key)) {
        uniqueSongs[key] = song;
      }
    }

    return uniqueSongs.values.toList();
  }

  // Spotify search
  Future<List<ApiSong>> _searchSpotify(String query, int limit) async {
    if (_spotifyToken == null) return [];

    final response = await _httpClient.get(
      Uri.parse('$_spotifyBaseUrl/search').replace(queryParameters: {
        'q': query,
        'type': 'track',
        'limit': limit.toString(),
      }),
      headers: {'Authorization': 'Bearer $_spotifyToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List<dynamic>;
      return tracks.map((track) => ApiSong.fromSpotify(track)).toList();
    }

    return [];
  }

  // Last.fm search
  Future<List<ApiSong>> _searchLastFm(String query, int limit) async {
    if (_lastFmApiKey == null) return [];

    final response = await _httpClient.get(
      Uri.parse(_lastFmBaseUrl).replace(queryParameters: {
        'method': 'track.search',
        'track': query,
        'api_key': _lastFmApiKey!,
        'format': 'json',
        'limit': limit.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['results']?['trackmatches']?['track'] as List<dynamic>? ?? [];
      return tracks.map((track) => ApiSong.fromLastFm(track)).toList();
    }

    return [];
  }

  // Deezer search
  Future<List<ApiSong>> _searchDeezer(String query, int limit) async {
    final response = await _httpClient.get(
      Uri.parse('$_deezerBaseUrl/search').replace(queryParameters: {
        'q': query,
        'limit': limit.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['data'] as List<dynamic>? ?? [];
      return tracks.map((track) => ApiSong.fromDeezer(track)).toList();
    }

    return [];
  }

  // Get trending/popular songs
  Future<List<ApiSong>> getTrending({
    String region = 'US',
    int limit = 50,
  }) async {
    if (_spotifyToken == null) {
      // Fallback to Deezer chart
      return _getDeezerChart(limit);
    }

    // Get featured playlists and extract songs
    final response = await _httpClient.get(
      Uri.parse('$_spotifyBaseUrl/browse/featured-playlists').replace(
        queryParameters: {
          'limit': '1',
          'country': region,
        },
      ),
      headers: {'Authorization': 'Bearer $_spotifyToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final playlists = data['playlists']['items'] as List<dynamic>;
      
      if (playlists.isNotEmpty) {
        final playlistId = playlists[0]['id'];
        return getPlaylistTracks(playlistId, limit: limit);
      }
    }

    return _getDeezerChart(limit);
  }

  // Get Deezer chart as fallback
  Future<List<ApiSong>> _getDeezerChart(int limit) async {
    final response = await _httpClient.get(
      Uri.parse('$_deezerBaseUrl/chart/0/tracks').replace(
        queryParameters: {'limit': limit.toString()},
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['data'] as List<dynamic>? ?? [];
      return tracks.map((track) => ApiSong.fromDeezer(track)).toList();
    }

    return [];
  }

  // Get songs from a specific playlist
  Future<List<ApiSong>> getPlaylistTracks(String playlistId, {int limit = 50}) async {
    if (_spotifyToken == null) return [];

    final response = await _httpClient.get(
      Uri.parse('$_spotifyBaseUrl/playlists/$playlistId/tracks').replace(
        queryParameters: {'limit': limit.toString()},
      ),
      headers: {'Authorization': 'Bearer $_spotifyToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;
      return items.map((item) => ApiSong.fromSpotify(item)).toList();
    }

    return [];
  }

  // Get new releases
  Future<List<ApiSong>> getNewReleases({String? country, int limit = 20}) async {
    if (_spotifyToken == null) {
      // Fallback to searching for recent songs
      return searchSongs('new songs 2024', limit: limit);
    }

    final response = await _httpClient.get(
      Uri.parse('$_spotifyBaseUrl/browse/new-releases').replace(
        queryParameters: {
          'limit': limit.toString(),
          if (country != null) 'country': country,
        },
      ),
      headers: {'Authorization': 'Bearer $_spotifyToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final albums = data['albums']['items'] as List<dynamic>;
      
      // Get first track from each album
      final List<ApiSong> songs = [];
      for (var album in albums.take(limit)) {
        final albumTracks = await getAlbumTracks(album['id']);
        if (albumTracks.isNotEmpty) {
          songs.add(albumTracks.first);
        }
      }
      return songs;
    }

    return [];
  }

  // Get album tracks
  Future<List<ApiSong>> getAlbumTracks(String albumId) async {
    if (_spotifyToken == null) return [];

    final response = await _httpClient.get(
      Uri.parse('$_spotifyBaseUrl/albums/$albumId/tracks'),
      headers: {'Authorization': 'Bearer $_spotifyToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['items'] as List<dynamic>;
      return tracks.map((track) => ApiSong.fromSpotify(track)).toList();
    }

    return [];
  }

  // Get recommendations based on seed tracks/artists
  Future<List<ApiSong>> getRecommendations({
    List<String>? seedTracks,
    List<String>? seedArtists,
    List<String>? seedGenres,
    int limit = 20,
  }) async {
    if (_spotifyToken == null) return [];

    final params = <String, String>{
      'limit': limit.toString(),
    };

    if (seedTracks != null && seedTracks.isNotEmpty) {
      params['seed_tracks'] = seedTracks.take(5).join(',');
    }
    if (seedArtists != null && seedArtists.isNotEmpty) {
      params['seed_artists'] = seedArtists.take(5).join(',');
    }
    if (seedGenres != null && seedGenres.isNotEmpty) {
      params['seed_genres'] = seedGenres.take(5).join(',');
    }

    final response = await _httpClient.get(
      Uri.parse('$_spotifyBaseUrl/recommendations').replace(queryParameters: params),
      headers: {'Authorization': 'Bearer $_spotifyToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks'] as List<dynamic>;
      return tracks.map((track) => ApiSong.fromSpotify(track)).toList();
    }

    return [];
  }

  void dispose() {
    _httpClient.close();
  }
}