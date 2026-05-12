import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/match_model.dart';
import '../widgets/match_card.dart';
import '../widgets/filter_button.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final bool autoRefreshEnabled;

  const HomePage({
    super.key,
    required this.autoRefreshEnabled,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<MatchModel>> matches;
  List<MatchModel> allMatches = [];
  List<MatchModel> displayedMatches = [];
  String selectedFilter = "Live";
  final TextEditingController _searchController = TextEditingController();
  Timer? _refreshTimer;
  bool autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (autoRefreshEnabled && selectedFilter == "Live") {
          if (kDebugMode) {
            print("AUTO REFRESH FETCH: ${DateTime.now()}");
          }
          _fetchMatches();
        }
      },
    );
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoRefreshEnabled != oldWidget.autoRefreshEnabled) {
      setState(() {
        autoRefreshEnabled = widget.autoRefreshEnabled;
      });
    }
  }

  void _fetchMatches() {
    matches = ApiService().getMatches(selectedFilter);
    matches.then((data) {
      if (mounted) {
        setState(() {
          allMatches = data;
          _onSearchChanged(_searchController.text);
        });
      }
    }).catchError((error) {
       // Error handled by FutureBuilder
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      _searchController.clear();
      _fetchMatches();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      displayedMatches = allMatches.where((match) {
        final homeTeam = match.homeTeamName.toLowerCase();
        final awayTeam = match.awayTeamName.toLowerCase();
        final leagueName = match.leagueName.toLowerCase();
        final searchLower = query.toLowerCase();
        final normalizedSearch = searchLower == "nbc" ? "ligi kuu bara" : searchLower;

        return homeTeam.contains(normalizedSearch) ||
            awayTeam.contains(normalizedSearch) ||
            leagueName.contains(normalizedSearch);
      }).toList();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "🔍 Search teams/leagues",
              hintStyle: const TextStyle(color: Colors.white54),
              fillColor: const Color(0xFF1A1A1A),
              filled: true,
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged("");
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white54,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        // Filter Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilterButton(
              title: "Live",
              isActive: selectedFilter == "Live",
              onTap: () => _onFilterChanged("Live"),
            ),
            FilterButton(
              title: "Finished",
              isActive: selectedFilter == "Finished",
              onTap: () => _onFilterChanged("Finished"),
            ),
            FilterButton(
              title: "Upcoming",
              isActive: selectedFilter == "Upcoming",
              onTap: () => _onFilterChanged("Upcoming"),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Matches List
        Expanded(
          child: FutureBuilder<List<MatchModel>>(
            future: matches,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && allMatches.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                );
              }

              if (snapshot.hasError && allMatches.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: _fetchMatches,
                          child: const Text("Retry", style: TextStyle(color: Colors.greenAccent)),
                        )
                      ],
                    ),
                  ),
                );
              }

              if (displayedMatches.isEmpty) {
                return const Center(
                  child: Text(
                    "No matches found",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _fetchMatches();
                  await matches;
                },
                color: Colors.greenAccent,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedMatches.length,
                  itemBuilder: (context, index) {
                    final match = displayedMatches[index];
                    return MatchCard(
                      match: match,
                      selectedFilter: selectedFilter,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
