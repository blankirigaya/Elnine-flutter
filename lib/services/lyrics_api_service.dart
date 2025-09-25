import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/song.dart';

class LyricLine {
  final int startTimeMs;
  final int endTimeMs;
  final String text;
  final bool isChorus;

  LyricLine({
    required this.startTimeMs,
    required this.endTimeMs,
    required this.text,
    this.isChorus = false,
  });

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      startTimeMs: json['startTimeMs'] ?? 0,
      endTimeMs: json['endTimeMs'] ?? 0,
      text: json['text'] ?? '',
      isChorus: json['isChorus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTimeMs': startTimeMs,
      'endTimeMs': endTimeMs,
      'text': text,
      'isChorus': isChorus,
    };
  }

  bool isActiveAt(int currentTimeMs) {
    return currentTimeMs >= startTimeMs && currentTimeMs < endTimeMs;
  }
}

class SongLyrics {
  final int songId;
  final List<LyricLine> lines;
  final String title;
  final String artist;
  final bool isSynced; // Whether lyrics have timing information

  SongLyrics({
    required this.songId,
    required this.lines,
    required this.title,
    required this.artist,
    this.isSynced = true,
  });

  factory SongLyrics.fromJson(Map<String, dynamic> json) {
    return SongLyrics(
      songId: json['songId'] ?? 0,
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      isSynced: json['isSynced'] ?? true,
      lines: (json['lines'] as List<dynamic>?)
          ?.map((line) => LyricLine.fromJson(line))
          .toList() ?? [],
    );
  }
}

enum LyricsProvider { musixmatch, genius, lyricsovh, custom }

class LyricsAPIService {
  static const String _musixmatchBaseUrl = 'https://api.musixmatch.com/ws/1.1';
  static const String _geniusBaseUrl = 'https://api.genius.com';
  static const String _lyricsOvhBaseUrl = 'https://api.lyrics.ovh/v1';
  
  // Add your API keys here
  static const String _musixmatchApiKey = 'YOUR_MUSIXMATCH_API_KEY';
  static const String _geniusApiKey = 'YOUR_GENIUS_API_KEY';
  
  // Custom API configuration
  static const String _customApiBaseUrl = 'YOUR_CUSTOM_API_URL';
  static const String _customApiKey = 'YOUR_CUSTOM_API_KEY';

  static Future<SongLyrics?> fetchLyrics(
    Song song, {
    LyricsProvider provider = LyricsProvider.lyricsovh,
  }) async {
    try {
      switch (provider) {
        case LyricsProvider.musixmatch:
          return await _fetchFromMusixmatch(song);
        case LyricsProvider.genius:
          return await _fetchFromGenius(song);
        case LyricsProvider.lyricsovh:
          return await _fetchFromLyricsOvh(song);
        case LyricsProvider.custom:
          return await _fetchFromCustomAPI(song);
      }
    } catch (e) {
      debugPrint('Error fetching lyrics from $provider: $e');
      return null;
    }
  }

