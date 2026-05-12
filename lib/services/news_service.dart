import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String apiKey = "087c4cc3eb444bce85acc008609885c0";

  static Future<List<dynamic>> fetchFootballNews() async {
    final query = Uri.encodeComponent(
      '(football OR soccer OR "Premier League" OR "Champions League" OR "La Liga" OR "Serie A" OR "CAF" OR "Yanga" OR "Simba") NOT Netflix NOT movie NOT film',
    );

    final url = Uri.parse(
      "https://newsapi.org/v2/everything?q=$query&language=en&sortBy=publishedAt&pageSize=30&apiKey=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final articles = data["articles"] ?? [];

      return articles.where((article) {
        final title = (article["title"] ?? "").toString().toLowerCase();
        final desc = (article["description"] ?? "").toString().toLowerCase();

        final text = "$title $desc";

        final isFootball = text.contains("football") ||
            text.contains("soccer") ||
            text.contains("premier league") ||
            text.contains("champions league") ||
            text.contains("la liga") ||
            text.contains("serie a") ||
            text.contains("caf") ||
            text.contains("yanga") ||
            text.contains("simba");

        final isBad = text.contains("netflix") ||
            text.contains("movie") ||
            text.contains("film") ||
            text.contains("tv show");

        return isFootball && !isBad;
      }).toList();
    } else {
      throw Exception("Failed to load football news");
    }
  }
}