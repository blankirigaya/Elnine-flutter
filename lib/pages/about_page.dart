import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFbe29ec),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(30),
              child: Icon(
                Icons.music_note,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Elnine',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFbe29ec),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                'Elnine is a modern audiobook streaming application that brings you the best audiobooks with high-quality audio, personalized playlists, and seamless playback.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            _buildInfoSection('Developer', 'Elnine Team'),
            _buildInfoSection('Copyright', '© 2024 Elnine Music'),
            _buildInfoSection('License', 'MIT License'),
            SizedBox(height: 30),
            Text(
              'Made with ❤️ for listeners',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}