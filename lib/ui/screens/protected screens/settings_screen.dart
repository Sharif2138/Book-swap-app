import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for settings options
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        toolbarHeight: 90.0,
        // Use the consistent dark theme color
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Profile Section ---
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color.fromARGB(255, 30, 24, 66
            ), // A deep, slightly lighter purple for the avatar background
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'John Doe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Center(
            child: Text(
              'john.doe@example.com',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),

          const Divider(height: 40, thickness: 1),

          // --- General Settings Section ---
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:  Color.fromARGB(255, 1, 6, 37),
              ),
            ),
          ),

          // Dark Mode Switch
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color.fromARGB(255, 1, 6, 37),
              ),
              value: isDarkMode,
              onChanged: (val) => setState(() => isDarkMode = val),
              title: const Text('Dark Mode'),
              activeThumbColor: const Color.fromARGB(255, 214, 196, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Notifications Switch
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              secondary: Icon(
                notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: const Color.fromARGB(255, 1, 6, 37),
              ),
              value: notificationsEnabled,
              onChanged: (val) => setState(() => notificationsEnabled = val),
              title: const Text('Notifications'),
              activeThumbColor: const Color.fromARGB(255, 214, 196, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // --- Action Button ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 198, 20, 7),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/');
              // TODO: Add actual logout logic later
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(
              //       'Logged out: isDarkMode=$isDarkMode, notificationsEnabled=$notificationsEnabled',
              //     ),
              //     duration: const Duration(seconds: 2),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
