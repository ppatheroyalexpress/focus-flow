import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.waves, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Focus Flow',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 1.1 "San Marzano"',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'A cross-platform productivity tool designed to help you stay focused and manage your time effectively using the Pomodoro Technique.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildLinkTile(
              context,
              icon: Icons.code,
              title: 'GitHub Repository',
              url: 'https://github.com/ppatheroyalexpress/pomodoro-timer',
            ),
            _buildLinkTile(
              context,
              icon: Icons.language,
              title: 'Web Version',
              url: 'https://patheroyalexpress.github.io/pomodoro-timer/',
            ),
            _buildLinkTile(
              context,
              icon: Icons.person,
              title: 'Developer Profile',
              url: 'https://github.com/ppatheroyalexpress',
            ),
            const SizedBox(height: 48),
            const Text(
              'Made with ❤️ with Flutter',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(BuildContext context, {required IconData icon, required String title, required String url}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
    );
  }
}
