// services/audio_player_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

enum PlaybackState { stopped, playing, paused, buffering, error }
enum RepeatMode { off, all, one }

class AudioPlayerService extends ChangeNotifier {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Current playback state
  PlaybackState _playbackState = PlaybackState.stopped;
  Song? _currentSong;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 0.7;
  bool _isShuffled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  
  // Playlist management
  List<Song> _playlist = [];
  int _currentIndex = 0;
  List<int> _shuffledIndexes = [];
  int _shuffledCurrentIndex = 0;

  // Stream subscriptions
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  // Getters
  PlaybackState get playbackState => _playbackState;
  Song? get currentSong => _currentSong;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  bool get isShuffled => _isShuffled;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get playlist => _playlist;
  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get isPaused => _playbackState == PlaybackState.paused;
  bool get isStopped => _playbackState == PlaybackState.stopped;
  bool get isBuffering => _playbackState == PlaybackState.buffering;
  
  // Progress as percentage (0-100)
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds) * 100;
  }

  // Current position as seconds
  int get currentPositionSeconds => _currentPosition.inSeconds;

  // Total duration as seconds
  int get totalDurationSeconds => _totalDuration.inSeconds;

  // Initialize the audio player service
  Future<void> initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _setupListeners();
  }

  // Setup audio player listeners
  void _setupListeners() {
    // Position updates
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Duration updates
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    // Player state changes
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.stopped:
          _playbackState = PlaybackState.stopped;
          _currentPosition = Duration.zero;
          break;
        case PlayerState.playing:
          _playbackState = PlaybackState.playing;
          break;
        case PlayerState.paused:
          _playbackState = PlaybackState.paused;
          break;
        case PlayerState.completed:
          _handleSongComplete();
          break;
        case PlayerState.disposed:
          _playbackState = PlaybackState.stopped;
          break;
      }
      notifyListeners();
    });

    // Handle player completion
    _audioPlayer.onPlayerComplete.listen((event) {
      _handleSongComplete();
    });
  }

  // Play a specific song
  Future<void> playSong(Song song, {List<Song>? newPlaylist, int? startIndex}) async {
    try {
      _playbackState = PlaybackState.buffering;
      notifyListeners();

      // Update playlist if provided
      if (newPlaylist != null) {
        _playlist = newPlaylist;
        _currentIndex = startIndex ?? 0;
        _generateShuffledIndexes();
      } else if (_currentSong?.id != song.id) {
        // Find song in current playlist or create new playlist
        final songIndex = _playlist.indexWhere((s) => s.id == song.id);
        if (songIndex != -1) {
          _currentIndex = songIndex;
        } else {
          _playlist = [song];
          _currentIndex = 0;
          _generateShuffledIndexes();
        }
      }

      _currentSong = song;

      // Get audio URL for the song
      final audioUrl = _getAudioUrl(song);
      
      if (audioUrl.isNotEmpty) {
        if (audioUrl.startsWith('http')) {
          await _audioPlayer.play(UrlSource(audioUrl));
        } else {
          await _audioPlayer.play(AssetSource(audioUrl));
        }
      } else {
        throw Exception('No audio URL available for this song');
      }
      
    } catch (e) {
      _playbackState = PlaybackState.error;
      notifyListeners();
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_playbackState == PlaybackState.playing) {
      await pause();
    } else if (_playbackState == PlaybackState.paused) {
      await resume();
    } else if (_currentSong != null) {
      await playSong(_currentSong!);
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume playback
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  // Seek to position (0.0 - 1.0)
  Future<void> seekToPercentage(double percentage) async {
    if (_totalDuration.inMilliseconds > 0) {
      final position = Duration(
        milliseconds: (_totalDuration.inMilliseconds * percentage).round(),
      );
      await _audioPlayer.seek(position);
    }
  }

  // Seek to specific duration
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  // Play next song
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    int nextIndex;
    if (_isShuffled) {
      nextIndex = (_shuffledCurrentIndex + 1) % _shuffledIndexes.length;
      _shuffledCurrentIndex = nextIndex;
      _currentIndex = _shuffledIndexes[nextIndex];
    } else {
      nextIndex = (_currentIndex + 1) % _playlist.length;
      _currentIndex = nextIndex;
    }

    await playSong(_playlist[_currentIndex]);
  }

  // Play previous song
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    // If more than 3 seconds into song, restart current song
    if (_currentPosition.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }

    int previousIndex;
    if (_isShuffled) {
      previousIndex = (_shuffledCurrentIndex - 1) % _shuffledIndexes.length;
      if (previousIndex < 0) previousIndex = _shuffledIndexes.length - 1;
      _shuffledCurrentIndex = previousIndex;
      _currentIndex = _shuffledIndexes[previousIndex];
    } else {
      previousIndex = (_currentIndex - 1) % _playlist.length;
      if (previousIndex < 0) previousIndex = _playlist.length - 1;
      _currentIndex = previousIndex;
    }

    await playSong(_playlist[_currentIndex]);
  }

  // Toggle shuffle mode
  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _generateShuffledIndexes();
      // Find current song in shuffled list
      _shuffledCurrentIndex = _shuffledIndexes.indexOf(_currentIndex);
    }
    notifyListeners();
  }

  // Toggle repeat mode
  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // Set repeat mode directly
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  // Handle song completion
  void _handleSongComplete() {
    switch (_repeatMode) {
      case RepeatMode.one:
        // Repeat current song
        seekTo(Duration.zero);
        resume();
        break;
      case RepeatMode.all:
        // Play next song, loop to beginning if at end
        playNext();
        break;
      case RepeatMode.off:
        // Play next song if available, otherwise stop
        if (_isShuffled) {
          if (_shuffledCurrentIndex < _shuffledIndexes.length - 1) {
            playNext();
          } else {
            stop();
          }
        } else {
          if (_currentIndex < _playlist.length - 1) {
            playNext();
          } else {
            stop();
          }
        }
        break;
    }
  }

  // Generate shuffled indexes for playlist
  void _generateShuffledIndexes() {
    _shuffledIndexes = List.generate(_playlist.length, (index) => index);
    _shuffledIndexes.shuffle();
    _shuffledCurrentIndex = 0;
  }

  // Get audio URL for a song
  String _getAudioUrl(Song song) {
    // If it's an ApiSong with audio URL, use that
    if (song is ApiSong && song.audioUrl != null) {
      return song.audioUrl!;
    }
    
    // If it's an ApiSong with preview URL, use that
    if (song is ApiSong && song.previewUrl != null) {
      return song.previewUrl!;
    }
    
    // For demo purposes, return sample audio URLs
    // In production, you would have your own audio hosting or use song streaming APIs
    const sampleUrls = [
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    ];
    
    // Return a sample URL based on song ID for demo
    return sampleUrls[song.id.abs() % sampleUrls.length];
  }

  // Add song to playlist
  void addToPlaylist(Song song) {
    if (!_playlist.any((s) => s.id == song.id)) {
      _playlist.add(song);
      _generateShuffledIndexes();
      notifyListeners();
    }
  }

  // Remove song from playlist
  void removeFromPlaylist(Song song) {
    final index = _playlist.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _playlist.removeAt(index);
      if (_currentIndex >= index && _currentIndex > 0) {
        _currentIndex--;
      }
      _generateShuffledIndexes();
      notifyListeners();
    }
  }

  // Clear playlist
  void clearPlaylist() {
    stop();
    _playlist.clear();
    _currentIndex = 0;
    _shuffledIndexes.clear();
    _shuffledCurrentIndex = 0;
    _currentSong = null;
    notifyListeners();
  }

  // Format duration to string (MM:SS)
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Dispose of resources
  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}