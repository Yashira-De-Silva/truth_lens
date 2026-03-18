import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import 'chess_provider.dart';
import 'chess_service.dart' as svc;

const _pieces = {
  'K': '♔',
  'Q': '♕',
  'R': '♖',
  'B': '♗',
  'N': '♘',
  'P': '♙',
  'k': '♚',
  'q': '♛',
  'r': '♜',
  'b': '♝',
  'n': '♞',
  'p': '♟',
};

List<List<String?>> _parseFen(String fen) {
  final parts = fen.split(' ');
  final rows = parts[0].split('/');
  return rows.map((row) {
    final cells = <String?>[];
    for (final ch in row.runes.map(String.fromCharCode)) {
      final n = int.tryParse(ch);
      if (n != null) {
        cells.addAll(List.filled(n, null));
      } else {
        cells.add(ch);
      }
    }
    return cells;
  }).toList();
}

/// Produce a new FEN string after moving a piece from [from] to [to].
String _applyMove(String fen, String from, String to, {String? promotion}) {
  final parts = fen.split(' ');
  final board = _parseFen(fen);

  int col(String sq) => sq.codeUnitAt(0) - 'a'.codeUnitAt(0);
  int row(String sq) => 8 - int.parse(sq[1]);

  final piece = board[row(from)][col(from)];
  board[row(from)][col(from)] = null;
  board[row(to)][col(to)] = promotion ?? piece;

  final ranks = board
      .map((rank) {
        var s = '';
        var empty = 0;
        for (final cell in rank) {
          if (cell == null) {
            empty++;
          } else {
            if (empty > 0) {
              s += '$empty';
              empty = 0;
            }
            s += cell;
          }
        }
        if (empty > 0) s += '$empty';
        return s;
      })
      .join('/');

  final active = parts.length > 1 ? (parts[1] == 'w' ? 'b' : 'w') : 'w';
  final castling = parts.length > 2 ? parts[2] : '-';
  final ep = parts.length > 3 ? parts[3] : '-';
  final half = parts.length > 4 ? '${int.parse(parts[4]) + 1}' : '0';
  final full = parts.length > 5
      ? '${active == 'w' ? int.parse(parts[5]) + 1 : int.parse(parts[5])}'
      : '1';
  return '$ranks $active $castling $ep $half $full';
}
class ChessScreen extends ConsumerStatefulWidget {
  final int gameId;
  const ChessScreen({super.key, required this.gameId});

