import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Settings',
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Playback'),
          _buildSettingItem('Audio Quality', 'High'),
          _buildSettingItem('Crossfade', 'Off'),
          _buildSettingItem('Gapless Playback', 'On'),
          SizedBox(height: 20),
          _buildSectionHeader('Display'),
          _buildSettingItem('Theme', 'Light'),
          _buildSettingItem('Show Explicit Content', 'On'),
          SizedBox(height: 20),
          _buildSectionHeader('Storage'),
          _buildSettingItem('Download Quality', 'High'),
          _buildSettingItem('Storage Location', 'Internal'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFbe29ec),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(width: 5),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}