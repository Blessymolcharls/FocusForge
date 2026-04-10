import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _morningReminder = true;
  bool _codingReminder = true;
  bool _eveningReminder = true;
  bool _nightReview = true;
  int _totalXP = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final xp = await StorageService.getTotalXP();
    final streak = await StorageService.getStreak();
    setState(() {
      _totalXP = xp;
      _streak = streak;
    });
  }

  String get _level {
    if (_totalXP < 500) return 'Beginner';
    if (_totalXP < 1500) return 'Learner';
    if (_totalXP < 3000) return 'Scholar';
    if (_totalXP < 6000) return 'Expert';
    return 'Master';
  }

  int get _nextLevelXP {
    if (_totalXP < 500) return 500;
    if (_totalXP < 1500) return 1500;
    if (_totalXP < 3000) return 3000;
    if (_totalXP < 6000) return 6000;
    return 10000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),
          _buildXPProgress(),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Notification Settings'),
          const SizedBox(height: 12),
          _buildNotificationSection(),
          const SizedBox(height: 20),
          const SectionHeader(title: 'XP System'),
          const SizedBox(height: 12),
          _buildXPGuide(),
          const SizedBox(height: 20),
          const SectionHeader(title: 'App Info'),
          const SizedBox(height: 12),
          _buildAppInfo(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return GradientCard(
      colors: const [AppTheme.primary, AppTheme.primaryDark],
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('B',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Blessy',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('CS Student • IBM & GATE Aspirant',
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text('$_streak day streak',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgress() {
    final progress = (_totalXP / _nextLevelXP).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_level,
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('$_totalXP XP total',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              const Icon(Icons.military_tech, color: Colors.amber, size: 40),
            ],
          ),
          const SizedBox(height: 14),
          ProgressBarCard(
            label: 'Progress to next level',
            progress: progress,
            color: Colors.amber,
            subtitle: '$_totalXP / $_nextLevelXP XP',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _notifTile(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: 'Morning Study Reminder',
            subtitle: '7:00 AM — "Time to study for GATE!"',
            value: _morningReminder,
            onChanged: (v) => setState(() => _morningReminder = v),
            id: 101,
          ),
          _divider(),
          _notifTile(
            icon: Icons.code,
            iconColor: AppTheme.codingColor,
            title: 'Coding Challenge',
            subtitle: '10:00 AM — "Solve 2 problems today!"',
            value: _codingReminder,
            onChanged: (v) => setState(() => _codingReminder = v),
            id: 102,
          ),
          _divider(),
          _notifTile(
            icon: Icons.local_fire_department,
            iconColor: Colors.deepOrange,
            title: 'Stay Consistent',
            subtitle: '6:00 PM — Motivational reminder',
            value: _eveningReminder,
            onChanged: (v) => setState(() => _eveningReminder = v),
            id: 103,
          ),
          _divider(),
          _notifTile(
            icon: Icons.nightlight,
            iconColor: const Color(0xFF9C88FF),
            title: 'Evening Review',
            subtitle: '9:00 PM — Review progress for the day',
            value: _nightReview,
            onChanged: (v) => setState(() => _nightReview = v),
            id: 104,
          ),
        ],
      ),
    );
  }

  Widget _notifTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required int id,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title:
          Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      value: value,
      activeThumbColor: AppTheme.primary,
      onChanged: (v) async {
        onChanged(v);
        if (!v) {
          await NotificationService.cancel(id);
        } else {
          await NotificationService.scheduleDefaultReminders();
        }
      },
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 1, color: AppTheme.background, indent: 16);

  Widget _buildXPGuide() {
    final items = [
      ('Complete a task', '+20–40 XP', Icons.task_alt, AppTheme.studyColor),
      ('Study session', '+30 XP', Icons.book, AppTheme.primary),
      ('Solve coding problem', '+20 XP', Icons.code, AppTheme.codingColor),
      ('Complete assignment', '+40 XP', Icons.assignment_turned_in, AppTheme.assignmentColor),
      ('Daily streak', '+10 XP/day', Icons.local_fire_department, Colors.orange),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.map((item) {
          final (label, xp, icon, color) = item;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            title: Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14)),
            trailing: Text(xp,
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow('App Name', 'BlessyForge'),
          _infoRow('Version', '1.0.0'),
          _infoRow('Developer', 'Blessy'),
          _infoRow('Purpose', 'IBM & GATE Prep Tracker'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await NotificationService.scheduleDefaultReminders();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All daily reminders scheduled! ✅'),
                  backgroundColor: AppTheme.studyColor,
                ),
              );
            }
          },
          icon: const Icon(Icons.notifications_active),
          label: const Text('Schedule All Reminders'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text('Send Test Notification',
                    style: TextStyle(color: AppTheme.textPrimary)),
                content: const Text(
                    'Send a motivational notification right now?',
                    style: TextStyle(color: AppTheme.textSecondary)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Send')),
                ],
              ),
            );
            if (confirm == true) {
              await NotificationService.showNow(
                id: 999,
                title: 'BlessyForge 🔥',
                body: 'Stay consistent and forge your future, Blessy!',
              );
            }
          },
          icon: const Icon(Icons.send),
          label: const Text('Test Notification'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.secondary,
            side: const BorderSide(color: AppTheme.secondary),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}
