import 'package:flutter/material.dart';
import '../models/song.dart';

class SongItem extends StatelessWidget {
  final Song song;
  final int index;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback onLikeToggle;

  const SongItem({
    Key? key,
    required this.song,
    required this.index,
    required this.onTap,
    required this.isLiked,
    required this.onLikeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 0,
      color: Colors.grey[50],
      child: ListTile(
        leading: ClipRRect(
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
                color: Colors.grey[300],
                child: Icon(Icons.music_note, color: Colors.grey[600]),
              );
            },
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
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
                size: 20,
              ),
            ),
            SizedBox(width: 15),
            Text(
              song.duration,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(width: 10),
            Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}