import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/genre.dart';
import '../widgets/song_item.dart';
import '../widgets/genre_card.dart';

class SearchContent extends StatelessWidget {
  final String searchQuery;
  final List<Song> songs;
  final List<Genre> genres;
  final Set<int> likedSongs;
  final Function(String) onSearchChanged;
  final Function(Song) onSongSelect;
  final Function(int) onLikeToggle;

  const SearchContent({
    Key? key,
    required this.searchQuery,
    required this.songs,
    required this.genres,
    required this.likedSongs,
    required this.onSearchChanged,
    required this.onSongSelect,
    required this.onLikeToggle,
  }) : super(key: key);

  List<Song> get filteredSongs {
    return songs.where((song) =>
        song.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        song.artist.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'What do you want to listen to?',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (searchQuery.isNotEmpty) ...[
            Text(
              'Search Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) => SongItem(
                  song: filteredSongs[index],
                  index: index,
                  onTap: () => onSongSelect(filteredSongs[index]),
                  isLiked: likedSongs.contains(filteredSongs[index].id),
                  onLikeToggle: () => onLikeToggle(filteredSongs[index].id),
                ),
              ),
            ),
          ] else ...[
            Text(
              'Browse all',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Wrap(
                spacing: 10,
                children: genres.map((genre) => GenreCard(
                  genre: genre,
                  onTap: () {
                    // Handle genre tapz
                  },
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}