import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/setting_tile.dart';
import '../services/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onAutoRefreshChanged;
  final bool autoRefreshEnabled;

  const SettingsPage({
    super.key,
    required this.onAutoRefreshChanged,
    required this.autoRefreshEnabled,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String selectedLanguage = "English";
  String selectedTimezone = "Device Local Time";
  String selectedTimeFormat = "24-hour";
  late bool autoRefreshEnabled;

  @override
  void initState() {
    super.initState();
    autoRefreshEnabled = widget.autoRefreshEnabled;
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("notifications_enabled") ?? true;

    setState(() {
      notificationsEnabled = saved;
    });

    if (saved) {
      await FirebaseMessaging.instance.subscribeToTopic("goal_alerts");
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic("goal_alerts");
    }
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      notificationsEnabled = val;
    });

    await prefs.setBool("notifications_enabled", val);

    if (val) {
      await FirebaseMessaging.instance.subscribeToTopic("goal_alerts");
      await FirebaseMessaging.instance.subscribeToTopic("live_updates");
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic("goal_alerts");
      await FirebaseMessaging.instance.unsubscribeFromTopic("live_updates");
    }
  }

  final Map<String, Map<String, String>> translations = {
    "English": {
      "darkMode": "Dark Mode",
      "notifications": "Notifications",
      "language": "Language",
      "timekeeping": "Timekeeping",
      "about": "About GoalPulseX",
      "logout": "Logout",
      "selectLanguage": "Select Language",
      "timezone": "Timezone",
      "timeFormat": "Time Format",
      "autoRefresh": "Auto Refresh",
      "refreshEvery": "Refresh live scores every 30s",
      "cancel": "Cancel",
      "logoutQuestion": "Are you sure you want to logout?",
      "loggedOut": "Logged out successfully",
    },
  };

  String t(String key) {
    return translations[selectedLanguage]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SettingTile(
          icon: Icons.dark_mode,
          title: t("darkMode"),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
            activeColor: Colors.greenAccent,
          ),
        ),
        SettingTile(
          icon: Icons.notifications,
          title: t("notifications"),
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: _toggleNotifications,
            activeColor: Colors.greenAccent,
          ),
        ),
        SettingTile(
          icon: Icons.language,
          title: t("language"),
          subtitle: selectedLanguage,
          onTap: _showLanguageDialog,
        ),
        SettingTile(
          icon: Icons.access_time,
          title: t("timekeeping"),
          subtitle: "$selectedTimezone • $selectedTimeFormat",
          onTap: _showTimekeepingDialog,
        ),
        SettingTile(
          icon: Icons.info,
          title: t("about"),
          onTap: _showAboutDialog,
        ),
        SettingTile(
          icon: Icons.logout,
          title: t("logout"),
          textColor: Colors.redAccent,
          onTap: _showLogoutDialog,
        ),
        const SizedBox(height: 30),
        const Center(
          child: Text(
            "GoalPulseX v1.0.0",
            style: TextStyle(color: Colors.white38),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    final languages = translations.keys.toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          t("selectLanguage"),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return ListTile(
              title: Text(lang, style: const TextStyle(color: Colors.white)),
              trailing: selectedLanguage == lang
                  ? const Icon(Icons.check, color: Colors.greenAccent)
                  : null,
              onTap: () {
                setState(() {
                  selectedLanguage = lang;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimekeepingDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              t("timekeeping"),
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.public, color: Colors.greenAccent),
                  title: Text(t("timezone"),
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(selectedTimezone,
                      style: const TextStyle(color: Colors.white54)),
                  onTap: () {
                    setState(() {
                      selectedTimezone = "Device Local Time";
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading:
                  const Icon(Icons.schedule, color: Colors.greenAccent),
                  title: Text(t("timeFormat"),
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(selectedTimeFormat,
                      style: const TextStyle(color: Colors.white54)),
                  onTap: () {
                    setState(() {
                      selectedTimeFormat =
                      selectedTimeFormat == "24-hour" ? "12-hour" : "24-hour";
                    });
                    Navigator.pop(context);
                  },
                ),
                SwitchListTile(
                  activeColor: Colors.greenAccent,
                  value: autoRefreshEnabled,
                  onChanged: (val) {
                    setState(() {
                      autoRefreshEnabled = val;
                    });
                    setDialogState(() {});
                    widget.onAutoRefreshChanged(val);
                  },
                  title: Text(t("autoRefresh"),
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(t("refreshEvery"),
                      style: const TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "GoalPulseX",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(
        Icons.sports_soccer,
        color: Colors.greenAccent,
        size: 40,
      ),
      children: const [
        Text(
          "GoalPulseX is your ultimate destination for live football scores, news, and updates from across the globe.",
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(t("logout"), style: const TextStyle(color: Colors.white)),
        content: Text(t("logoutQuestion"),
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t("cancel")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t("loggedOut"))),
              );
            },
            child:
            Text(t("logout"), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}