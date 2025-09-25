import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_item.dart';

class LikedSongsPage extends StatelessWidget {
  final List<Song> likedSongs;
  final Function(Song) onSongTap;
  final Function(int) onLikeToggle;
  final bool Function(int) isSongLiked;

  const LikedSongsPage({
    Key? key,
    required this.likedSongs,
    required this.onSongTap,
    required this.onLikeToggle,
    required this.isSongLiked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Liked Songs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle, color: Color(0xFFbe29ec)),
            onPressed: () {
              if (likedSongs.isNotEmpty) {
                final shuffled = List.from(likedSongs)..shuffle();
                onSongTap(shuffled.first);
              }
            },
          ),
        ],
      ),
      body: likedSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No liked songs yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap the heart on any song to add it here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: likedSongs.length,
              itemBuilder: (context, index) {
                final song = likedSongs[index];
                return SongItem(
                  song: song,
                  index: index,
                  onTap: () => onSongTap(song),
                  isLiked: isSongLiked(song.id),
                  onLikeToggle: () => onLikeToggle(song.id),
                );
              },
            ),
    );
  }
}