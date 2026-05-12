import 'package:flutter/material.dart';
import 'services/notification_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'screens/news_page.dart';
import 'screens/notifications_page.dart';
import 'screens/settings_page.dart';
import 'services/favorites_provider.dart';
import 'services/theme_provider.dart';
import 'widgets/match_card.dart';
import 'models/news_model.dart';
import 'models/match_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint("Background notification: ${message.notification?.title}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint("Foreground notification: ${message.notification?.title}");
    }

    final title = message.notification?.title ?? "Notification";
    final body = message.notification?.body ?? "";

    await NotificationStore.saveNotification(
      title: title,
      body: body,
    );

    print("NOTIFICATION SAVED");
  });

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Subscribe to global live updates topic for automatic notifications
  await FirebaseMessaging.instance.subscribeToTopic("live_updates");

  final token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    debugPrint("FCM TOKEN: $token");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const GoalPulseX(),
    ),
  );
}

class GoalPulseX extends StatelessWidget {
  const GoalPulseX({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GoalPulseX',
          theme: ThemeData(
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: themeProvider.isDarkMode ? const Color(0xFF0D0D0D) : Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: const MainContainer(),
        );
      },
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  bool autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    // Handling message when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.greenAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.notification!.title ?? "GoalPulseX Update",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  message.notification!.body ?? "",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // Handling message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App opened from notification: ${message.data}");
      // You can add navigation logic here, e.g., go to News tab
      setState(() {
        _selectedIndex = 2; // Switch to News tab
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = HomePage(autoRefreshEnabled: autoRefreshEnabled);
        break;
      case 1:
        currentScreen = const FavoritesScreen();
        break;
      case 2:
        currentScreen = const NewsPage();
        break;
      case 3:
        currentScreen = SettingsPage(
          autoRefreshEnabled: autoRefreshEnabled,
          onAutoRefreshChanged: (val) {
            setState(() {
              autoRefreshEnabled = val;
            });
          },
        );
        break;
      default:
        currentScreen = HomePage(autoRefreshEnabled: autoRefreshEnabled);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "GoalPulseX",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Matches"),
              Tab(text: "News"),
            ],
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white54,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFavoriteMatches(),
                _buildFavoriteNews(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteMatches() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        if (provider.favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, color: Colors.white54, size: 80),
                SizedBox(height: 16),
                Text(
                  "No favorite matches yet",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            final match = provider.favorites[index];
            return MatchCard(
              match: match,
              selectedFilter: "Finished",
            );
          },
        );
      },
    );
  }

  Widget _buildFavoriteNews() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        if (provider.favoriteNews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, color: Colors.white54, size: 80),
                SizedBox(height: 16),
                Text(
                  "No favorite news yet",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.favoriteNews.length,
          itemBuilder: (context, index) {
            final article = provider.favoriteNews[index];
            return _FavoriteNewsCard(article: article);
          },
        );
      },
    );
  }
}

class _FavoriteNewsCard extends StatelessWidget {
  final NewsModel article;

  const _FavoriteNewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: article.image,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              color: Colors.black26,
              width: 80,
              height: 80,
              child: const Icon(Icons.image, color: Colors.white38),
            ),
          ),
        ),
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          article.date,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.redAccent),
          onPressed: () => Provider.of<FavoritesProvider>(context, listen: false).toggleFavoriteNews(article),
        ),
      ),
    );
  }
}
