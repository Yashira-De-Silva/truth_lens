import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as ch;

// ─────────────────────────────────────────────────────────────────────────────
// AiDifficulty  (also used by ChessLobbyScreen)
// ─────────────────────────────────────────────────────────────────────────────

enum AiDifficulty { beginner, intermediate, professional }

// ─────────────────────────────────────────────────────────────────────────────
// ChessGameScreen
// Accepts:
//   isMultiplayer – two humans on same device, board flips after each move
//   difficulty    – Beginner / Intermediate / Professional AI behaviour
// ─────────────────────────────────────────────────────────────────────────────

class ChessGameScreen extends ConsumerStatefulWidget {
  final bool isMultiplayer;
  final AiDifficulty difficulty;
  // playerColor: true=White, false=Black, null=multiplayer (both human)
  final bool? playerColor;

  const ChessGameScreen({
    super.key,
    this.isMultiplayer = false,
    this.difficulty = AiDifficulty.beginner,
    this.playerColor,
  });

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen>
    with SingleTickerProviderStateMixin {

  // ── Game state ──────────────────────────────────────────────────────────────
  late ch.Chess _chess;
  String? _selectedSquare;
  Set<String> _legalDests = {};

  // vs-AI mode: true=White, false=Black  |  multiplayer: null (both human)
  late bool? _playerColor;
  bool _aiThinking = false;
  List<String> _moveHistory = [];

  late AnimationController _pulseController;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _chess = ch.Chess();
    _playerColor = widget.playerColor;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    // If playing Black vs AI, trigger AI first move
    if (!widget.isMultiplayer && _playerColor == false) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Future.delayed(const Duration(milliseconds: 400), _makeAIMove));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Set<String> _getLegalDestsFrom(String square) {
    final verbose = _chess.moves({'square': square, 'verbose': true});
    return {
      for (final m in verbose)
        if (m is Map && m['to'] != null) m['to'] as String
    };
  }

  void _syncHistory() {
    final hist = _chess.getHistory({'verbose': true});
    _moveHistory = hist.map<String>((m) {
      if (m is Map) return (m['san'] as String?) ?? '';
      return m.toString();
    }).toList();
  }

  // In multiplayer mode the active "player" is always whoever's turn it is.
  bool get _isPlayerTurn {
    if (widget.isMultiplayer) return true;
    return _playerColor != null &&
        ((_chess.turn == ch.Color.WHITE && _playerColor == true) ||
            (_chess.turn == ch.Color.BLACK && _playerColor == false));
  }

  // For board orientation: in multiplayer flip to active side.
  bool get _boardFlipped {
    if (widget.isMultiplayer) return _chess.turn == ch.Color.BLACK;
    return _playerColor == false;
  }

  String get _activePlayerLabel {
    if (widget.isMultiplayer) {
      return _chess.turn == ch.Color.WHITE ? 'White to move' : 'Black to move';
    }
    return _isPlayerTurn ? 'Your turn' : "AI's turn";
  }

  // ── Square tap ──────────────────────────────────────────────────────────────

  void _onSquareTapped(String square) {
    if (_chess.game_over || _aiThinking || !_isPlayerTurn) return;

    setState(() {
      if (_selectedSquare == null) {
        final piece = _chess.get(square);
        if (piece == null) return;
        if (piece.color != _chess.turn) return;
        _selectedSquare = square;
        _legalDests = _getLegalDestsFrom(square);
      } else {
        if (square == _selectedSquare) {
          _selectedSquare = null;
          _legalDests = {};
          return;
        }
        final piece = _chess.get(square);
        if (piece != null && piece.color == _chess.turn) {
          _selectedSquare = square;
          _legalDests = _getLegalDestsFrom(square);
          return;
        }
        if (_legalDests.contains(square)) {
          _tryMove(_selectedSquare!, square);
        } else {
          _selectedSquare = null;
          _legalDests = {};
        }
      }
    });
  }

  // ── Move execution ──────────────────────────────────────────────────────────

  void _tryMove(String from, String to) {
    final piece = _chess.get(from);
    final isPromotion = piece?.type == ch.Chess.PAWN &&
        ((to[1] == '8' && _chess.turn == ch.Color.WHITE) ||
            (to[1] == '1' && _chess.turn == ch.Color.BLACK));

    if (isPromotion) {
      _selectedSquare = null;
      _legalDests = {};
      _showPromotionDialog(from, to);
      return;
    }
    _executeMove(from, to);
  }