  // Lyrics.ovh API (Free, no API key required, but no timing)
  static Future<SongLyrics?> _fetchFromLyricsOvh(Song song) async {
    final artist = Uri.encodeComponent(song.artist);
    final title = Uri.encodeComponent(song.title);
    final url = '$_lyricsOvhBaseUrl/$artist/$title';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final lyricsText = data['lyrics'] as String?;

      if (lyricsText != null && lyricsText.isNotEmpty) {
        return _convertPlainTextToTimedLyrics(song, lyricsText);
      }
    }
    return null;
  }

  // Musixmatch API (Requires API key, has timing data)
  static Future<SongLyrics?> _fetchFromMusixmatch(Song song) async {
    if (_musixmatchApiKey == 'YOUR_MUSIXMATCH_API_KEY') {
      debugPrint('Please add your Musixmatch API key');
      return null;
    }

    // First, search for the track
    final searchUrl = '$_musixmatchBaseUrl/track.search'
        '?apikey=$_musixmatchApiKey'
        '&q_track=${Uri.encodeComponent(song.title)}'
        '&q_artist=${Uri.encodeComponent(song.artist)}'
        '&page_size=1';

    final searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode == 200) {
      final searchData = json.decode(searchResponse.body);
      final trackList = searchData['message']?['body']?['track_list'];

      if (trackList != null && trackList.isNotEmpty) {
        final trackId = trackList[0]['track']['track_id'];

        // Get lyrics
        final lyricsUrl = '$_musixmatchBaseUrl/track.lyrics.get'
            '?apikey=$_musixmatchApiKey'
            '&track_id=$trackId';

        final lyricsResponse = await http.get(Uri.parse(lyricsUrl));

        if (lyricsResponse.statusCode == 200) {
          final lyricsData = json.decode(lyricsResponse.body);
          final lyricsBody = lyricsData['message']?['body']?['lyrics']?['lyrics_body'];

          if (lyricsBody != null) {
            return _convertPlainTextToTimedLyrics(song, lyricsBody);
          }
        }
      }
    }
    return null;
  }

  // Genius API (Requires API key, no timing data)
  static Future<SongLyrics?> _fetchFromGenius(Song song) async {
    if (_geniusApiKey == 'YOUR_GENIUS_API_KEY') {
      debugPrint('Please add your Genius API key');
      return null;
    }

    final searchUrl = '$_geniusBaseUrl/search'
        '?q=${Uri.encodeComponent('${song.artist} ${song.title}')}';

    final response = await http.get(
      Uri.parse(searchUrl),
      headers: {'Authorization': 'Bearer $_geniusApiKey'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['response']?['hits'];

      if (hits != null && hits.isNotEmpty) {
        // Note: Genius API doesn't provide lyrics directly due to licensing
        // You would need to scrape the lyrics from the URL or use a different approach
        // This is a placeholder implementation
        return _generateFallbackLyrics(song);
      }
    }
    return null;
  }

  // Custom API implementation
  static Future<SongLyrics?> _fetchFromCustomAPI(Song song) async {
    final url = '$_customApiBaseUrl/lyrics'
        '?artist=${Uri.encodeComponent(song.artist)}'
        '&title=${Uri.encodeComponent(song.title)}';

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_customApiKey != 'YOUR_CUSTOM_API_KEY') {
      headers['Authorization'] = 'Bearer $_customApiKey';
    }

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SongLyrics.fromJson(data);
    }
    return null;
  }

  // Convert plain text lyrics to timed lyrics (estimated timing)
  static SongLyrics _convertPlainTextToTimedLyrics(Song song, String lyricsText) {
    final lines = lyricsText
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    // Estimate timing based on song duration
    final songDurationMs = _parseDuration(song.duration) * 1000;
    final timePerLine = songDurationMs / lines.length;

    final lyricLines = <LyricLine>[];
    
    for (int i = 0; i < lines.length; i++) {
      final startTime = (i * timePerLine).round();
      final endTime = ((i + 1) * timePerLine).round();
      
      // Simple chorus detection (lines that repeat)
      final isChorus = _detectChorus(lines[i], lines);
      
      lyricLines.add(LyricLine(
        startTimeMs: startTime,
        endTimeMs: endTime,
        text: lines[i].trim(),
        isChorus: isChorus,
      ));
    }

    return SongLyrics(
      songId: song.id,
      title: song.title,
      artist: song.artist,
      lines: lyricLines,
      isSynced: false, // Estimated timing
    );
  }

  // Simple chorus detection
  static bool _detectChorus(String line, List<String> allLines) {
    int occurrences = 0;
    final cleanLine = line.toLowerCase().trim();
    
    for (String otherLine in allLines) {
      if (otherLine.toLowerCase().trim() == cleanLine) {
        occurrences++;
      }
    }
    
    return occurrences > 1; // Line appears more than once
  }

  // Parse duration string (e.g., "3:45") to seconds
  static int _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 180; // Default 3 minutes
  }

  // Fallback lyrics when API fails
  static SongLyrics _generateFallbackLyrics(Song song) {
    final fallbackLines = [
      'Lyrics not available',
      'Please check your internet connection',
      'or try again later',
    ];

    final lyricLines = fallbackLines.asMap().entries.map((entry) {
      return LyricLine(
        startTimeMs: entry.key * 2000,
        endTimeMs: (entry.key + 1) * 2000,
        text: entry.value,
        isChorus: false,
      );
    }).toList();

    return SongLyrics(
      songId: song.id,
      title: song.title,
      artist: song.artist,
      lines: lyricLines,
      isSynced: false,
    );
  }

  // Batch fetch lyrics for multiple songs
  static Future<Map<int, SongLyrics>> fetchBatchLyrics(
    List<Song> songs, {
    LyricsProvider provider = LyricsProvider.lyricsovh,
    int delayBetweenRequestsMs = 1000, // Rate limiting
  }) async {
    final results = <int, SongLyrics>{};
    
    for (Song song in songs) {
      try {
        final lyrics = await fetchLyrics(song, provider: provider);
        if (lyrics != null) {
          results[song.id] = lyrics;
        }
        
        // Rate limiting - wait between requests
        if (delayBetweenRequestsMs > 0) {
          await Future.delayed(Duration(milliseconds: delayBetweenRequestsMs));
        }
      } catch (e) {
        debugPrint('Error fetching lyrics for ${song.title}: $e');
      }
    }
    
    return results;
  }
}