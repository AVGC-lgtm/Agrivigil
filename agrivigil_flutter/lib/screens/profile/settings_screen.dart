import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification Settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _inspectionReminders = true;
  bool _reportAlerts = true;
  bool _seizureUpdates = true;
  
  // App Settings
  bool _darkMode = false;
  bool _biometricAuth = false;
  bool _offlineMode = false;
  bool _autoSync = true;
  String _language = 'English';
  String _syncFrequency = 'Every hour';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Notification Settings
              _buildSection(
                'Notifications',
                Icons.notifications,
                [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive notifications via email'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('SMS Notifications'),
                    subtitle: const Text('Receive notifications via SMS'),
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() => _smsNotifications = value);
                    },
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Notification Types',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Inspection Reminders'),
                    value: _inspectionReminders,
                    onChanged: _pushNotifications
                        ? (value) {
                            setState(() => _inspectionReminders = value);
                          }
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('Report Alerts'),
                    value: _reportAlerts,
                    onChanged: _pushNotifications
                        ? (value) {
                            setState(() => _reportAlerts = value);
                          }
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('Seizure Updates'),
                    value: _seizureUpdates,
                    onChanged: _pushNotifications
                        ? (value) {
                            setState(() => _seizureUpdates = value);
                          }
                        : null,
                  ),
                ],
              ),
              
              // App Settings
              _buildSection(
                'App Preferences',
                Icons.phone_android,
                [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                      _showRestartDialog();
                    },
                  ),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(_language),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageDialog,
                  ),
                  SwitchListTile(
                    title: const Text('Biometric Authentication'),
                    subtitle: const Text('Use fingerprint/face unlock'),
                    value: _biometricAuth,
                    onChanged: (value) {
                      setState(() => _biometricAuth = value);
                    },
                  ),
                ],
              ),
              
              // Data & Sync
              _buildSection(
                'Data & Sync',
                Icons.sync,
                [
                  SwitchListTile(
                    title: const Text('Offline Mode'),
                    subtitle: const Text('Work without internet connection'),
                    value: _offlineMode,
                    onChanged: (value) {
                      setState(() => _offlineMode = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Automatically sync data'),
                    value: _autoSync,
                    onChanged: (value) {
                      setState(() => _autoSync = value);
                    },
                  ),
                  ListTile(
                    title: const Text('Sync Frequency'),
                    subtitle: Text(_syncFrequency),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    enabled: _autoSync,
                    onTap: _autoSync ? _showSyncFrequencyDialog : null,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload, color: AppTheme.primaryColor),
                    title: const Text('Sync Now'),
                    subtitle: const Text('Last synced: 2 hours ago'),
                    onTap: _syncNow,
                  ),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services, color: Colors.orange),
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Free up storage space'),
                    onTap: _clearCache,
                  ),
                ],
              ),
              
              // Privacy & Security
              _buildSection(
                'Privacy & Security',
                Icons.security,
                [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Open terms of service
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Reset App'),
                    subtitle: const Text('Clear all data and settings'),
                    onTap: _resetApp,
                  ),
                ],
              ),
              
              // About
              _buildSection(
                'About',
                Icons.info,
                [
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0 (Build 100)'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text('Check for Updates'),
                    onTap: _checkForUpdates,
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Send Feedback'),
                    onTap: _sendFeedback,
                  ),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Rate App'),
                    onTap: () {
                      // TODO: Open app store for rating
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                _showRestartDialog();
              },
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी'),
              value: 'Hindi',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                _showRestartDialog();
              },
            ),
            RadioListTile<String>(
              title: const Text('मराठी'),
              value: 'Marathi',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                _showRestartDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Every 30 minutes'),
              value: 'Every 30 minutes',
              groupValue: _syncFrequency,
              onChanged: (value) {
                setState(() => _syncFrequency = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Every hour'),
              value: 'Every hour',
              groupValue: _syncFrequency,
              onChanged: (value) {
                setState(() => _syncFrequency = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Every 6 hours'),
              value: 'Every 6 hours',
              groupValue: _syncFrequency,
              onChanged: (value) {
                setState(() => _syncFrequency = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Once a day'),
              value: 'Once a day',
              groupValue: _syncFrequency,
              onChanged: (value) {
                setState(() => _syncFrequency = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestartDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restart app to apply changes'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _syncNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing data...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text(
          'This will clear all data and reset the app to default settings. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement reset logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App is up to date'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter your feedback here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Feedback sent successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