  void _executeMove(String from, String to, {String promotion = 'q'}) {
    final ok = _chess.move({'from': from, 'to': to, 'promotion': promotion});
    if (!ok) {
      setState(() { _selectedSquare = null; _legalDests = {}; });
      return;
    }
    _syncHistory();
    setState(() { _selectedSquare = null; _legalDests = {}; });

    if (_chess.in_checkmate) {
      Future.delayed(const Duration(milliseconds: 250), () {
        widget.isMultiplayer
            ? _showMultiplayerResult()
            : _showVictoryDialog();
      });
      return;
    }
    if (_chess.in_draw || _chess.in_stalemate) {
      Future.delayed(
          const Duration(milliseconds: 250), _showDrawDialog);
      return;
    }

    // Multiplayer: board flips automatically (boardFlipped is computed),
    // show a brief "hand off" overlay then continue.
    if (widget.isMultiplayer) {
      _showHandoffOverlay();
      return;
    }

    // vs AI: trigger AI move
    Future.delayed(const Duration(milliseconds: 350), _makeAIMove);
  }

  // ── Hand-off overlay (multiplayer only) ──────────────────────────────────

  void _showHandoffOverlay() {
    final side = _chess.turn == ch.Color.WHITE ? 'White' : 'Black';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1F3A), Color(0xFF0A0E27)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF6366F1), width: 1.5),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  side == 'White' ? '♔' : '♚',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text("$side's turn",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Pass the device',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ready',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── AI engine ───────────────────────────────────────────────────────────────

  void _makeAIMove() {
    if (_chess.game_over || !mounted) return;
    setState(() => _aiThinking = true);

    final thinkMs = switch (widget.difficulty) {
      AiDifficulty.beginner => 280,
      AiDifficulty.intermediate => 450,
      AiDifficulty.professional => 700,
    };

    Future.delayed(Duration(milliseconds: thinkMs), () {
      if (!mounted) return;

      final chosen = switch (widget.difficulty) {
        AiDifficulty.beginner => _pickRandom(),
        AiDifficulty.intermediate => _pickIntermediate(),
        AiDifficulty.professional => _pickMinimax(),
      };

      if (chosen != null) {
        _chess.move(chosen);
        _syncHistory();
      }
      setState(() => _aiThinking = false);

      if (_chess.in_checkmate) {
        Future.delayed(
            const Duration(milliseconds: 250), _showDefeatDialog);
      } else if (_chess.in_draw || _chess.in_stalemate) {
        Future.delayed(const Duration(milliseconds: 250), _showDrawDialog);
      }
    });
  }

  // Beginner: purely random
  String? _pickRandom() {
    final moves = _chess.moves();
    if (moves.isEmpty) return null;
    return moves[Random().nextInt(moves.length)].toString();
  }

  // Intermediate: prefer checkmates → captures → checks → else random
  String? _pickIntermediate() {
    final moves = _chess.moves();
    if (moves.isEmpty) return null;

    // Prefer moves that end the game (checkmate)
    for (final m in moves) {
      final s = m.toString();
      if (s.endsWith('#')) return s;
    }
    // Prefer captures (SAN contains 'x')
    final captures =
        moves.where((m) => m.toString().contains('x')).toList();
    if (captures.isNotEmpty) {
      return captures[Random().nextInt(captures.length)].toString();
    }
    // Prefer checks
    final checks =
        moves.where((m) => m.toString().endsWith('+')).toList();
    if (checks.isNotEmpty) {
      return checks[Random().nextInt(checks.length)].toString();
    }
    return moves[Random().nextInt(moves.length)].toString();
  }

  // Professional: minimax depth 3 with simple material evaluation
  String? _pickMinimax() {
    final moves = _chess.moves();
    if (moves.isEmpty) return null;

    String? best;
    int bestScore = -99999;
    final aiColor = _chess.turn;

    for (final m in moves) {
      final san = m.toString();
      _chess.move(san);
      final score = -_minimax(2, -99999, 99999, aiColor);
      _chess.undo();
      if (score > bestScore) {
        bestScore = score;
        best = san;
      }
    }
    return best;
  }

  int _minimax(int depth, int alpha, int beta, ch.Color maxColor) {
    if (depth == 0 || _chess.game_over) {
      return _evaluate(maxColor);
    }
    final moves = _chess.moves();
    if (moves.isEmpty) return _evaluate(maxColor);

    final isMax = _chess.turn == maxColor;
    int best = isMax ? -99999 : 99999;

    for (final m in moves) {
      _chess.move(m.toString());
      final score = _minimax(depth - 1, alpha, beta, maxColor);
      _chess.undo();

      if (isMax) {
        best = max(best, score);
        alpha = max(alpha, best);
      } else {
        best = min(best, score);
        beta = min(beta, best);
      }
      if (beta <= alpha) break; // alpha-beta pruning
    }
    return best;
  }

  // Simple piece-value material count
  int _evaluate(ch.Color forColor) {
    if (_chess.in_checkmate) {
      return _chess.turn == forColor ? -9000 : 9000;
    }
    if (_chess.in_draw || _chess.in_stalemate) return 0;

    const values = {'p': 10, 'n': 30, 'b': 30, 'r': 50, 'q': 90, 'k': 0};
    int score = 0;
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (final f in files) {
      for (int r = 1; r <= 8; r++) {
        final p = _chess.get('$f$r');
        if (p == null) continue;
        final v = values[p.type.name] ?? 0;
        score += p.color == forColor ? v : -v;
      }
    }
    return score;
  }

  // ── Undo (chess.undo() × 2) ─────────────────────────────────────────────────

  void _undoMove() {
    if (widget.isMultiplayer) {
      _chess.undo();
    } else {
      if (_moveHistory.length < 2) {
        _chess.undo();
      } else {
        _chess.undo();
        _chess.undo();
      }
    }
    _syncHistory();
    setState(() { _selectedSquare = null; _legalDests = {}; });
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  void _resetGame() {
    setState(() {
      _chess.reset();
      _selectedSquare = null;
      _legalDests = {};
      _moveHistory = [];
      _playerColor = widget.playerColor;
      _aiThinking = false;
    });
    // If playing Black vs AI, trigger AI first move
    if (!widget.isMultiplayer && widget.playerColor == false) {
      Future.delayed(const Duration(milliseconds: 400), _makeAIMove);
    }
  }

  // ── Promotion dialog ──────────────────────────────────────────────────────

  void _showPromotionDialog(String from, String to) {
    final isWhite = _chess.turn == ch.Color.WHITE;
    const options = [
      ('♕', '♛', 'q', 'Queen'),
      ('♖', '♜', 'r', 'Rook'),
      ('♗', '♝', 'b', 'Bishop'),
      ('♘', '♞', 'n', 'Knight'),
    ];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1F3A), Color(0xFF0A0E27)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF6366F1), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Promote Pawn',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: options.map((o) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _executeMove(from, to, promotion: o.$3);
                      },
                      child: Container(
                        width: 62,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF6366F1)
                                  .withOpacity(0.4)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isWhite ? o.$1 : o.$2,
                                style:
                                    const TextStyle(fontSize: 30)),
                            Text(o.$4,
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 9)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Result dialogs ────────────────────────────────────────────────────────

  void _showVictoryDialog() => _showResultDialog(
        title: '🏆 You Won!',
        subtitle: 'Checkmate — brilliant play!',
        accent: const Color(0xFFFFD700),
        icon: Icons.emoji_events_rounded,
      );

  void _showDefeatDialog() => _showResultDialog(
        title: '😔 You Lost',
        subtitle: 'The AI wins this round.',
        accent: const Color(0xFFEF4444),
        icon: Icons.sentiment_dissatisfied_rounded,
      );

  void _showMultiplayerResult() {
    // The side that delivered checkmate is the PREVIOUS turn
    final winner = _chess.turn == ch.Color.WHITE ? 'Black' : 'White';
    _showResultDialog(
      title: '$winner Wins! 🎉',
      subtitle: 'Checkmate!',
      accent: winner == 'White'
          ? const Color(0xFFF0D9B5)
          : const Color(0xFF4A3728),
      icon: Icons.emoji_events_rounded,
    );
  }

  void _showDrawDialog() => _showResultDialog(
        title: '🤝 Draw!',
        subtitle: _chess.in_stalemate
            ? 'Stalemate'
            : 'Repetition or 50-move rule',
        accent: const Color(0xFF6366F1),
        icon: Icons.handshake_rounded,
      );

  void _showResultDialog({
    required String title,
    required String subtitle,
    required Color accent,
    required IconData icon,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1F3A).withOpacity(0.97),
                  const Color(0xFF0A0E27).withOpacity(0.97),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 4)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.15),
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: Icon(icon, size: 48, color: accent),
                ),
                const SizedBox(height: 18),
                Text(title,
                    style: TextStyle(
                        color: accent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('${_moveHistory.length} half-moves played',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12)),
                const SizedBox(height: 26),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resetGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                      child: const Text('Play Again',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side:
                            const BorderSide(color: Colors.white30),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                      child: const Text('Exit',
                          style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF0A0E27)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildChessBoard(),
                    ),
                  ),
                ),
              ),
              _buildMoveHistory(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    String turnLabel;
    Color turnColor = Colors.white60;

    if (_aiThinking) {
      turnLabel = 'AI is thinking…';
      turnColor = const Color(0xFF6366F1);
    } else if (_chess.in_checkmate) {
      turnLabel = 'Checkmate!';
      turnColor = const Color(0xFFFFD700);
    } else if (_chess.in_stalemate) {
      turnLabel = 'Stalemate!';
      turnColor = const Color(0xFF6366F1);
    } else if (_chess.in_draw) {
      turnLabel = 'Draw!';
      turnColor = const Color(0xFF6366F1);
    } else if (_chess.in_check) {
      turnLabel = '⚠  Check!';
      turnColor = const Color(0xFFEF4444);
    } else {
      turnLabel = _activePlayerLabel;
      turnColor = _isPlayerTurn
          ? const Color(0xFF34D399)
          : Colors.white38;
    }

    // Badge row: mode + difficulty or multiplayer tag
    final badge = widget.isMultiplayer
        ? '2P Local'
        : _difficultyLabel(widget.difficulty);
    final badgeColor = widget.isMultiplayer
        ? const Color(0xFF34D399)
        : _difficultyColor(widget.difficulty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back,
                color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Chess',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: badgeColor.withOpacity(0.4),
                        width: 1),
                  ),
                  child: Text(badge,
                      style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(turnLabel,
                    key: ValueKey(turnLabel),
                    style: TextStyle(
                        color: turnColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        if (_moveHistory.isNotEmpty && !_chess.game_over)
          IconButton(
            onPressed: _aiThinking ? null : _undoMove,
            icon: const Icon(Icons.undo_rounded,
                color: Colors.white60),
            tooltip: 'Undo',
          ),
        IconButton(
          onPressed: _resetGame,
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white60),
          tooltip: 'New Game',
        ),
      ]),
    );
  }

  // ── Board ─────────────────────────────────────────────────────────────────

  Widget _buildChessBoard() {
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const ranks = [8, 7, 6, 5, 4, 3, 2, 1];
    final dFiles =
        _boardFlipped ? files.reversed.toList() : files;
    final dRanks =
        _boardFlipped ? ranks.reversed.toList() : ranks;

    final squares = [
      for (final r in dRanks)
        for (final f in dFiles) '$f$r'
    ];

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
          itemCount: 64,
          itemBuilder: (_, i) => _buildSquare(squares[i]),
        ),
      ),
    );
  }

  Widget _buildSquare(String square) {
    final file = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(square[1]) - 1;
    final isLight = (rank + file) % 2 == 0;

    final piece = _chess.get(square);
    final isSelected = _selectedSquare == square;
    final isLegalDest = _legalDests.contains(square);

    final isKingInCheck = _chess.in_check &&
        piece != null &&
        piece.type == ch.Chess.KING &&
        piece.color == _chess.turn;

    final hist = _chess.getHistory({'verbose': true});
    final String? lFrom =
        hist.isNotEmpty ? (hist.last as Map)['from'] as String? : null;
    final String? lTo =
        hist.isNotEmpty ? (hist.last as Map)['to'] as String? : null;
    final isLastMove = square == lFrom || square == lTo;

    return GestureDetector(
      onTap: () => _onSquareTapped(square),
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: isKingInCheck
                ? const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)])
                : isSelected
                    ? const LinearGradient(colors: [
                        Color(0xFFFBBF24),
                        Color(0xFFD97706)
                      ])
                    : isLastMove
                        ? LinearGradient(
                            colors: isLight
                                ? [
                                    const Color(0xFFCDD16F),
                                    const Color(0xFFB8C44A)
                                  ]
                                : [
                                    const Color(0xFF7B9B3C),
                                    const Color(0xFF5D7A22)
                                  ])
                        : LinearGradient(
                            colors: isLight
                                ? [
                                    const Color(0xFFF0D9B5),
                                    const Color(0xFFE8C89A)
                                  ]
                                : [
                                    const Color(0xFFB58863),
                                    const Color(0xFF9D6F43)
                                  ]),
          ),
        ),
        if (isLegalDest)
          Center(
            child: piece != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black38, width: 4),
                    ),
                  )
                : Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
          ),
        if (piece != null)
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) {
                final scale = isKingInCheck
                    ? 1.0 + _pulseController.value * 0.07
                    : 1.0;
                return Transform.scale(
                    scale: scale, child: child);
              },
              child: Text(_pieceSymbol(piece),
                  style:
                      const TextStyle(fontSize: 34, height: 1.0)),
            ),
          ),
        if (square[0] == 'a')
          Positioned(
            top: 2,
            left: 2,
            child: Text(square[1],
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isLight
                        ? const Color(0xFFB58863)
                        : const Color(0xFFF0D9B5))),
          ),
        if (square[1] == (_boardFlipped ? '8' : '1'))
          Positioned(
            bottom: 2,
            right: 3,
            child: Text(square[0],
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isLight
                        ? const Color(0xFFB58863)
                        : const Color(0xFFF0D9B5))),
          ),
      ]),
    );
  }

  // ── Piece symbols ─────────────────────────────────────────────────────────

  String _pieceSymbol(ch.Piece piece) {
    const w = {
      'p': '♙',
      'n': '♘',
      'b': '♗',
      'r': '♖',
      'q': '♕',
      'k': '♔'
    };
    const b = {
      'p': '♟',
      'n': '♞',
      'b': '♝',
      'r': '♜',
      'q': '♛',
      'k': '♚'
    };
    return (piece.color == ch.Color.WHITE ? w : b)[piece.type.name] ??
        '?';
  }

  // ── Move history ──────────────────────────────────────────────────────────

  Widget _buildMoveHistory() {
    final pairs = <(String, String?)>[];
    for (int i = 0; i < _moveHistory.length; i += 2) {
      pairs.add((_moveHistory[i],
          i + 1 < _moveHistory.length
              ? _moveHistory[i + 1]
              : null));
    }

    return Container(
      height: 108,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(children: [
                  const Icon(
                      Icons.format_list_numbered_rounded,
                      color: Color(0xFF6366F1),
                      size: 15),
                  const SizedBox(width: 6),
                  const Text('Move History',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${pairs.length} moves',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11)),
                ]),
              ),
              Expanded(
                child: pairs.isEmpty
                    ? Center(
                        child: Text('No moves yet',
                            style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.28),
                                fontSize: 12)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10),
                        itemCount: pairs.length,
                        itemBuilder: (_, i) {
                          final p = pairs[i];
                          return Container(
                            margin: const EdgeInsets.only(
                                right: 6, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1)
                                  .withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF6366F1)
                                      .withOpacity(0.22)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${i + 1}.',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.35),
                                        fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(p.$1,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.bold)),
                                if (p.$2 != null) ...[
                                  const SizedBox(width: 5),
                                  Text(p.$2!,
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.6),
                                          fontSize: 13)),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Difficulty helpers ────────────────────────────────────────────────────

  String _difficultyLabel(AiDifficulty d) => switch (d) {
        AiDifficulty.beginner => 'Beginner',
        AiDifficulty.intermediate => 'Intermediate',
        AiDifficulty.professional => 'Professional',
      };

  Color _difficultyColor(AiDifficulty d) => switch (d) {
        AiDifficulty.beginner => const Color(0xFF34D399),
        AiDifficulty.intermediate => const Color(0xFFFBBF24),
        AiDifficulty.professional => const Color(0xFFEF4444),
      };
}
