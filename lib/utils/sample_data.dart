import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/genre.dart';

class SampleData {
  static final List<Song> songs = [
    Song(
      id: 1,
      title: "Blinding Lights",
      artist: "The Weeknd",
      album: "After Hours",
      duration: "3:20",
      image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
    ),
    Song(
      id: 2,
      title: "Watermelon Sugar",
      artist: "Harry Styles",
      album: "Fine Line",
      duration: "2:54",
      image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&h=300&fit=crop",
    ),
    Song(
      id: 3,
      title: "Levitating",
      artist: "Dua Lipa",
      album: "Future Nostalgia",
      duration: "3:23",
      image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
    ),
    Song(
      id: 4,
      title: "Good 4 U",
      artist: "Olivia Rodrigo",
      album: "SOUR",
      duration: "2:58",
      image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&h=300&fit=crop",
    ),
    Song(
      id: 5,
      title: "Stay",
      artist: "The Kid LAROI & Justin Bieber",
      album: "F*CK LOVE 3",
      duration: "2:21",
      image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
    ),
    Song(
      id: 6,
      title: "Industry Baby",
      artist: "Lil Nas X ft. Jack Harlow",
      album: "MONTERO",
      duration: "3:32",
      image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&h=300&fit=crop",
    ),
  ];

  static final List<Playlist> playlists = [
    Playlist(
      id: 1,
      name: "My Mix 1",
      songCount: 25,
      image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200&h=200&fit=crop",
    ),
    Playlist(
      id: 2,
      name: "Chill Vibes",
      songCount: 42,
      image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200&h=200&fit=crop",
    ),
    Playlist(
      id: 3,
      name: "Workout Hits",
      songCount: 18,
      image: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200&h=200&fit=crop",
    ),
    Playlist(
      id: 4,
      name: "Late Night",
      songCount: 33,
      image: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200&h=200&fit=crop",
    ),
  ];

  static final List<Genre> genres = [
    Genre(name: 'mystery', image: Image.network("https://i.postimg.cc/mrHRCQLJ/mystery.jpg")), // Dark mysterious scene
    Genre(name: 'romance', image: Image.network("https://i.postimg.cc/cL1rRk2j/rose.jpg")), // Romantic heart/roses
    Genre(name: 'fantasy', image: Image.network("https://i.postimg.cc/vBtJthpq/fantasy.jpg")), // Fantasy forest/magical
    Genre(name: 'horror', image: Image.network("https://i.postimg.cc/25Fcs623/horror.jpg")), // Dark spooky scene
    Genre(name: 'paranormal', image: Image.network("https://i.postimg.cc/C15GcL23/paranormal.jpg")), // Supernatural/ghostly
    Genre(name: 'rom-com', image: Image.network("https://i.postimg.cc/fRvqFyHy/rom-com.jpg")), // Light romantic comedy
    Genre(name: 'historical', image: Image.network("https://i.postimg.cc/sXWNTcbd/history.jpg")), // Historical architecture/vintage
    Genre(name: 'LGBTQ+', image: Image.network("https://i.postimg.cc/TwntVPWT/lgbtq.png")), // Pride colors/inclusive imagery
    Genre(name: 'sci-fi', image: Image.network("https://i.postimg.cc/13NwnjFQ/scifi.jpg")), // Futuristic/space scene
    Genre(name: 'Elninee Exclusive', image: Image.network("https://i.postimg.cc/rwCyPGX4/exclusive.jpg")), // Futuristic/space scene
    ];
}