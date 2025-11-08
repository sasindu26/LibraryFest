import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dueDateReminders = true;
  bool _newBooksNotification = true;
  bool _systemNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Notification Preferences',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage how you receive notifications',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Due Date Reminders
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _dueDateReminders,
              onChanged: (value) {
                setState(() {
                  _dueDateReminders = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Due date reminders enabled'
                          : 'Due date reminders disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              title: Text(
                'Due Date Reminders',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Get notified before your books are due',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_available, color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // New Books Notification
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _newBooksNotification,
              onChanged: (value) {
                setState(() {
                  _newBooksNotification = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'New books notifications enabled'
                          : 'New books notifications disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              title: Text(
                'New Books',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Get notified when new books are added',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.new_releases, color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // System Notifications
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _systemNotifications,
              onChanged: (value) {
                setState(() {
                  _systemNotifications = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'System notifications enabled'
                          : 'System notifications disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              title: Text(
                'System Notifications',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Important updates and announcements',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email Notifications
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Email notifications enabled'
                          : 'Email notifications disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              title: Text(
                'Email Notifications',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Receive notifications via email',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.email, color: Colors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
