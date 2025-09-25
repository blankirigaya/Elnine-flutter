import 'package:flutter/material.dart';

class HelpFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Help & Feedback',
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
          _buildHelpSection('Frequently Asked Questions', [
            'How do I create a playlist?',
            'How do I download songs for offline listening?',
            'How do I share music with friends?',
            'How do I change audio quality?',
          ]),
          SizedBox(height: 30),
          _buildHelpSection('Account & Billing', [
            'Manage your subscription',
            'Payment methods',
            'Billing history',
            'Cancel subscription',
          ]),
          SizedBox(height: 30),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFbe29ec),
          ),
        ),
        SizedBox(height: 15),
        ...items.map((item) => Container(
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
          ),
          child: ListTile(
            title: Text(
              item,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            onTap: () {},
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFbe29ec),
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.email, color: Color(0xFFbe29ec)),
                  SizedBox(width: 15),
                  Text(
                    'support@elnine.com',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFFbe29ec)),
                  SizedBox(width: 15),
                  Text(
                    '+1 (555) 123-4567',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}