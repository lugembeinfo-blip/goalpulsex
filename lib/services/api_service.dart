import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';
import '../models/news_model.dart';

class ApiService {
  final String apiKey = "459c95e5470e53e6be91053bc24d39e6";

  final String newsApiKey = "a150365a0c14417491ce8d8b073dc156"; // Replace with your NewsAPI.org key

  Future<List<MatchModel>> getMatches(String filter) async {
    String url;

    final String today = _today();

    if (filter == "Live") {
      url = "https://v3.football.api-sports.io/fixtures?live=all";
    } else if (filter == "Finished") {
      url = "https://v3.football.api-sports.io/fixtures?date=$today";
    } else {
      url = "https://v3.football.api-sports.io/fixtures?date=$today";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "x-apisports-key": apiKey,
      },
    ).timeout(const Duration(seconds: 15));

    if (kDebugMode) {
      debugPrint("REQUEST URL: $url");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check for API-specific errors (like request limit)
      if (data["errors"] is Map && (data["errors"] as Map).isNotEmpty) {
        final errorMsg = (data["errors"] as Map).values.first.toString();
        throw Exception(errorMsg);
      }

      final List responseData = data["response"] ?? [];

      List<MatchModel> matches =
          responseData.map((e) => MatchModel.fromJson(e)).toList();

      if (filter == "Finished") {
        matches = matches.where((match) {
          return match.statusShort == "FT" ||
              match.statusShort == "AET" ||
              match.statusShort == "PEN";
        }).toList();
      }

      if (filter == "Upcoming") {
        matches = matches.where((match) {
          return match.statusShort == "NS" || match.statusShort == "TBD";
        }).toList();
      }

      return matches;
    }

    throw Exception("Failed to load matches: ${response.statusCode}");
  }

  Future<List<NewsModel>> getFootballNews() async {
    if (newsApiKey == "YOUR_NEWS_API_KEY") {
      // Fallback to mock data if no key is provided
      return _getMockNews();
    }

    try {
      final url =
          "https://newsapi.org/v2/everything?q=(football OR soccer OR FIFA OR UEFA OR Premier League OR La Liga OR Serie A OR Bundesliga OR Ligue 1 OR CAF OR Champions League)&language=en&sortBy=publishedAt&apiKey=$newsApiKey";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List articles = data["articles"] ?? [];

        return articles.map((article) {
          return NewsModel(
            title: article["title"] ?? "No Title",
            image: article["urlToImage"] ?? "",
            description: article["description"] ?? "",
            date: _formatNewsDate(article["publishedAt"]),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching real news: $e");
    }

    return _getMockNews();
  }

  String _formatNewsDate(String? isoDate) {
    if (isoDate == null) return "Unknown date";
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} mins ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else {
        return "${difference.inDays} days ago";
      }
    } catch (e) {
      return "Recently";
    }
  }

  Future<List<NewsModel>> _getMockNews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // ignore: spell_check_on_languages
    return [
      NewsModel(
        title: "Simba SC prepare for NBC Premier League clash",
        image:
            "https://upload.wikimedia.org/wikipedia/en/5/53/Simba_SC_Logo.png",
        description:
            "Simba SC continue preparations ahead of this weekend's NBC Premier League fixture.",
        date: "2 hours ago",
      ),
      NewsModel(
        title: "Yanga win big in CAF Confederation Cup",
        image:
            "https://upload.wikimedia.org/wikipedia/en/6/65/Young_Africans_SC_logo.png",
        description:
            "Young Africans secured an important victory in continental competition.",
        date: "5 hours ago",
      ),
      NewsModel(
        title: "Arsenal signs new striker",
        image: "https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg",
        description:
            "Arsenal officially announced the signing of a new striker today.",
        date: "1 day ago",
      ),
    ];
  }

  String _today() {
    final now = DateTime.now();

    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
