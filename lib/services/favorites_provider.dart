import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/news_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<MatchModel> _favorites = [];
  final List<String> _favoriteTeams = [];
  final List<NewsModel> _favoriteNews = [];

  List<MatchModel> get favorites => _favorites;
  List<String> get favoriteTeams => _favoriteTeams;
  List<NewsModel> get favoriteNews => _favoriteNews;

  void toggleFavorite(MatchModel match) {
    final index = _favorites.indexWhere((m) => m.id == match.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(match);
    }
    notifyListeners();
  }

  void toggleFavoriteTeam(String teamName) {
    if (_favoriteTeams.contains(teamName)) {
      _favoriteTeams.remove(teamName);
    } else {
      _favoriteTeams.add(teamName);
    }
    notifyListeners();
  }

  void toggleFavoriteNews(NewsModel article) {
    final index = _favoriteNews.indexWhere((n) => n.title == article.title);
    if (index >= 0) {
      _favoriteNews.removeAt(index);
    } else {
      _favoriteNews.add(article);
    }
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _favorites.any((m) => m.id == id);
  }

  bool isFavoriteTeam(String teamName) {
    return _favoriteTeams.contains(teamName);
  }

  bool isFavoriteNews(String title) {
    return _favoriteNews.any((n) => n.title == title);
  }
}
