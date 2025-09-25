import 'package:flutter/material.dart';
import '../models/song.dart';

class MiniPlayer extends StatelessWidget {
  final Song currentSong;
  final bool isPlaying;
  final int currentTime;
  final int duration;
  final bool isLiked;
  final VoidCallback onPlayPause;
  final VoidCallback onLikeToggle;
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.currentSong,
    required this.isPlaying,
    required this.currentTime,
    required this.duration,
    required this.isLiked,
    required this.onPlayPause,
    required this.onLikeToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = duration > 0 ? (currentTime / duration) * 100 : 0.0;

    return Positioned(
      bottom: 100, // Position above the bottom navigation
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: ListTile(
                leading: Hero(
                  tag: 'player-image',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      currentSong.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: Icon(Icons.music_note, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                title: Text(
                  currentSong.title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  currentSong.artist,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onLikeToggle,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_outline,
                        color: isLiked ? Color(0xFFbe29ec) : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: onPlayPause,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFbe29ec),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 2,
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFbe29ec)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}