class MatchModel {
  final int id;
  final String leagueName;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int homeGoals;
  final int awayGoals;
  final String statusShort;
  final int? elapsed;

  MatchModel({
    required this.id,
    required this.leagueName,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeGoals,
    required this.awayGoals,
    required this.statusShort,
    this.elapsed,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['fixture']['id'],
      leagueName: json['league']['name'],
      homeTeamName: json['teams']['home']['name'],
      awayTeamName: json['teams']['away']['name'],
      homeTeamLogo: json['teams']['home']['logo'],
      awayTeamLogo: json['teams']['away']['logo'],
      homeGoals: json['goals']['home'] ?? 0,
      awayGoals: json['goals']['away'] ?? 0,
      statusShort: json['fixture']['status']['short'],
      elapsed: json['fixture']['status']['elapsed'],
    );
  }

  String get displayStatus {
    if (statusShort == "1H" || statusShort == "2H") {
      return "$elapsed'";
    } else if (statusShort == "HT") {
      return "HT";
    } else if (statusShort == "FT") {
      return "FT";
    } else if (statusShort == "ET") {
      return "ET";
    } else if (statusShort == "P") {
      return "PEN";
    } else if (statusShort == "NS") {
      return "Upcoming";
    } else {
      return statusShort;
    }
  }
}
