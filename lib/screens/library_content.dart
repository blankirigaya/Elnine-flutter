import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../widgets/song_item.dart';
import '../widgets/playlist_card.dart';

class LibraryContent extends StatelessWidget {
  final List<Song> songs;
  final List<Playlist> playlists;
  final Set<int> likedSongs;
  final Function(Song) onSongSelect;
  final Function(int) onLikeToggle;

  const LibraryContent({
    Key? key,
    required this.songs,
    required this.playlists,
    required this.likedSongs,
    required this.onSongSelect,
    required this.onLikeToggle,
  }) : super(key: key);

  List<Song> get likedSongsList {
    return songs.where((song) => likedSongs.contains(song.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Library',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFFbe29ec), size: 28),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.8,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) => PlaylistCard(
              playlist: playlists[index],
              onTap: () {
                // Handle playlist tap
              },
            ),
          ),
          SizedBox(height: 30),
          if (likedSongsList.isNotEmpty) ...[
            Text(
              'Liked Songs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            ...likedSongsList.map((song) => SongItem(
              song: song,
              index: songs.indexOf(song),
              onTap: () => onSongSelect(song),
              isLiked: likedSongs.contains(song.id),
              onLikeToggle: () => onLikeToggle(song.id),
            )),
          ] else ...[
            Container(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No liked songs yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any song to add it here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}