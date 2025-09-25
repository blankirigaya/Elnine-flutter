import 'package:flutter/material.dart';

// Main Profile Content Widget
class ProfileContent extends StatefulWidget {
  const ProfileContent({Key? key}) : super(key: key);

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  String userName = 'Music Lover';
  String userEmail = 'musiclover@example.com';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 120),
      child: Column(
        children: [
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _editProfile(context),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: Icon(Icons.account_circle, size: 100, color: Colors.grey[600]),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFbe29ec),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ..._buildProfileMenuItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildProfileMenuItems(BuildContext context) {
    final items = [
      {'icon': Icons.person, 'title': 'Edit Profile', 'color': Colors.grey[600], 'action': () => _editProfile(context)},
      {'icon': Icons.card_membership, 'title': 'Subscription', 'color': Colors.grey[600], 'action': () => _openSubscription(context)},
      {'icon': Icons.download, 'title': 'Downloads', 'color': Colors.grey[600], 'action': () => _openDownloads(context)},
      {'icon': Icons.bar_chart, 'title': 'Listening Stats', 'color': Colors.grey[600], 'action': () => _openStats(context)},
      {'icon': Icons.notifications, 'title': 'Notifications', 'color': Colors.grey[600], 'action': () => _openNotifications(context)},
      {'icon': Icons.security, 'title': 'Privacy & Security', 'color': Colors.grey[600], 'action': () => _openPrivacySecurity(context)},
      {'icon': Icons.help, 'title': 'Help & Support', 'color': Colors.grey[600], 'action': () => _openHelpSupport(context)},
      {'icon': Icons.logout, 'title': 'Log Out', 'color': Color(0xFFbe29ec), 'action': () => _logOut(context)},
    ];

    return items.map((item) {
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
        ),
        child: ListTile(
          leading: Icon(item['icon'] as IconData, color: item['color'] as Color),
          title: Text(
            item['title'] as String,
            style: TextStyle(
              color: item['color'] == Color(0xFFbe29ec) ? Color(0xFFbe29ec) : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: item['color'] as Color),
          onTap: item['action'] as VoidCallback,
        ),
      );
    }).toList();
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: userName,
          currentEmail: userEmail,
          onUpdate: (name, email) {
            setState(() {
              userName = name;
              userEmail = email;
            });
          },
        ),
      ),
    );
  }

  void _openSubscription(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionScreen()),
    );
  }

  void _openDownloads(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DownloadsScreen()),
    );
  }

  void _openStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListeningStatsScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()),
    );
  }

  void _openPrivacySecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacySecurityScreen()),
    );
  }

  void _openHelpSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpSupportScreen()),
    );
  }

  void _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add your logout logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully')),
                );
              },
              child: Text('Log Out', style: TextStyle(color: Color(0xFFbe29ec))),
            ),
          ],
        );
      },
    );
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final Function(String, String) onUpdate;

  const EditProfileScreen({
    Key? key,
    required this.currentName,
    required this.currentEmail,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text('Save', style: TextStyle(color: Color(0xFFbe29ec))),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Icon(Icons.account_circle, size: 120, color: Colors.grey[600]),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFbe29ec),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    widget.onUpdate(nameController.text, emailController.text);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

// Subscription Screen
class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscription')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFbe29ec).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFbe29ec)),
              ),
              child: Column(
                children: [
                  Icon(Icons.star, color: Color(0xFFbe29ec), size: 48),
                  SizedBox(height: 16),
                  Text('Premium Plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Unlimited music, no ads', style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 16),
                  Text('\$9.99/month', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFbe29ec))),
                ],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Ad-free listening'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Unlimited downloads'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('High-quality audio'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Offline mode'),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Subscription upgraded!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFbe29ec),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Upgrade to Premium', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Downloads Screen
class DownloadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final downloads = [
      {'title': 'Bohemian Rhapsody', 'artist': 'Queen', 'size': '8.2 MB'},
      {'title': 'Shape of You', 'artist': 'Ed Sheeran', 'size': '7.1 MB'},
      {'title': 'Blinding Lights', 'artist': 'The Weeknd', 'size': '6.8 MB'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Downloads'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloads cleared')),
              );
            },
            icon: Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: downloads.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No downloads yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return ListTile(
                leading: Icon(Icons.music_note, color: Color(0xFFbe29ec)),
                title: Text(download['title']!),
                subtitle: Text(download['artist']!),
                trailing: Text(download['size']!, style: TextStyle(color: Colors.grey)),
              );
            },
          ),
    );
  }
}

// Listening Stats Screen
class ListeningStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listening Stats')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('This Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('42', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFbe29ec))),
                          Text('Hours', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Column(
                        children: [
                          Text('156', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFbe29ec))),
                          Text('Songs', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Column(
                        children: [
                          Text('23', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFbe29ec))),
                          Text('Artists', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Top Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(child: Text('1')),
                    title: Text('Ed Sheeran'),
                    trailing: Text('12 hours'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text('2')),
                    title: Text('Taylor Swift'),
                    trailing: Text('8 hours'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text('3')),
                    title: Text('The Weeknd'),
                    trailing: Text('6 hours'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Notifications Screen
class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool newReleases = true;
  bool playlistUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Push Notifications'),
            subtitle: Text('Get notified about new releases and updates'),
            value: pushNotifications,
            onChanged: (value) => setState(() => pushNotifications = value),
          ),
          SwitchListTile(
            title: Text('Email Notifications'),
            subtitle: Text('Receive notifications via email'),
            value: emailNotifications,
            onChanged: (value) => setState(() => emailNotifications = value),
          ),
          SwitchListTile(
            title: Text('New Releases'),
            subtitle: Text('Get notified when artists release new music'),
            value: newReleases,
            onChanged: (value) => setState(() => newReleases = value),
          ),
          SwitchListTile(
            title: Text('Playlist Updates'),
            subtitle: Text('Get notified when followed playlists are updated'),
            value: playlistUpdates,
            onChanged: (value) => setState(() => playlistUpdates = value),
          ),
        ],
      ),
    );
  }
}

// Privacy & Security Screen
class PrivacySecurityScreen extends StatefulWidget {
  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool privateProfile = false;
  bool shareListeningActivity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy & Security')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Private Profile'),
            subtitle: Text('Make your profile private'),
            value: privateProfile,
            onChanged: (value) => setState(() => privateProfile = value),
          ),
          SwitchListTile(
            title: Text('Share Listening Activity'),
            subtitle: Text('Allow others to see what you\'re listening to'),
            value: shareListeningActivity,
            onChanged: (value) => setState(() => shareListeningActivity = value),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password change feature coming soon')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Delete Account', style: TextStyle(color: Colors.red)),
            trailing: Icon(Icons.chevron_right, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Account'),
                  content: Text('This action cannot be undone. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Account deletion requested')),
                        );
                      },
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help & Support')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('FAQ'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening FAQ...')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Contact Support'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening chat support...')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Report a Bug'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bug report form opened')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Rate the App'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Thank you for rating!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('About'),
                  content: Text('Music App v1.0.0\nBuilt with Flutter'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}