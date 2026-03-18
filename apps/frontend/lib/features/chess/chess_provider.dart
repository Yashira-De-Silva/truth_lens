import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'chess_service.dart' as svc;

class ChessGamesState {
  final List<svc.ChessGameModel> games;
  final bool isLoading;
  final String? error;
  const ChessGamesState({
    this.games = const [],
    this.isLoading = false,
    this.error,
  });
  ChessGamesState copyWith({
    List<svc.ChessGameModel>? games,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => ChessGamesState(
    games: games ?? this.games,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class ChessGamesNotifier extends StateNotifier<ChessGamesState> {
  final String token;
  Timer? _pollTimer;

  ChessGamesNotifier(this.token)
    : super(const ChessGamesState(isLoading: true)) {
    if (token.isNotEmpty) {
      load();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 8),
        (_) => _silentRefresh(),
      );
    } else {
      state = const ChessGamesState();
    }
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final games = await svc.getMyGames(token);
      state = state.copyWith(games: games, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _silentRefresh() async {
    try {
      final games = await svc.getMyGames(token);
      if (mounted) state = state.copyWith(games: games);
    } catch (_) {}
  }

  Future<svc.ChessGameModel?> challenge(int userId) async {
    try {
      final game = await svc.challengeUser(token, userId);
      await load();
      return game;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final chessGamesProvider =
    StateNotifierProvider.autoDispose<ChessGamesNotifier, ChessGamesState>(
      (ref) => ChessGamesNotifier(ref.watch(authProvider).token ?? ''),
    );
class ChessGameState {
  final svc.ChessGameModel? game;
  final bool isLoading;
  final bool isMakingMove;
  final String? error;
  const ChessGameState({
    this.game,
    this.isLoading = false,
    this.isMakingMove = false,
    this.error,
  });
  ChessGameState copyWith({
    svc.ChessGameModel? game,
    bool? isLoading,
    bool? isMakingMove,
    String? error,
    bool clearError = false,
  }) => ChessGameState(
    game: game ?? this.game,
    isLoading: isLoading ?? this.isLoading,
    isMakingMove: isMakingMove ?? this.isMakingMove,
    error: clearError ? null : (error ?? this.error),
  );
}

class ChessGameNotifier extends StateNotifier<ChessGameState> {
  final String token;
  final int gameId;
  Timer? _pollTimer;

  ChessGameNotifier(this.token, this.gameId)
    : super(const ChessGameState(isLoading: true)) {
    load();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _silentRefresh(),
    );
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final game = await svc.getGame(token, gameId);
      state = state.copyWith(game: game, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _silentRefresh() async {
    if (state.isMakingMove) return;
    try {
      final game = await svc.getGame(token, gameId);
      if (mounted) state = state.copyWith(game: game);
    } catch (_) {}
  }

  Future<bool> makeMove(
    String from,
    String to,
    String newFen, {
    String? promotion,
  }) async {
    state = state.copyWith(isMakingMove: true, clearError: true);
    try {
      final game = await svc.makeMove(
        token,
        gameId,
        from,
        to,
        newFen,
        promotion: promotion,
      );
      state = state.copyWith(game: game, isMakingMove: false);
      return true;
    } catch (e) {
      state = state.copyWith(isMakingMove: false, error: e.toString());
      return false;
    }
  }

  Future<void> accept() async {
    try {
      final game = await svc.acceptGame(token, gameId);
      state = state.copyWith(game: game);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resign() async {
    try {
      final game = await svc.resignGame(token, gameId);
      state = state.copyWith(game: game);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> finishGame(String result) async {
    try {
      final game = await svc.finishGame(token, gameId, result);
      state = state.copyWith(game: game);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final chessGameProvider = StateNotifierProvider.autoDispose
    .family<ChessGameNotifier, ChessGameState, int>(
      (ref, gameId) =>
          ChessGameNotifier(ref.watch(authProvider).token ?? '', gameId),
    );