  @override
  ConsumerState<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends ConsumerState<ChessScreen> {
  String? _selected;
  List<String> _validTargets = [];

  String _toCoord(int row, int col) =>
      '${String.fromCharCode('a'.codeUnitAt(0) + col)}${8 - row}';

  void _handleSquareTap(
    BuildContext context,
    svc.ChessGameModel game,
    int row,
    int col,
  ) {
    if (game.status != 'active') return;
    if (!game.isMyTurn) return;

    final coord = _toCoord(row, col);
    final board = _parseFen(game.fen);
    final piece = board[row][col];

    if (_selected == null) {
      if (piece != null && _isMyPiece(piece, game.myColor)) {
        setState(() {
          _selected = coord;
          _validTargets = _getBasicMoves(board, row, col, game.myColor!);
        });
      }
    } else {
      if (coord == _selected) {
        setState(() {
          _selected = null;
          _validTargets = [];
        });
        return;
      }
      if (_validTargets.contains(coord)) {
        _executeMove(context, game, _selected!, coord, board);
      } else if (piece != null && _isMyPiece(piece, game.myColor)) {
        setState(() {
          _selected = coord;
          _validTargets = _getBasicMoves(board, row, col, game.myColor!);
        });
      } else {
        setState(() {
          _selected = null;
          _validTargets = [];
        });
      }
    }
  }

  bool _isMyPiece(String piece, String? color) {
    if (color == 'white') return piece == piece.toUpperCase();
    if (color == 'black') return piece == piece.toLowerCase();
    return false;
  }

  /// Returns a list of possible target squares (very basic: includes moves that
  /// may still land on friendly pieces; the server will reject illegal moves).
  List<String> _getBasicMoves(
    List<List<String?>> board,
    int r,
    int c,
    String myColor,
  ) {
    final piece = board[r][c];
    if (piece == null) return [];

    final targets = <String>[];
    final p = piece.toLowerCase();

    bool isEnemy(int tr, int tc) {
      final t = board[tr][tc];
      if (t == null) return false;
      return (myColor == 'white') ? t == t.toLowerCase() : t == t.toUpperCase();
    }

    bool isEmpty(int tr, int tc) => board[tr][tc] == null;
    bool inBounds(int tr, int tc) => tr >= 0 && tr < 8 && tc >= 0 && tc < 8;
    bool isFriendly(int tr, int tc) {
      final t = board[tr][tc];
      if (t == null) return false;
      return !isEnemy(tr, tc);
    }

    void addIfValid(int tr, int tc) {
      if (inBounds(tr, tc) && !isFriendly(tr, tc))
        targets.add(_toCoord(tr, tc));
    }

    void addRayUntilBlocked(int dr, int dc) {
      var tr = r + dr;
      var tc = c + dc;
      while (inBounds(tr, tc)) {
        if (isFriendly(tr, tc)) break;
        addIfValid(tr, tc);
        if (isEnemy(tr, tc)) break;
        tr += dr;
        tc += dc;
      }
    }

    switch (p) {
      case 'p':
        final dir = myColor == 'white' ? -1 : 1;
        final start = myColor == 'white' ? 6 : 1;
        if (inBounds(r + dir, c) && isEmpty(r + dir, c)) {
          targets.add(_toCoord(r + dir, c));
          if (r == start && isEmpty(r + 2 * dir, c)) {
            targets.add(_toCoord(r + 2 * dir, c));
          }
        }
        for (final dc in [-1, 1]) {
          if (inBounds(r + dir, c + dc) && isEnemy(r + dir, c + dc)) {
            targets.add(_toCoord(r + dir, c + dc));
          }
        }
        break;
      case 'n':
        for (final d in [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ]) {
          addIfValid(r + d[0], c + d[1]);
        }
        break;
      case 'b':
        for (final d in [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ]) {
          addRayUntilBlocked(d[0], d[1]);
        }
        break;
      case 'r':
        for (final d in [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ]) {
          addRayUntilBlocked(d[0], d[1]);
        }
        break;
      case 'q':
        for (final d in [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ]) {
          addRayUntilBlocked(d[0], d[1]);
        }
        break;
      case 'k':
        for (final d in [
          [-1, -1],
          [-1, 0],
          [-1, 1],
          [0, -1],
          [0, 1],
          [1, -1],
          [1, 0],
          [1, 1],
        ]) {
          addIfValid(r + d[0], c + d[1]);
        }
        break;
    }
    return targets;
  }

  Future<void> _executeMove(
    BuildContext context,
    svc.ChessGameModel game,
    String from,
    String to,
    List<List<String?>> board,
  ) async {
    setState(() {
      _selected = null;
      _validTargets = [];
    });

    final piece = board[int.parse(from[1]) * -1 + 8][from.codeUnitAt(0) - 97];
    String? promotion;
    // Pawn promotion
    if (piece?.toLowerCase() == 'p') {
      final destRow = int.parse(to[1]);
      if (destRow == 8 || destRow == 1) {
        promotion = await _showPromotionDialog(
          context,
          game.myColor ?? 'white',
        );
        if (promotion == null) return;
      }
    }

    final newFen = _applyMove(game.fen, from, to, promotion: promotion);
    final ok = await ref
        .read(chessGameProvider(widget.gameId).notifier)
        .makeMove(from, to, newFen, promotion: promotion);

    if (!ok && context.mounted) {
      AppSnackbar.showError(context, 'Invalid move. Try again.');
    }
  }

  Future<String?> _showPromotionDialog(
    BuildContext context,
    String color,
  ) async {
    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text(
          'Promote pawn',
          style: TextStyle(color: Colors.white),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final p
                in color == 'white'
                    ? ['Q', 'R', 'B', 'N']
                    : ['q', 'r', 'b', 'n'])
              GestureDetector(
                onTap: () => Navigator.pop(ctx, p.toLowerCase()),
                child: Text(
                  _pieces[p] ?? p,
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(chessGameProvider(widget.gameId));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF020617), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, gameState),
              if (gameState.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                )
              else if (gameState.game == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'Game not found',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else ...[
                _buildPlayerInfo(gameState.game!, isTop: true),
                const SizedBox(height: 8),
                Expanded(child: _buildBoard(context, gameState.game!)),
                const SizedBox(height: 8),
                _buildPlayerInfo(gameState.game!, isTop: false),
                _buildStatusBar(context, gameState.game!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChessGameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '♟ Chess Match',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (state.game?.status == 'active')
            GestureDetector(
              onTap: () => _confirmResign(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Resign',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(svc.ChessGameModel game, {required bool isTop}) {
    // Top = opponent, bottom = me
    final player = isTop
        ? (game.myColor == 'white' ? game.blackPlayer : game.whitePlayer)
        : (game.myColor == 'white' ? game.whitePlayer : game.blackPlayer);
    final isBlack =
        (isTop && game.myColor == 'white') ||
        (!isTop && game.myColor == 'black');
    final color = isBlack ? '♟ Black' : '♔ White';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Center(
              child: Text(
                player.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTop ? player.name : '${player.name} (You)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  color,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context, svc.ChessGameModel game) {
    final board = _parseFen(game.fen);
    final flip = game.myColor == 'black'; // Flip board for black player

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (_, index) {
                final r = flip ? 7 - index ~/ 8 : index ~/ 8;
                final c = flip ? 7 - index % 8 : index % 8;
                return _buildSquare(context, game, board, r, c);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquare(
    BuildContext context,
    svc.ChessGameModel game,
    List<List<String?>> board,
    int r,
    int c,
  ) {
    final coord = _toCoord(r, c);
    final isLight = (r + c) % 2 == 0;
    final piece = board[r][c];
    final isSelected = _selected == coord;
    final isTarget = _validTargets.contains(coord);
    final isLastMove =
        game.moves.isNotEmpty &&
        (game.moves.last.startsWith(coord) ||
            game.moves.last.substring(2, 4) == coord);

    Color squareColor;
    if (isSelected) {
      squareColor = AppColors.secondary.withValues(alpha: 0.7);
    } else if (isLastMove) {
      squareColor = Colors.yellow.withValues(alpha: 0.3);
    } else {
      squareColor = isLight ? const Color(0xFFECDAB8) : const Color(0xFF8B5E3C);
    }

    return GestureDetector(
      onTap: () => _handleSquareTap(context, game, r, c),
      child: Container(
        color: squareColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isTarget)
              Container(
                margin: piece != null
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: piece != null ? BoxShape.rectangle : BoxShape.circle,
                  color: piece != null
                      ? Colors.red.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.25),
                  borderRadius: piece != null ? BorderRadius.circular(4) : null,
                ),
              ),
            if (piece != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _pieces[piece] ?? piece,
                  style: TextStyle(
                    fontSize: 34,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 3,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, svc.ChessGameModel game) {
    String message;
    Color color;

    if (game.status == 'waiting') {
      message = game.myColor == 'white'
          ? '⏳ Waiting for opponent to accept...'
          : '⚔️ You\'ve been challenged! Accept to play.';
      color = Colors.orange;
    } else if (game.status == 'finished') {
      if (game.result == 'draw') {
        message = '🤝 It\'s a draw!';
        color = Colors.grey;
      } else {
        final iWon =
            (game.result == 'white' && game.myColor == 'white') ||
            (game.result == 'black' && game.myColor == 'black');
        message = iWon ? '🏆 You won!' : '😔 You lost.';
        color = iWon ? AppColors.success : AppColors.error;
      }
    } else if (game.isMyTurn) {
      message = '🟢 Your turn';
      color = AppColors.success;
    } else {
      message = '⏸ Waiting for opponent...';
      color = Colors.white.withValues(alpha: 0.5);
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (game.status == 'waiting' && game.myColor == 'black') ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () =>
                  ref.read(chessGameProvider(widget.gameId).notifier).accept(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await ref
                    .read(chessGameProvider(widget.gameId).notifier)
                    .resign();
                if (context.mounted) Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Decline',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmResign(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Resign game?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You will lose this match.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Resign', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(chessGameProvider(widget.gameId).notifier).resign();
    }
  }
}
