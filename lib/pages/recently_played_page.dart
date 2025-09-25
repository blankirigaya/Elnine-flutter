import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_item.dart';

class RecentlyPlayedPage extends StatelessWidget {
  final List<Song> songs;
  final Function(Song) onSongTap;
  final Function(int) onLikeToggle;
  final bool Function(int) isSongLiked;

  const RecentlyPlayedPage({
    Key? key,
    required this.songs,
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
          'Recently Played',
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
            icon: Icon(Icons.clear_all, color: Colors.grey[600]),
            onPressed: () {
              // Clear recently played - would need implementation
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
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