// main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart' hide ApiSong;
import 'models/album.dart';
import 'models/playlist.dart';
import 'models/genre.dart';
import 'screens/home_content.dart';
import 'screens/search_content.dart';
import 'screens/library_content.dart';
import 'screens/profile_content.dart';
import 'widgets/mini_player.dart';
import 'widgets/full_player.dart';
import 'widgets/side_menu.dart';
import 'services/audio_player_service.dart';
import 'services/lyrics_service.dart';
import 'services/music_api_service.dart';
import 'services/api_config_service.dart';
import 'utils/sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final apiConfigService = ApiConfigService();
  await apiConfigService.initialize();
  
  final audioService = AudioPlayerService();
  await audioService.initialize();
  
  final lyricsService = LyricsService();
  lyricsService.configure(
    lyricsApi: DefaultLyricsApi(
      baseUrl: 'https://api.lyrics.ovh/v1',
    ),
  );

  runApp(ElnineApp(
    apiConfigService: apiConfigService,
    audioService: audioService,
    lyricsService: lyricsService,
  ));
}

class ElnineApp extends StatelessWidget {
  final ApiConfigService apiConfigService;
  final AudioPlayerService audioService;
  final LyricsService lyricsService;

  const ElnineApp({
    Key? key,
    required this.apiConfigService,
    required this.audioService,
    required this.lyricsService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: apiConfigService),
        ChangeNotifierProvider.value(value: audioService),
        ChangeNotifierProvider.value(value: lyricsService),
        ProxyProvider<ApiConfigService, MusicAPIService>(
          update: (context, config, previous) {
            final musicApi = MusicAPIService(
              lastFmApiKey: config.config.lastFmApiKey,
            );
            
            // Initialize Spotify if configured
            if (config.config.hasSpotifyConfig) {
              musicApi.initializeSpotify(
                clientId: config.config.spotifyClientId!,
                clientSecret: config.config.spotifyClientSecret!,
              );
            }
            
            return musicApi;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Elnine',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFFbe29ec, {
            50: Color(0xFFF8E8FD),
            100: Color(0xFFEEC5FA),
            200: Color(0xFFE29FF7),
            300: Color(0xFFD578F3),
            400: Color(0xFFCC5CF0),
            500: Color(0xFFbe29ec),
            600: Color(0xFFA825D3),
            700: Color(0xFF8E1FB8),
            800: Color(0xFF75199D),
            900: Color(0xFF4F1074),
          }),
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
        ),
        home: ElnineHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ElnineHomePage extends StatefulWidget {
  @override
  _ElnineHomePageState createState() => _ElnineHomePageState();
}

class _ElnineHomePageState extends State<ElnineHomePage>
    with TickerProviderStateMixin {
  int activeTab = 0;
  String searchQuery = '';
  bool showFullPlayer = false;
  Set<int> likedSongs = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // API-loaded music data
  List<ApiSong> songs = [];
  List<ApiSong> trendingSongs = [];
  List<ApiSong> newReleases = [];
  List<Album> albums = []; // New albums list
  List<Album> forYouAlbums = []; // Albums for "For You" section
  List<Playlist> playlists = [];
  List<Genre> genres = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAudioPlayerListener();
  }

