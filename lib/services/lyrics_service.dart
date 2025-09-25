// services/lyrics_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  bool isActiveAt(int currentTimeMs) {
    return currentTimeMs >= startTimeMs && currentTimeMs < endTimeMs;
  }

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
}

class SongLyrics {
  final int songId;
  final List<LyricLine> lines;
  final String title;
  final String artist;
  final String? language;
  final String? source;

  SongLyrics({
    required this.songId,
    required this.lines,
    required this.title,
    required this.artist,
    this.language,
    this.source,
  });

  factory SongLyrics.fromJson(Map<String, dynamic> json) {
    return SongLyrics(
      songId: json['songId'] ?? 0,
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      language: json['language'],
      source: json['source'],
      lines: (json['lines'] as List<dynamic>?)
              ?.map((line) => LyricLine.fromJson(line))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'title': title,
      'artist': artist,
      'language': language,
      'source': source,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}

abstract class LyricsApi {
  Future<SongLyrics?> fetchLyrics(Song song);
  Future<List<SongLyrics>> searchLyrics(String query);
}

// Default implementation for lyrics.ovh (free API)
class DefaultLyricsApi implements LyricsApi {
  final String baseUrl;
  final String? apiKey;
  final http.Client httpClient;

  DefaultLyricsApi({
    required this.baseUrl,
    this.apiKey,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  @override
  Future<SongLyrics?> fetchLyrics(Song song) async {
    try {
      // lyrics.ovh format: https://api.lyrics.ovh/v1/{artist}/{title}
      final artist = Uri.encodeComponent(song.artist);
      final title = Uri.encodeComponent(song.title);
      final url = '$baseUrl/$artist/$title';

      final response = await httpClient.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lyricsText = data['lyrics'] as String?;
        
        if (lyricsText != null && lyricsText.isNotEmpty) {
          return _convertPlainTextToTimedLyrics(song, lyricsText);
        }
      } else if (response.statusCode == 404) {
        debugPrint('Lyrics not found for ${song.title} by ${song.artist}');
        return null;
      } else {
        debugPrint('Failed to fetch lyrics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching lyrics: $e');
      return null;
    }
    return null;
  }

  @override
  Future<List<SongLyrics>> searchLyrics(String query) async {
    // lyrics.ovh doesn't support search, so return empty list
    return [];
  }

  SongLyrics _convertPlainTextToTimedLyrics(Song song, String lyricsText) {
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
      source: 'lyrics.ovh',
    );
  }

  bool _detectChorus(String line, List<String> allLines) {
    int occurrences = 0;
    final cleanLine = line.toLowerCase().trim();
    
    for (String otherLine in allLines) {
      if (otherLine.toLowerCase().trim() == cleanLine) {
        occurrences++;
      }
    }
    
    return occurrences > 1;
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 180; // Default 3 minutes
  }
}

class LyricsService extends ChangeNotifier {
  static final LyricsService _instance = LyricsService._internal();
  factory LyricsService() => _instance;
  LyricsService._internal();

  final Map<int, SongLyrics> _lyricsCache = {};
  SongLyrics? _currentLyrics;
  int _currentTimeMs = 0;
  int _activeLyricIndex = -1;
  
  // API configuration
  LyricsApi? _lyricsApi;
  bool _useCache = true;

  // Getters
  SongLyrics? get currentLyrics => _currentLyrics;
  int get activeLyricIndex => _activeLyricIndex;
  bool get hasLyrics => _currentLyrics?.lines.isNotEmpty ?? false;

  // Configure the lyrics API
  void configure({
    required LyricsApi lyricsApi,
    bool useCache = true,
  }) {
    _lyricsApi = lyricsApi;
    _useCache = useCache;
  }

  // Load lyrics for a song
  Future<SongLyrics?> loadLyrics(Song song) async {
    // Check cache first
    if (_useCache && _lyricsCache.containsKey(song.id)) {
      _currentLyrics = _lyricsCache[song.id];
      notifyListeners();
      return _currentLyrics;
    }

    // Fetch from API
    if (_lyricsApi != null) {
      try {
        final lyrics = await _lyricsApi!.fetchLyrics(song);
        if (lyrics != null) {
          if (_useCache) {
            _lyricsCache[song.id] = lyrics;
          }
          _currentLyrics = lyrics;
          _activeLyricIndex = -1;
          notifyListeners();
          return lyrics;
        }
      } catch (e) {
        debugPrint('Failed to fetch lyrics from API: $e');
      }
    }

    // Fallback to demo lyrics if API fails
    final demoLyrics = _generateDemoLyrics(song);
    _currentLyrics = demoLyrics;
    _activeLyricIndex = -1;
    notifyListeners();
    return demoLyrics;
  }

  // Update current playback time and find active lyric
  void updateTime(int timeMs) {
    _currentTimeMs = timeMs;

    if (_currentLyrics != null && _currentLyrics!.lines.isNotEmpty) {
      int newActiveLyricIndex = -1;

      for (int i = 0; i < _currentLyrics!.lines.length; i++) {
        if (_currentLyrics!.lines[i].isActiveAt(timeMs)) {
          newActiveLyricIndex = i;
          break;
        }
      }

      if (newActiveLyricIndex != _activeLyricIndex) {
        _activeLyricIndex = newActiveLyricIndex;
        notifyListeners();
      }
    }
  }

  // Get the currently active lyric line
  LyricLine? get activeLyricLine {
    if (_currentLyrics != null &&
        _activeLyricIndex >= 0 &&
        _activeLyricIndex < _currentLyrics!.lines.length) {
      return _currentLyrics!.lines[_activeLyricIndex];
    }
    return null;
  }

  // Clear current lyrics
  void clearLyrics() {
    _currentLyrics = null;
    _activeLyricIndex = -1;
    _currentTimeMs = 0;
    notifyListeners();
  }

  // Clear cache
  void clearCache() {
    _lyricsCache.clear();
    notifyListeners();
  }

  // Generate demo lyrics (fallback when API fails)
  SongLyrics _generateDemoLyrics(Song song) {
    final lines = _generateGenericLyrics();
    final songDurationMs = _parseDuration(song.duration) * 1000;
    final timePerLine = songDurationMs ~/ lines.length;

    final lyricLines = <LyricLine>[];
    for (int i = 0; i < lines.length; i++) {
      final startTime = i * timePerLine;
      final endTime = (i + 1) * timePerLine;
      final isChorus = (i ~/ 4) % 2 == 1; // Every other verse is chorus

      lyricLines.add(LyricLine(
        startTimeMs: startTime,
        endTimeMs: endTime,
        text: lines[i],
        isChorus: isChorus,
      ));
    }

    return SongLyrics(
      songId: song.id,
      title: song.title,
      artist: song.artist,
      lines: lyricLines,
      source: 'Demo',
    );
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 180; // Default 3 minutes
  }

  List<String> _generateGenericLyrics() {
    return [
      // Verse 1
      "Walking down this empty street tonight",
      "Stars are shining oh so bright",
      "Feeling like I'm finally free",
      "This is where I'm meant to be",

      // Chorus
      "Dancing through the night away",
      "Music takes my breath away",
      "Nothing else matters right now",
      "Living in this moment somehow",

      // Verse 2
      "Memories fade but dreams remain",
      "Sunshine follows after rain",
      "Every step a new beginning",
      "Feel my heart inside me singing",

      // Chorus
      "Dancing through the night away",
      "Music takes my breath away",
      "Nothing else matters right now",
      "Living in this moment somehow",

      // Bridge
      "Time stands still when music plays",
      "Lost inside these melodies",
      "Every note a story told",
      "Young at heart but feeling old",

      // Final Chorus
      "Dancing through the night away",
      "Music takes my breath away",
      "Nothing else matters right now",
      "Living in this moment somehow",
    ];
  }
}