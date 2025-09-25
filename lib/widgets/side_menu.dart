import 'package:flutter/material.dart';
import '../pages/downloads_page.dart';
import '../pages/liked_songs_page.dart';
import '../pages/recently_played_page.dart';
import '../pages/settings_page.dart';
import '../pages/help_feedback_page.dart';
import '../pages/about_page.dart';
import '../models/song.dart';

class SideMenu extends StatelessWidget {
  final int activeTab;
  final List<Song> songs;
  final List<Song> likedSongs;
  final Function(int) onTabChanged;
  final Function(Song) onSongSelect;
  final Function(int) onLikeToggle;
  final bool Function(int) isSongLiked;

  const SideMenu({
    Key? key,
    required this.activeTab,
    required this.songs,
    required this.likedSongs,
    required this.onTabChanged,
    required this.onSongSelect,
    required this.onLikeToggle,
    required this.isSongLiked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Elnine',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFbe29ec),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black87, size: 24),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 10),
                  _buildSideMenuItem(context, Icons.home_outlined, Icons.home, 'Home', 0),
                  _buildSideMenuItem(context, Icons.search_outlined, Icons.search, 'Search', 1),
                  _buildSideMenuItem(context, Icons.library_music_outlined, Icons.library_music, 'Your Library', 2),
                  _buildSideMenuItem(context, Icons.person_outline, Icons.person, 'Profile', 3),
                  
                  // Divider
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                  
                  _buildSideMenuItem(context, Icons.download_outlined, Icons.download, 'Downloads', -1),
                  _buildSideMenuItem(context, Icons.favorite_outline, Icons.favorite, 'Liked Songs', -1),
                  _buildSideMenuItem(context, Icons.history, Icons.history, 'Recently Played', -1),
                  
                  // Divider
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                  
                  _buildSideMenuItem(context, Icons.settings_outlined, Icons.settings, 'Settings', -1),
                  _buildSideMenuItem(context, Icons.help_outline, Icons.help, 'Help & Feedback', -1),
                  _buildSideMenuItem(context, Icons.info_outline, Icons.info, 'About', -1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenuItem(BuildContext context, IconData outlinedIcon, IconData filledIcon, String title, int tabIndex) {
    final isActive = tabIndex >= 0 && activeTab == tabIndex;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (tabIndex >= 0) {
              onTabChanged(tabIndex);
              Navigator.of(context).pop(); // Close drawer
            } else {
              // Navigate to separate pages for non-tab items
              Navigator.of(context).pop(); // Close drawer first
              _navigateToPage(context, title);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Color(0xFFbe29ec).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? filledIcon : outlinedIcon,
                  color: isActive ? Color(0xFFbe29ec) : Colors.grey[600],
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Color(0xFFbe29ec) : Colors.black87,
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(0xFFbe29ec),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageName) {
    Widget page;
    switch (pageName) {
      case 'Downloads':
        page = DownloadsPage();
        break;
      case 'Liked Songs':
        page = LikedSongsPage(
          likedSongs: likedSongs,
          onSongTap: onSongSelect,
          onLikeToggle: onLikeToggle,
          isSongLiked: isSongLiked,
        );
        break;
      case 'Recently Played':
        page = RecentlyPlayedPage(
          songs: songs.take(10).toList(),
          onSongTap: onSongSelect,
          onLikeToggle: onLikeToggle,
          isSongLiked: isSongLiked,
        );
        break;
      case 'Settings':
        page = SettingsPage();
        break;
      case 'Help & Feedback':
        page = HelpFeedbackPage();
        break;
      case 'About':
        page = AboutPage();
        break;
      default:
        return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}