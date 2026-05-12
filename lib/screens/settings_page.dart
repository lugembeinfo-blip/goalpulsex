import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    "Swahili": {
      "darkMode": "Hali ya Giza",
      "notifications": "Arifa",
      "language": "Lugha",
      "timekeeping": "Mpangilio wa Muda",
      "about": "Kuhusu GoalPulseX",
      "logout": "Toka",
      "selectLanguage": "Chagua Lugha",
      "timezone": "Ukanda wa Muda",
      "timeFormat": "Muundo wa Muda",
      "autoRefresh": "Jisasishe Kiotomatiki",
      "refreshEvery": "Sasisha matokeo kila sekunde 30",
      "cancel": "Ghairi",
      "logoutQuestion": "Una uhakika unataka kutoka?",
      "loggedOut": "Umetoka kikamilifu",
    },
    "Spanish": {
      "darkMode": "Modo Oscuro",
      "notifications": "Notificaciones",
      "language": "Idioma",
      "timekeeping": "Control de Tiempo",
      "about": "Acerca de GoalPulseX",
      "logout": "Cerrar sesión",
      "selectLanguage": "Seleccionar idioma",
      "timezone": "Zona horaria",
      "timeFormat": "Formato de hora",
      "autoRefresh": "Actualización automática",
      "refreshEvery": "Actualizar resultados cada 30s",
      "cancel": "Cancelar",
      "logoutQuestion": "¿Seguro que quieres cerrar sesión?",
      "loggedOut": "Sesión cerrada correctamente",
    },
    "French": {
      "darkMode": "Mode Sombre",
      "notifications": "Notifications",
      "language": "Langue",
      "timekeeping": "Gestion du Temps",
      "about": "À propos de GoalPulseX",
      "logout": "Déconnexion",
      "selectLanguage": "Choisir la langue",
      "timezone": "Fuseau horaire",
      "timeFormat": "Format de l’heure",
      "autoRefresh": "Actualisation auto",
      "refreshEvery": "Actualiser les scores toutes les 30s",
      "cancel": "Annuler",
      "logoutQuestion": "Voulez-vous vraiment vous déconnecter ?",
      "loggedOut": "Déconnexion réussie",
    },
    "Arabic": {
      "darkMode": "الوضع الداكن",
      "notifications": "الإشعارات",
      "language": "اللغة",
      "timekeeping": "ضبط الوقت",
      "about": "حول GoalPulseX",
      "logout": "تسجيل الخروج",
      "selectLanguage": "اختر اللغة",
      "timezone": "المنطقة الزمنية",
      "timeFormat": "تنسيق الوقت",
      "autoRefresh": "تحديث تلقائي",
      "refreshEvery": "تحديث النتائج كل 30 ثانية",
      "cancel": "إلغاء",
      "logoutQuestion": "هل أنت متأكد أنك تريد تسجيل الخروج؟",
      "loggedOut": "تم تسجيل الخروج بنجاح",
    },

    "Portuguese": {
      "darkMode": "Modo Escuro",
      "notifications": "Notificações",
      "language": "Idioma",
      "timekeeping": "Controle de Tempo",
      "about": "Sobre GoalPulseX",
      "logout": "Sair",
      "selectLanguage": "Selecionar idioma",
      "timezone": "Fuso horário",
      "timeFormat": "Formato de hora",
      "autoRefresh": "Atualização automática",
      "refreshEvery": "Atualizar resultados a cada 30s",
      "cancel": "Cancelar",
      "logoutQuestion": "Tem certeza que deseja sair?",
      "loggedOut": "Sessão encerrada com sucesso",
    },

    "German": {
      "darkMode": "Dunkler Modus",
      "notifications": "Benachrichtigungen",
      "language": "Sprache",
      "timekeeping": "Zeitverwaltung",
      "about": "Über GoalPulseX",
      "logout": "Abmelden",
      "selectLanguage": "Sprache auswählen",
      "timezone": "Zeitzone",
      "timeFormat": "Zeitformat",
      "autoRefresh": "Automatisch aktualisieren",
      "refreshEvery": "Live-Ergebnisse alle 30s aktualisieren",
      "cancel": "Abbrechen",
      "logoutQuestion": "Möchtest du dich wirklich abmelden?",
      "loggedOut": "Erfolgreich abgemeldet",
    },

    "Italian": {
      "darkMode": "Modalità Scura",
      "notifications": "Notifiche",
      "language": "Lingua",
      "timekeeping": "Gestione Tempo",
      "about": "Informazioni su GoalPulseX",
      "logout": "Esci",
      "selectLanguage": "Seleziona lingua",
      "timezone": "Fuso orario",
      "timeFormat": "Formato ora",
      "autoRefresh": "Aggiornamento automatico",
      "refreshEvery": "Aggiorna risultati ogni 30s",
      "cancel": "Annulla",
      "logoutQuestion": "Sei sicuro di voler uscire?",
      "loggedOut": "Disconnessione riuscita",
    },
  };

  String t(String key) {
    return translations[selectedLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    autoRefreshEnabled = widget.autoRefreshEnabled;
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
            onChanged: (val) {
              themeProvider.toggleTheme(val);
            },
            activeColor: Colors.greenAccent,
          ),
        ),
        SettingTile(
          icon: Icons.notifications,
          title: t("notifications"),
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() {
                notificationsEnabled = val;
              });
            },
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
              title: Text(
                lang,
                style: const TextStyle(color: Colors.white),
              ),
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
                  title: Text(
                    t("timezone"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    selectedTimezone,
                    style: const TextStyle(color: Colors.white54),
                  ),
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
                  title: Text(
                    t("timeFormat"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    selectedTimeFormat,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    setState(() {
                      selectedTimeFormat =
                      selectedTimeFormat == "24-hour"
                          ? "12-hour"
                          : "24-hour";
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
                  title: Text(
                    t("autoRefresh"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    t("refreshEvery"),
                    style: const TextStyle(color: Colors.white54),
                  ),
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
        title: Text(
          t("logout"),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          t("logoutQuestion"),
          style: const TextStyle(color: Colors.white70),
        ),
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
            child: Text(
              t("logout"),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}