// services/api_config_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiConfig {
  final String? spotifyClientId;
  final String? spotifyClientSecret;
  final String? lastFmApiKey;
  final String? musixmatchApiKey;
  final String? geniusApiKey;
  final String? customLyricsApiUrl;
  final String? customLyricsApiKey;

  ApiConfig({
    this.spotifyClientId,
    this.spotifyClientSecret,
    this.lastFmApiKey,
    this.musixmatchApiKey,
    this.geniusApiKey,
    this.customLyricsApiUrl,
    this.customLyricsApiKey,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      spotifyClientId: json['spotifyClientId'],
      spotifyClientSecret: json['spotifyClientSecret'],
      lastFmApiKey: json['lastFmApiKey'],
      musixmatchApiKey: json['musixmatchApiKey'],
      geniusApiKey: json['geniusApiKey'],
      customLyricsApiUrl: json['customLyricsApiUrl'],
      customLyricsApiKey: json['customLyricsApiKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotifyClientId': spotifyClientId,
      'spotifyClientSecret': spotifyClientSecret,
      'lastFmApiKey': lastFmApiKey,
      'musixmatchApiKey': musixmatchApiKey,
      'geniusApiKey': geniusApiKey,
      'customLyricsApiUrl': customLyricsApiUrl,
      'customLyricsApiKey': customLyricsApiKey,
    };
  }

  bool get hasSpotifyConfig => 
      spotifyClientId != null && 
      spotifyClientId!.isNotEmpty && 
      spotifyClientSecret != null && 
      spotifyClientSecret!.isNotEmpty;

  bool get hasLastFmConfig => 
      lastFmApiKey != null && lastFmApiKey!.isNotEmpty;

  bool get hasMusixmatchConfig => 
      musixmatchApiKey != null && musixmatchApiKey!.isNotEmpty;

  bool get hasGeniusConfig => 
      geniusApiKey != null && geniusApiKey!.isNotEmpty;

  bool get hasCustomLyricsConfig => 
      customLyricsApiUrl != null && 
      customLyricsApiUrl!.isNotEmpty &&
      customLyricsApiKey != null && 
      customLyricsApiKey!.isNotEmpty;
}

class ApiConfigService extends ChangeNotifier {
  static const String _prefsKey = 'api_config';
  
  ApiConfig _config = ApiConfig();
  bool _isConfigured = false;

  ApiConfig get config => _config;
  bool get isConfigured => _isConfigured;

  // Initialize and load saved configuration
  Future<void> initialize() async {
    await _loadConfig();
  }

  // Load configuration from SharedPreferences
  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_prefsKey);
      
      if (configJson != null) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        _config = ApiConfig.fromJson(configMap);
        _isConfigured = _validateConfiguration();
      }
    } catch (e) {
      debugPrint('Error loading API configuration: $e');
    }
    
    notifyListeners();
  }

  // Save configuration to SharedPreferences
  Future<void> saveConfig(ApiConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(config.toJson());
      await prefs.setString(_prefsKey, configJson);
      
      _config = config;
      _isConfigured = _validateConfiguration();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving API configuration: $e');
      rethrow;
    }
  }

  // Clear all configuration
  Future<void> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      _config = ApiConfig();
      _isConfigured = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing API configuration: $e');
    }
  }

  // Validate if we have minimum required configuration
  bool _validateConfiguration() {
    // At minimum, we need either Spotify or Last.fm configuration
    return _config.hasSpotifyConfig || _config.hasLastFmConfig;
  }

  // Get configuration status for UI
  Map<String, bool> getConfigurationStatus() {
    return {
      'spotify': _config.hasSpotifyConfig,
      'lastfm': _config.hasLastFmConfig,
      'musixmatch': _config.hasMusixmatchConfig,
      'genius': _config.hasGeniusConfig,
      'customLyrics': _config.hasCustomLyricsConfig,
    };
  }

  // Get list of available music providers
  List<String> getAvailableMusicProviders() {
    final providers = <String>[];
    
    if (_config.hasSpotifyConfig) providers.add('spotify');
    if (_config.hasLastFmConfig) providers.add('lastfm');
    
    // Always available (no API key required)
    providers.add('deezer');
    
    return providers;
  }

  // Get list of available lyrics providers
  List<String> getAvailableLyricsProviders() {
    final providers = <String>['lyricsovh']; // Free, no API key required
    
    if (_config.hasMusixmatchConfig) providers.add('musixmatch');
    if (_config.hasGeniusConfig) providers.add('genius');
    if (_config.hasCustomLyricsConfig) providers.add('custom');
    
    return providers;
  }
}