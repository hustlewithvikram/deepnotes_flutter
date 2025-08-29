import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _enableBiometrics = false;
  bool _autoSync = true;
  bool _backupEnabled = true;
  bool _autoLock = true;
  bool _cloudBackup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // For now, load from local storage only
    // You can integrate the SettingsService later
    setState(() {
      _enableBiometrics = false;
      _autoSync = true;
      _backupEnabled = true;
      _autoLock = true;
      _cloudBackup = true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    // Simple implementation - you can integrate SettingsService here later
    setState(() {
      switch (key) {
        case 'enableBiometrics':
          _enableBiometrics = value;
          break;
        case 'autoSync':
          _autoSync = value;
          break;
        case 'backupEnabled':
          _backupEnabled = value;
          break;
        case 'autoLock':
          _autoLock = value;
          break;
        case 'cloudBackup':
          _cloudBackup = value;
          break;
      }
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void _shareApp() {
    Share.share(
      'Check out DeepNotes - the best note-taking app! '
      'Download it from: https://example.com/deepnotes',
    );
  }

  void _showBackupOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Options'),
        content: const Text('Choose your backup method:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Google Drive'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Local Storage'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Text('We\'d love to hear your thoughts!'),
        actions: [
          TextButton(
            onPressed: () {
              _launchURL('mailto:support@deepnotes.com?subject=Feedback');
              Navigator.pop(context);
            },
            child: const Text('Email'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Section
          _buildSectionHeader('Security', theme),
          _buildSwitchTile(
            title: 'Biometric Lock',
            subtitle: 'Use fingerprint or face ID to secure your notes',
            value: _enableBiometrics,
            settingKey: 'enableBiometrics',
            icon: Icons.fingerprint,
          ),
          _buildSwitchTile(
            title: 'Auto Lock',
            subtitle: 'Lock app automatically after 5 minutes',
            value: _autoLock,
            settingKey: 'autoLock',
            icon: Icons.lock_clock,
          ),

          const SizedBox(height: 24),

          // Sync & Backup Section
          _buildSectionHeader('Sync & Backup', theme),
          _buildSwitchTile(
            title: 'Auto Sync',
            subtitle: 'Automatically sync notes across devices',
            value: _autoSync,
            settingKey: 'autoSync',
            icon: Icons.sync,
          ),
          _buildSwitchTile(
            title: 'Cloud Backup',
            subtitle: 'Backup your notes to the cloud',
            value: _cloudBackup,
            settingKey: 'cloudBackup',
            icon: Icons.cloud_upload,
          ),
          ListTile(
            leading: Icon(Icons.backup, color: colorScheme.primary),
            title: const Text('Backup Now'),
            subtitle: const Text('Create a manual backup'),
            onTap: _showBackupOptions,
            trailing: const Icon(Icons.chevron_right),
          ),

          const SizedBox(height: 24),

          // App Section
          _buildSectionHeader('App', theme),
          ListTile(
            leading: Icon(Icons.share, color: colorScheme.primary),
            title: const Text('Share App'),
            subtitle: const Text('Tell others about DeepNotes'),
            onTap: _shareApp,
          ),
          ListTile(
            leading: Icon(Icons.star, color: colorScheme.primary),
            title: const Text('Rate App'),
            subtitle: const Text('Leave a review on the app store'),
            onTap: () => _launchURL('https://example.com/rate'),
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: colorScheme.primary),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            onTap: _showFeedbackDialog,
          ),
          ListTile(
            leading: Icon(Icons.help, color: colorScheme.primary),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help using the app'),
            onTap: () => _launchURL('https://example.com/support'),
          ),

          const SizedBox(height: 24),

          // Legal Section
          _buildSectionHeader('Legal', theme),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
            title: const Text('Privacy Policy'),
            onTap: () => _launchURL('https://example.com/privacy'),
          ),
          ListTile(
            leading: Icon(Icons.description, color: colorScheme.primary),
            title: const Text('Terms of Service'),
            onTap: () => _launchURL('https://example.com/terms'),
          ),
          ListTile(
            leading: Icon(Icons.copyright, color: colorScheme.primary),
            title: const Text('Licenses'),
            onTap: () => showLicensePage(context: context),
          ),

          const SizedBox(height: 24),

          // App Info
          _buildSectionHeader('About', theme),
          ListTile(
            leading: Icon(Icons.info, color: colorScheme.primary),
            title: const Text('Version'),
            subtitle: const Text('1.0.0 (build 1)'),
          ),
          ListTile(
            leading: Icon(Icons.update, color: colorScheme.primary),
            title: const Text('Check for Updates'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checking for updates...')),
              );
            },
          ),

          const SizedBox(height: 32),

          // Data Management
          _buildSectionHeader('Data', theme),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Clear Cache',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete All Notes',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Add confirmation dialog here
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required String settingKey,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) {
        _saveSetting(settingKey, newValue);
      },
      secondary: Icon(icon, color: colorScheme.primary),
      activeThumbColor: colorScheme.primary,
    );
  }
}
