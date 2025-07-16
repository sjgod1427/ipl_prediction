import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getPrediction({
  required String battingTeam,
  required String bowlingTeam,
  required String city,
  required int runsLeft,
  required int ballsLeft,
  required int wickets,
  required int totalRuns,
  required double currentRR,
  required double requiredRR,
}) async {
  final url = Uri.parse(
    'http://192.168.1.2:8000/predict',
  ); // Replace with your actual IP

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "batting_team": battingTeam,
      "bowling_team": bowlingTeam,
      "city": city,
      "runs_left": runsLeft,
      "balls_left": ballsLeft,
      "wickets": wickets,
      "total_runs_x": totalRuns,
      "current_rate": currentRR,
      "rrr": requiredRR,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print(response.statusCode);
    throw Exception("Failed to get prediction");
  }
}
