import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/api_config.dart';

Map<String, String> _headers(String token) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};
class ChessPlayer {
  final int id;
  final String name;
  final String? profileImage;
  const ChessPlayer({required this.id, required this.name, this.profileImage});
  factory ChessPlayer.fromJson(Map<String, dynamic> j) => ChessPlayer(
    id: j['id'] as int,
    name: j['name'] as String,
    profileImage: j['profile_image'] as String?,
  );
}

class ChessGameModel {
  final int id;
  final ChessPlayer whitePlayer;
  final ChessPlayer blackPlayer;
  final String? myColor; 
  final String fen;
  final List<String> moves;
  final String status;
  final int? winnerId;
  final String? result; 
  final String? updatedAt;

  const ChessGameModel({
    required this.id,
    required this.whitePlayer,
    required this.blackPlayer,
    this.myColor,
    required this.fen,
    required this.moves,
    required this.status,
    this.winnerId,
    this.result,
    this.updatedAt,
  });

  factory ChessGameModel.fromJson(Map<String, dynamic> j) => ChessGameModel(
    id: j['id'] as int,
    whitePlayer: ChessPlayer.fromJson(
      j['white_player'] as Map<String, dynamic>,
    ),
    blackPlayer: ChessPlayer.fromJson(
      j['black_player'] as Map<String, dynamic>,
    ),
    myColor: j['my_color'] as String?,
    fen:
        j['fen'] as String? ??
        'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    moves: (j['moves'] as List?)?.map((e) => e.toString()).toList() ?? [],
    status: j['status'] as String? ?? 'waiting',
    winnerId: j['winner_id'] as int?,
    result: j['result'] as String?,
    updatedAt: j['updated_at'] as String?,
  );

  bool get isMyTurn {
    if (myColor == null) return false;
    // In FEN the active color is at position after first space: 'w' or 'b'
    final parts = fen.split(' ');
    if (parts.length < 2) return false;
    final active = parts[1];
    return (active == 'w' && myColor == 'white') ||
        (active == 'b' && myColor == 'black');
  }
}

// ── API calls ─────────────────────────────────────────────────────────────────

Future<ChessGameModel> challengeUser(String token, int userId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .post(
        Uri.parse('$base/chess/challenge/$userId'),
        headers: _headers(token),
      )
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if ((res.statusCode == 200 || res.statusCode == 201) &&
      body['success'] == true) {
    return ChessGameModel.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Failed to send challenge');
}

Future<List<ChessGameModel>> getMyGames(String token) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/chess/games'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List)
        .map((e) => ChessGameModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

Future<ChessGameModel> getGame(String token, int gameId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/chess/games/$gameId'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return ChessGameModel.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Game not found');
}

Future<ChessGameModel> acceptGame(String token, int gameId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .post(
        Uri.parse('$base/chess/games/$gameId/accept'),
        headers: _headers(token),
      )
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return ChessGameModel.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Failed to accept');
}

Future<void> declineGame(String token, int gameId) async {
  final base = await ApiConfig.baseUrl;
  await http
      .post(
        Uri.parse('$base/chess/games/$gameId/decline'),
        headers: _headers(token),
      )
      .timeout(const Duration(seconds: 10));
}

Future<ChessGameModel> makeMove(
  String token,
  int gameId,
  String from,
  String to,
  String newFen, {
  String? promotion,
}) async {
  final base = await ApiConfig.baseUrl;
  final payload = {'from': from, 'to': to, 'fen': newFen};
  if (promotion != null) payload['promotion'] = promotion;
  final res = await http
      .post(
        Uri.parse('$base/chess/games/$gameId/move'),
        headers: _headers(token),
        body: jsonEncode(payload),
      )
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return ChessGameModel.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Invalid move');
}

Future<ChessGameModel> resignGame(String token, int gameId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .post(
        Uri.parse('$base/chess/games/$gameId/resign'),
        headers: _headers(token),
      )
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return ChessGameModel.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Failed to resign');
}

Future<ChessGameModel> finishGame(
  String token,
  int gameId,
  String result,
) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .post(
        Uri.parse('$base/chess/games/$gameId/finish'),
        headers: _headers(token),
        body: jsonEncode({'result': result}),
      )
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return ChessGameModel.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Failed to finish game');
}
