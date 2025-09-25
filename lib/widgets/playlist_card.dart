import 'package:flutter/material.dart';
import '../models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  playlist.image,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 160,
                      height: 160,
                      color: Colors.grey[300],
                      child: Icon(Icons.music_note, color: Colors.grey[600], size: 40),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              playlist.name,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              '${playlist.songCount} songs',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}