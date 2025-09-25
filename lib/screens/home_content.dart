// screens/home_content.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../models/playlist.dart';

class HomeContent extends StatelessWidget {
  final List<Song> songs;
  final List<Album> albums;
  final List<Playlist> playlists;
  final Set<int> likedSongs;
  final List<Song> trendingSongs;
  final List<Song> newReleases;
  final List<Song> lastPlayedSongs; // New last played parameter
  final bool isLoading;
  final Function(Song) onSongSelect;
  final Function(Album) onAlbumSelect;
  final Function(int) onLikeToggle;

  const HomeContent({
    Key? key,
    required this.songs,
    required this.albums,
    required this.playlists,
    required this.likedSongs,
    required this.trendingSongs,
    required this.newReleases,
    required this.lastPlayedSongs, // New required parameter
    required this.isLoading,
    required this.onSongSelect,
    required this.onAlbumSelect,
    required this.onLikeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFbe29ec)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your music...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 150), // Space for mini player and nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          SizedBox(height: 24),

          // For You Albums Section (More Compact)
          _buildForYouSection(context),
          SizedBox(height: 32),

          // Quick Actions (with Last Played instead of Shuffle)
          _buildQuickActionsSection(context),
          SizedBox(height: 32),

          // Trending Songs
          if (trendingSongs.isNotEmpty) ...[
            _buildTrendingSection(context),
            SizedBox(height: 32),
          ],

          // New Releases
          if (newReleases.isNotEmpty) ...[
            _buildNewReleasesSection(context),
            SizedBox(height: 32),
          ],

          // Recent Playlists
          if (playlists.isNotEmpty) ...[
            _buildPlaylistsSection(context),
            SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
  Widget _buildForYouSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: Color(0xFFbe29ec),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'For You',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to all albums view
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFFbe29ec),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 220, // Reduced from 280 to 220
          child: albums.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return _buildCompactAlbumCard(context, album, index == 0);
                  },
                )
              : _buildEmptyAlbumsState(),
        ),
      ],
    );
  }

  Widget _buildCompactAlbumCard(BuildContext context, Album album, bool isFirst) {
    return GestureDetector(
      onTap: () => onAlbumSelect(album),
      child: Container(
        width: 140, // Reduced from 180 to 140
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover (more compact)
            Container(
              height: 140, // Reduced from 180 to 140
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // Reduced radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      album.coverImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFbe29ec).withOpacity(0.3),
                                Color(0xFFbe29ec).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.album,
                              color: Color(0xFFbe29ec),
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Genre badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        album.genre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(0xFFbe29ec).withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFbe29ec).withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // First album indicator
                  if (isFirst)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Album Info (more compact)
            Text(
              album.title,
              style: TextStyle(
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1, // Reduced from 2
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              album.artist,
              style: TextStyle(
                fontSize: 12, // Reduced from 14
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  size: 12, // Reduced from 14
                  color: Colors.grey[500],
                ),
                SizedBox(width: 2),
                Expanded(
                  child: Text(
                    '${album.songs.length} • ${album.formattedDuration}',
                    style: TextStyle(
                      fontSize: 10, // Reduced from 12
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAlbumsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.album_outlined,
            size: 48, // Reduced from 64
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'No albums available',
            style: TextStyle(
              fontSize: 14, // Reduced from 16
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Check back later for curated albums',
            style: TextStyle(
              fontSize: 12, // Reduced from 14
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.history,
                  title: 'Last Played',
                  subtitle: lastPlayedSongs.isEmpty 
                      ? 'No recent songs' 
                      : '${lastPlayedSongs.length} recent',
                  color: Color(0xFFbe29ec),
                  onTap: () {
                    if (lastPlayedSongs.isNotEmpty) {
                      // Navigate to last played or play the most recent song
                      onSongSelect(lastPlayedSongs.first);
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.favorite,
                  title: 'Liked Songs',
                  subtitle: '${likedSongs.length} songs',
                  color: Colors.red,
                  onTap: () {
                    // Navigate to liked songs
                    if (likedSongs.isNotEmpty) {
                      // Find first liked song and play it
                      final likedSongsList = songs.where((song) => likedSongs.contains(song.id)).toList();
                      if (likedSongsList.isNotEmpty) {
                        onSongSelect(likedSongsList.first);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: trendingSongs.take(10).length,
            itemBuilder: (context, index) {
              final song = trendingSongs[index];
              return _buildSongCard(song, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.new_releases,
                color: Colors.green,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'New Releases',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: newReleases.take(10).length,
            itemBuilder: (context, index) {
              final song = newReleases[index];
              return _buildSongCard(song);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.queue_music,
                color: Color(0xFFbe29ec),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Your Playlists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _buildPlaylistCard(playlist);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongCard(Song song, [int? rank]) {
    return GestureDetector(
      onTap: () => onSongSelect(song),
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    song.image,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFbe29ec).withOpacity(0.3),
                              Color(0xFFbe29ec).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Icon(Icons.music_note, color: Color(0xFFbe29ec)),
                      );
                    },
                  ),
                ),
                if (rank != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            song.duration,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onLikeToggle(song.id),
                          child: Icon(
                            likedSongs.contains(song.id)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            size: 16,
                            color: likedSongs.contains(song.id)
                                ? Colors.red
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return GestureDetector(
      onTap: () {
        // Navigate to playlist
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFbe29ec).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.queue_music,
                color: Color(0xFFbe29ec),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playlist.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${playlist.songCount} songs',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}