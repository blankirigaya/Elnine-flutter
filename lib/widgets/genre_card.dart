import 'package:flutter/material.dart';
import '../models/genre.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;
  final VoidCallback? onTap;

  const GenreCard({
    Key? key,
    required this.genre,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 50) / 2,
        height: 100,
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: genre.image.image,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFbe29ec),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(15),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            genre.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}