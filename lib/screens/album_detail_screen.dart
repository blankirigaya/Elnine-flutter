// screens/album_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/song.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;
  final Set<int> likedSongs;
  final Function(Song) onSongSelect;
  final Function(int) onLikeToggle;
  final Function() onPlayAll;
  final Function() onShufflePlay;

  const AlbumDetailScreen({
    Key? key,
    required this.album,
    required this.likedSongs,
    required this.onSongSelect,
    required this.onLikeToggle,
    required this.onPlayAll,
    required this.onShufflePlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Album Cover
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Color(0xFFbe29ec),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Album Cover Background
                  Image.network(
                    album.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFbe29ec),
                              Color(0xFFbe29ec).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.album,
                            size: 120,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Album Info
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            album.genre,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          album.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          album.artist,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${album.year}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.music_note,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${album.songs.length} songs',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              album.formattedDuration,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPlayAll,
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Play All',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFbe29ec),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFbe29ec),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: onShufflePlay,
                      icon: Icon(
                        Icons.shuffle,
                        color: Color(0xFFbe29ec),
                      ),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Add to playlist functionality
                        _showAddToPlaylistDialog(context);
                      },
                      icon: Icon(
                        Icons.playlist_add,
                        color: Colors.grey[600],
                      ),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Songs List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Songs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Songs List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = album.songs[index];
                return _buildSongTile(context, song, index + 1);
              },
              childCount: album.songs.length,
            ),
          ),

          // Bottom Padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, Song song, int trackNumber) {
    final isLiked = likedSongs.contains(song.id);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFbe29ec).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$trackNumber',
                          style: TextStyle(
                            color: Color(0xFFbe29ec),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Track number overlay
              if (song.image.isNotEmpty)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$trackNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              song.artist,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (song.album.isNotEmpty && song.album != album.title) ...[
              SizedBox(height: 2),
              Text(
                song.album,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.duration,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () => onLikeToggle(song.id),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLiked 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: isLiked ? Colors.red : Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'add_to_playlist':
                    _showAddToPlaylistDialog(context, song: song);
                    break;
                  case 'share':
                    _shareSong(context, song);
                    break;
                  case 'info':
                    _showSongInfo(context, song);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add_to_playlist',
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add, size: 18),
                      SizedBox(width: 8),
                      Text('Add to playlist'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 18),
                      SizedBox(width: 8),
                      Text('Song info'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => onSongSelect(song),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, {Song? song}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(song != null ? 'Add Song to Playlist' : 'Add Album to Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create New Playlist'),
              onTap: () {
                Navigator.pop(context);
                _showCreatePlaylistDialog(context, song: song);
              },
            ),
            Divider(),
            Text('Or add to existing playlist:', 
                 style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            // Here you would list existing playlists
            ListTile(
              leading: Icon(Icons.queue_music),
              title: Text('My Favorites'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(song != null 
                        ? 'Song added to My Favorites'
                        : 'Album added to My Favorites'),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, {Song? song}) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Playlist'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playlist "${controller.text}" created!'),
                  ),
                );
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _shareSong(BuildContext context, Song song) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${song.title}" by ${song.artist}'),
      ),
    );
  }

  void _showSongInfo(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Song Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Title', song.title),
            _buildInfoRow('Artist', song.artist),
            _buildInfoRow('Album', song.album),
            _buildInfoRow('Duration', song.duration),
            _buildInfoRow('Genre', album.genre),
            _buildInfoRow('Year', '${album.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}