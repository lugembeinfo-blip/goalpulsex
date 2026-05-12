import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../services/favorites_provider.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final String selectedFilter;

  const MatchCard({
    super.key,
    required this.match,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.leagueName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Consumer<FavoritesProvider>(
                      builder: (context, provider, child) {
                        final isFav = provider.isFavorite(match.id);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                            size: 22,
                          ),
                          onPressed: () => provider.toggleFavorite(match),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (selectedFilter == "Live")
                      ? Colors.redAccent.withOpacity(0.15)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  (selectedFilter == "Live")
                      ? "LIVE ${match.displayStatus}"
                      : match.displayStatus,
                  style: TextStyle(
                    color: (selectedFilter == "Live")
                        ? Colors.redAccent
                        : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(match.homeTeamLogo),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            match.homeTeamName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Consumer<FavoritesProvider>(
                          builder: (context, provider, child) {
                            final isFav = provider.isFavoriteTeam(match.homeTeamName);
                            return GestureDetector(
                              onTap: () => provider.toggleFavoriteTeam(match.homeTeamName),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  isFav ? Icons.star : Icons.star_border,
                                  color: isFav ? Colors.yellowAccent : Colors.white24,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      match.homeGoals.toString(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "-",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Text(
                      match.awayGoals.toString(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(match.awayTeamLogo),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            match.awayTeamName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Consumer<FavoritesProvider>(
                          builder: (context, provider, child) {
                            final isFav = provider.isFavoriteTeam(match.awayTeamName);
                            return GestureDetector(
                              onTap: () => provider.toggleFavoriteTeam(match.awayTeamName),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  isFav ? Icons.star : Icons.star_border,
                                  color: isFav ? Colors.yellowAccent : Colors.white24,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: 50,
      placeholder: (context, url) => const SizedBox(
        height: 50,
        width: 50,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.greenAccent,
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.sports_soccer,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}