  void _setupAudioPlayerListener() {
    final audioService = context.read<AudioPlayerService>();
    audioService.addListener(() {
      // Update lyrics service with current playback time
      if (audioService.currentSong != null) {
        context.read<LyricsService>().updateTime(
          audioService.currentPositionSeconds * 1000,
        );
      }
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final musicApiService = context.read<MusicAPIService>();

      // Try to load data from APIs
      final List<Future> futures = [
        musicApiService.getTrending(limit: 20),
        musicApiService.getNewReleases(limit: 15),
        musicApiService.searchSongs('popular music', limit: 30),
      ];

      final results = await Future.wait(futures, eagerError: false);
      
      final trending = results[0] as List<ApiSong>? ?? [];
      final releases = results[1] as List<ApiSong>? ?? [];
      final searchResults = results[2] as List<ApiSong>? ?? [];

      setState(() {
        trendingSongs = trending;
        newReleases = releases;
        songs = [...trending, ...releases, ...searchResults];
        
        // If no API data, fall back to sample data
        if (songs.isEmpty) {
          _loadSampleData();
        } else {
          _createAlbumsFromSongs();
          _updateLegacyData();
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load music: $e';
        isLoading = false;
        _loadSampleData();
      });
    }
  }

  void _createAlbumsFromSongs() {
    // Group songs by artist to create albums
    final Map<String, List<ApiSong>> artistGroups = {};
    
    for (final song in songs) {
      artistGroups.putIfAbsent(song.artist, () => []).add(song);
    }

    final List<Album> generatedAlbums = [];
    
    artistGroups.forEach((artist, artistSongs) {
      if (artistSongs.length >= 3) { // Only create albums with at least 3 songs
        // Group by album name if available, otherwise create single artist album
        final Map<String, List<ApiSong>> albumGroups = {};
        
        for (final song in artistSongs) {
          final albumName = song.album.isNotEmpty ? song.album : '$artist Collection';
          albumGroups.putIfAbsent(albumName, () => []).add(song);
        }
        
        albumGroups.forEach((albumName, albumSongs) {
          if (albumSongs.length >= 2) { // At least 2 songs per album
            generatedAlbums.add(Album.fromSongs(
              id: '${artist}_$albumName'.replaceAll(' ', '_').toLowerCase(),
              title: albumName,
              artist: artist,
              songs: albumSongs.cast<Song>(),
              year: DateTime.now().year,
              genre: _getGenreForArtist(artist),
            ));
          }
        });
      }
    });

    albums = generatedAlbums;
    forYouAlbums = generatedAlbums.take(6).toList(); // Take first 6 for "For You"
  }

  String _getGenreForArtist(String artist) {
    // Simple genre mapping - you could make this more sophisticated
    final genreMap = {
      'pop': ['taylor swift', 'ariana grande', 'billie eilish', 'dua lipa'],
      'rock': ['queen', 'the beatles', 'led zeppelin', 'pink floyd'],
      'hip-hop': ['drake', 'kendrick lamar', 'kanye west', 'travis scott'],
      'electronic': ['calvin harris', 'david guetta', 'skrillex', 'deadmau5'],
      'r&b': ['the weeknd', 'frank ocean', 'sza', 'daniel caesar'],
    };

    for (final entry in genreMap.entries) {
      if (entry.value.any((artistName) => 
          artist.toLowerCase().contains(artistName))) {
        return entry.key.toUpperCase();
      }
    }
    
    return 'Pop'; // Default genre
  }

  void _updateLegacyData() {
    playlists = SampleData.playlists;
    genres = SampleData.genres;
  }

  void _loadSampleData() {
    final sampleSongs = SampleData.songs;
    songs = sampleSongs.map((song) => ApiSong(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      image: song.image,
    )).toList();
    
    trendingSongs = songs.take(10).toList();
    newReleases = songs.skip(10).take(10).toList();
    
    // Create sample albums
    _createSampleAlbums();
    
    playlists = SampleData.playlists;
    genres = SampleData.genres;
  }

  void _createSampleAlbums() {
    // Create sample albums from existing songs
    final sampleAlbums = [
      Album.fromSongs(
        id: 'pop_hits_2024',
        title: 'Pop Hits 2024',
        artist: 'Various Artists',
        songs: songs.take(5).cast<Song>().toList(),
        year: 2024,
        genre: 'Pop',
      ),
      Album.fromSongs(
        id: 'indie_collection',
        title: 'Indie Collection',
        artist: 'Indie Artists',
        songs: songs.skip(5).take(4).cast<Song>().toList(),
        year: 2024,
        genre: 'Indie',
      ),
      Album.fromSongs(
        id: 'electronic_vibes',
        title: 'Electronic Vibes',
        artist: 'Electronic Artists',
        songs: songs.skip(9).take(6).cast<Song>().toList(),
        year: 2024,
        genre: 'Electronic',
      ),
      Album.fromSongs(
        id: 'chill_acoustic',
        title: 'Chill Acoustic',
        artist: 'Acoustic Artists',
        songs: songs.skip(15).take(4).cast<Song>().toList(),
        year: 2024,
        genre: 'Acoustic',
      ),
    ];

    albums = sampleAlbums;
    forYouAlbums = sampleAlbums;
  }

  Future<void> _handleSongSelect(Song song) async {
    final audioService = context.read<AudioPlayerService>();
    final lyricsService = context.read<LyricsService>();

    try {
      // Convert to ApiSong if needed
      ApiSong apiSong;
      if (song is ApiSong) {
        apiSong = song;
      } else {
        apiSong = ApiSong(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: song.duration,
          image: song.image,
        );
      }

      // Play the song
      await audioService.playSong(apiSong, newPlaylist: songs.cast<Song>());

      // Load lyrics in background
      lyricsService.loadLyrics(apiSong);

    } catch (e) {
      _showError('Failed to play song: $e');
    }
  }

  Future<void> _handleAlbumSelect(Album album) async {
    if (album.songs.isNotEmpty) {
      // Play the first song from the album
      await _handleSongSelect(album.songs.first);
      
      // Set the playlist to all songs from this album
      final audioService = context.read<AudioPlayerService>();
      audioService.clearPlaylist();
      for (final song in album.songs) {
        audioService.addToPlaylist(song);
      }
    }
  }

  void _handlePlayPause() {
    context.read<AudioPlayerService>().togglePlayPause();
  }

  void _handlePrevious() {
    context.read<AudioPlayerService>().playPrevious();
  }

  void _handleNext() {
    context.read<AudioPlayerService>().playNext();
  }

  void _handleShuffle() {
    context.read<AudioPlayerService>().toggleShuffle();
  }

  void _handleRepeat() {
    context.read<AudioPlayerService>().toggleRepeatMode();
  }

  void _handleVolumeChange(double newVolume) {
    context.read<AudioPlayerService>().setVolume(newVolume / 100);
  }

  void _handleSeek(double value) {
    context.read<AudioPlayerService>().seekToPercentage(value);
  }

  void _openFullPlayer() {
    setState(() {
      showFullPlayer = true;
    });
  }

  void _closeFullPlayer() {
    setState(() {
      showFullPlayer = false;
    });
  }

  void _toggleLikedSong(int songId) {
    setState(() {
      if (likedSongs.contains(songId)) {
        likedSongs.remove(songId);
      } else {
        likedSongs.add(songId);
      }
    });
  }

  bool _isSongLiked(int songId) {
    return likedSongs.contains(songId);
  }

  List<Song> get likedSongsList {
    return songs.where((song) => likedSongs.contains(song.id)).cast<Song>().toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    
    // Debounce search
    _performSearch(query);
  }

  Timer? _searchTimer;
  void _performSearch(String query) async {
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        try {
          setState(() {
            isLoading = true;
          });
          
          final musicApiService = context.read<MusicAPIService>();
          final results = await musicApiService.searchSongs(query, limit: 50);
          
          setState(() {
            songs = results;
            _createAlbumsFromSongs(); // Recreate albums from search results
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          _showError('Search failed: $e');
        }
      } else {
        // Reset to original songs
        _initializeData();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _initializeData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        return Stack(
          children: [
            Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                shadowColor: Colors.grey.withOpacity(0.5),
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Colors.black87),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                title: Text(
                  'Elnine',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFbe29ec),
                  ),
                ),
                actions: [
                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFbe29ec)),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.grey[600]),
                    onPressed: _initializeData,
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) {
                      if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ApiSetupScreen()),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 20),
                            SizedBox(width: 8),
                            Text('API Settings'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              drawer: SideMenu(
                activeTab: activeTab,
                songs: songs.cast<Song>(),
                likedSongs: likedSongsList,
                onTabChanged: (index) {
                  setState(() {
                    activeTab = index;
                  });
                },
                onSongSelect: _handleSongSelect,
                onLikeToggle: _toggleLikedSong,
                isSongLiked: _isSongLiked,
              ),
              body: Stack(
                children: [
                  if (errorMessage != null && !isLoading && songs.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFbe29ec),
                            ),
                            child: Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  else
                    IndexedStack(
                      index: activeTab,
                      children: [
                        HomeContent(
                          songs: songs.cast<Song>(),
                          albums: forYouAlbums, // Pass albums for "For You" section
                          playlists: playlists,
                          likedSongs: likedSongs,
                          trendingSongs: trendingSongs.cast<Song>(),
                          newReleases: newReleases.cast<Song>(),
                          isLoading: isLoading,
                          onSongSelect: _handleSongSelect,
                          onAlbumSelect: _handleAlbumSelect, // New album handler
                          onLikeToggle: _toggleLikedSong,
                          lastPlayedSongs: [],
                        ),
                        SearchContent(
                          searchQuery: searchQuery,
                          songs: songs.cast<Song>(),
                           genres: genres,
                          likedSongs: likedSongs,
                          onSearchChanged: _onSearchChanged,
                          onSongSelect: _handleSongSelect,
                           onLikeToggle: _toggleLikedSong,
                        ),
                        LibraryContent(
                          songs: songs.cast<Song>(),
                          playlists: playlists,
                          likedSongs: likedSongs,
                          onSongSelect: _handleSongSelect,
                             onLikeToggle: _toggleLikedSong,
                        ),
                        ProfileContent(),
                      ],
                    ),
                  // Mini Player
                  if (audioService.currentSong != null && !showFullPlayer)
                    Positioned(
                      bottom: 90, // Above navigation bar
                      left: 20,
                      right: 20,
                      child: MiniPlayer(
                        currentSong: audioService.currentSong!,
                        isPlaying: audioService.isPlaying,
                        currentTime: audioService.currentPositionSeconds,
                        duration: audioService.totalDurationSeconds,
                        isLiked: _isSongLiked(audioService.currentSong!.id),
                        onPlayPause: _handlePlayPause,
                        onLikeToggle: () => _toggleLikedSong(audioService.currentSong!.id),
                        onTap: _openFullPlayer,
                      ),
                    ),
                  // Bottom Navigation
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(Icons.home, 'Home', 0),
                          _buildNavItem(Icons.search, 'Search', 1),
                          FloatingActionButton(
                            onPressed: () async {
                              // Shuffle and play all songs
                              if (songs.isNotEmpty) {
                                final shuffledSongs = List<ApiSong>.from(songs)..shuffle();
                                await _handleSongSelect(shuffledSongs.first);
                                context.read<AudioPlayerService>().toggleShuffle();
                              }
                            },
                            backgroundColor: Color(0xFFbe29ec),
                            child: Icon(Icons.shuffle, color: Colors.white),
                            elevation: 8,
                            mini: true,
                          ),
                          _buildNavItem(Icons.library_music, 'Library', 2),
                          _buildNavItem(Icons.person, 'Profile', 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Full Player
            if (showFullPlayer && audioService.currentSong != null)
              Consumer<LyricsService>(
                builder: (context, lyricsService, child) {
                  return FullPlayer(
                    currentSong: audioService.currentSong!,
                    isPlaying: audioService.isPlaying,
                    currentTime: audioService.currentPositionSeconds,
                    duration: audioService.totalDurationSeconds,
                    volume: (audioService.volume * 100).round().toDouble(),
                    isShuffled: audioService.isShuffled,
                    repeatMode: audioService.repeatMode.toString().split('.').last,
                    isLiked: _isSongLiked(audioService.currentSong!.id),
                    lyrics: lyricsService.currentLyrics,
                    activeLyricIndex: lyricsService.activeLyricIndex,
                    onClose: _closeFullPlayer,
                    onPlayPause: _handlePlayPause,
                    onPrevious: _handlePrevious,
                    onNext: _handleNext,
                    onShuffle: _handleShuffle,
                    onRepeat: _handleRepeat,
                    onLikeToggle: () => _toggleLikedSong(audioService.currentSong!.id),
                    onVolumeChange: _handleVolumeChange,
                    onSeek: _handleSeek,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeTab = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Color(0xFFbe29ec) : Colors.grey[600],
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Color(0xFFbe29ec) : Colors.grey[600],
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}

// API Setup Screen Widget (unchanged)
class ApiSetupScreen extends StatefulWidget {
  @override
  _ApiSetupScreenState createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _spotifyClientIdController = TextEditingController();
  final _spotifyClientSecretController = TextEditingController();
  final _lastFmApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    // TODO: Implement loading of current API config if needed.
    // For now, this is a placeholder to avoid errors.
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder UI for API setup
    return Scaffold(
      appBar: AppBar(
        title: Text('API Settings'),
        backgroundColor: Color(0xFFbe29ec),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Spotify Client ID'),
              TextFormField(
                controller: _spotifyClientIdController,
                decoration: InputDecoration(
                  hintText: 'Enter Spotify Client ID',
                ),
              ),
              SizedBox(height: 16),
              Text('Spotify Client Secret'),
              TextFormField(
                controller: _spotifyClientSecretController,
                decoration: InputDecoration(
                  hintText: 'Enter Spotify Client Secret',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              Text('Last.fm API Key'),
              TextFormField(
                controller: _lastFmApiKeyController,
                decoration: InputDecoration(
                  hintText: 'Enter Last.fm API Key',
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save API keys
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFbe29ec),
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}