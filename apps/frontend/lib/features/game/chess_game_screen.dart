import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as ch;

// ─────────────────────────────────────────────────────────────────────────────
// ChessGameScreen
// Uses the Dart `chess` package (pub.dev/packages/chess), the direct Dart port
// of the node-chess algebraic engine (npmjs.com/package/chess).
//
// Chess-package API surface used:
//   chess.get(square)                          – piece on a square
//   chess.moves({'square': sq})                – legal SAN moves from sq
//   chess.moves({'square': sq, 'verbose':true})– legal moves with src/dest
//   chess.moves()                              – all legal SAN moves
//   chess.move({'from', 'to', 'promotion'})    – execute a move (Map form)
//   chess.move(sanString)                      – execute a move (SAN string)
//   chess.getHistory({'verbose': true})        – full move list as Maps
//   chess.undo()                               – take back last half-move
//   chess.in_check / in_checkmate / in_stalemate / in_draw / game_over
//   chess.turn                                 – Color.WHITE | Color.BLACK
//   chess.fen                                  – current FEN string
// ─────────────────────────────────────────────────────────────────────────────

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen>
    with SingleTickerProviderStateMixin {
  // ── Game state ──────────────────────────────────────────────────────────────
  late ch.Chess _chess;
  String? _selectedSquare;
  Set<String> _legalDests = {};
  bool? _playerColor;         // true = White, false = Black
  bool _showColorSelection = true;
  bool _aiThinking = false;
  List<String> _moveHistory = [];

  late AnimationController _pulseController;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _chess = ch.Chess();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Chess-package helpers ───────────────────────────────────────────────────

  /// Uses chess.moves({'square': sq, 'verbose': true}) to get destination squares.
  Set<String> _getLegalDestsFrom(String square) {
    final verbose =
        _chess.moves({'square': square, 'verbose': true});
    return {
      for (final m in verbose)
        if (m is Map && m['to'] != null) m['to'] as String
    };
  }

  /// Re-builds _moveHistory from chess.getHistory({'verbose': true}).
  /// Each entry in the result is a Map with key 'san'.
  void _syncHistory() {
    final hist = _chess.getHistory({'verbose': true});
    _moveHistory = hist.map<String>((m) {
      if (m is Map) return (m['san'] as String?) ?? '';
      return m.toString();
    }).toList();
  }

  bool get _isPlayerTurn =>
      _playerColor != null &&
      ((_chess.turn == ch.Color.WHITE && _playerColor == true) ||
       (_chess.turn == ch.Color.BLACK && _playerColor == false));

  // ── Color selection ─────────────────────────────────────────────────────────

  void _selectColor(bool isWhite) {
    setState(() {
      _playerColor = isWhite;
      _showColorSelection = false;
    });
    if (!isWhite) {
      Future.delayed(const Duration(milliseconds: 400), _makeAIMove);
    }
  }

  // ── Square tap handler ──────────────────────────────────────────────────────

  void _onSquareTapped(String square) {
    if (_chess.game_over || _aiThinking || !_isPlayerTurn) return;

    setState(() {
      if (_selectedSquare == null) {
        final piece = _chess.get(square);
        if (piece == null) return;
        final myColor = _playerColor! ? ch.Color.WHITE : ch.Color.BLACK;
        if (piece.color != myColor) return;
        _selectedSquare = square;
        _legalDests = _getLegalDestsFrom(square);
      } else {
        if (square == _selectedSquare) {
          _selectedSquare = null;
          _legalDests = {};
          return;
        }
        final piece = _chess.get(square);
        final myColor = _playerColor! ? ch.Color.WHITE : ch.Color.BLACK;
        if (piece != null && piece.color == myColor) {
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

  /// Calls chess.move({'from': from, 'to': to, 'promotion': promo}).
  void _executeMove(String from, String to, {String promotion = 'q'}) {
    final ok = _chess.move({'from': from, 'to': to, 'promotion': promotion});
    if (!ok) {
      setState(() { _selectedSquare = null; _legalDests = {}; });
      return;
    }
    _syncHistory();
    setState(() { _selectedSquare = null; _legalDests = {}; });

    if (_chess.in_checkmate) {
      Future.delayed(const Duration(milliseconds: 250), _showVictoryDialog);
    } else if (_chess.in_draw || _chess.in_stalemate) {
      Future.delayed(const Duration(milliseconds: 250), _showDrawDialog);
    } else {
      Future.delayed(const Duration(milliseconds: 350), _makeAIMove);
    }
  }

  // ── AI (random legal move via chess.moves()) ────────────────────────────────

  void _makeAIMove() {
    if (_chess.game_over || !mounted) return;
    setState(() => _aiThinking = true);

    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      // chess.moves() returns a List of SAN strings
      final sanMoves = _chess.moves();
      if (sanMoves.isEmpty) { setState(() => _aiThinking = false); return; }

      final chosen = sanMoves[Random().nextInt(sanMoves.length)].toString();
      // chess.move(String) accepts a SAN string
      _chess.move(chosen);
      _syncHistory();
      setState(() => _aiThinking = false);

      if (_chess.in_checkmate) {
        Future.delayed(const Duration(milliseconds: 250), _showDefeatDialog);
      } else if (_chess.in_draw || _chess.in_stalemate) {
        Future.delayed(const Duration(milliseconds: 250), _showDrawDialog);
      }
    });
  }

  // ── Undo (chess.undo() × 2) ─────────────────────────────────────────────────

  void _undoMove() {
    if (_moveHistory.length < 2) {
      _chess.undo();
    } else {
      _chess.undo(); // AI half-move
      _chess.undo(); // player half-move
    }
    _syncHistory();
    setState(() { _selectedSquare = null; _legalDests = {}; });
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void _resetGame() {
    setState(() {
      _chess.reset();
      _selectedSquare = null;
      _legalDests = {};
      _moveHistory = [];
      _playerColor = null;
      _showColorSelection = true;
      _aiThinking = false;
    });
  }

  // ── Promotion dialog ─────────────────────────────────────────────────────

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
              border: Border.all(color: const Color(0xFF6366F1), width: 2),
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
                              color: const Color(0xFF6366F1).withOpacity(0.4)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isWhite ? o.$1 : o.$2,
                                style: const TextStyle(fontSize: 30)),
                            Text(o.$4,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 9)),
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
                        color: Colors.white.withOpacity(0.65), fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('${_moveHistory.length} half-moves played',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35), fontSize: 12)),
                const SizedBox(height: 26),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); _resetGame(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Play Again',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
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
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Exit', style: TextStyle(fontSize: 15)),
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
    if (_showColorSelection) return _buildColorSelection();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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

  // ── Color selection ───────────────────────────────────────────────────────

  Widget _buildColorSelection() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Chess',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('♟  Choose Your Side',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('You play against the AI',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14)),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildColorOption(true),
                          const SizedBox(width: 28),
                          _buildColorOption(false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(bool isWhite) {
    return GestureDetector(
      onTap: () => _selectColor(isWhite),
      child: Container(
        width: 138,
        height: 158,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWhite
                ? [const Color(0xFFF0EAD6), const Color(0xFFD4C99A)]
                : [const Color(0xFF4A3728), const Color(0xFF1A0E08)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6366F1), width: 2.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isWhite ? '♔' : '♚',
                style: TextStyle(
                    fontSize: 60,
                    color: isWhite ? Colors.black87 : Colors.white)),
            const SizedBox(height: 8),
            Text(isWhite ? 'WHITE' : 'BLACK',
                style: TextStyle(
                    color: isWhite ? Colors.black87 : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(isWhite ? 'You go first' : 'AI goes first',
                style: TextStyle(
                    color: (isWhite ? Colors.black : Colors.white)
                        .withOpacity(0.45),
                    fontSize: 11)),
          ],
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
      turnLabel = _isPlayerTurn ? 'Your turn' : "AI's turn";
      turnColor = _isPlayerTurn
          ? const Color(0xFF34D399)
          : Colors.white38;
    }

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
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chess',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
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
        // Undo — available when ≥ 2 half-moves and game is ongoing
        if (_moveHistory.length >= 2 && !_chess.game_over)
          IconButton(
            onPressed: _aiThinking ? null : _undoMove,
            icon: const Icon(Icons.undo_rounded, color: Colors.white60),
            tooltip: 'Undo',
          ),
        IconButton(
          onPressed: _resetGame,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white60),
          tooltip: 'New Game',
        ),
      ]),
    );
  }

  // ── Board ─────────────────────────────────────────────────────────────────

  Widget _buildChessBoard() {
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const ranks = [8, 7, 6, 5, 4, 3, 2, 1];
    final dFiles = _playerColor == false ? files.reversed.toList() : files;
    final dRanks = _playerColor == false ? ranks.reversed.toList() : ranks;

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
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
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

    // Check: is the current-turn King on this square?
    final isKingInCheck = _chess.in_check &&
        piece != null &&
        piece.type == ch.Chess.KING &&
        piece.color == _chess.turn;

    // Last-move highlight from getHistory
    final hist = _chess.getHistory({'verbose': true});
    final String? lFrom =
        hist.isNotEmpty ? (hist.last as Map)['from'] as String? : null;
    final String? lTo =
        hist.isNotEmpty ? (hist.last as Map)['to'] as String? : null;
    final isLastMove = square == lFrom || square == lTo;

    return GestureDetector(
      onTap: () => _onSquareTapped(square),
      child: Stack(children: [
        // ── Background ───────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: isKingInCheck
                ? const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)])
                : isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFD97706)])
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

        // ── Legal move indicator ─────────────────────────────────────────────
        if (isLegalDest)
          Center(
            child: piece != null
                // Capture: ring around square
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black38, width: 4),
                    ),
                  )
                // Empty square: dot
                : Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
          ),

        // ── Piece ─────────────────────────────────────────────────────────
        if (piece != null)
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) {
                final scale =
                    isKingInCheck ? 1.0 + _pulseController.value * 0.07 : 1.0;
                return Transform.scale(scale: scale, child: child);
              },
              child: Text(_pieceSymbol(piece),
                  style: const TextStyle(fontSize: 34, height: 1.0)),
            ),
          ),

        // ── Edge labels ──────────────────────────────────────────────────
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
        if (square[1] == (_playerColor == false ? '8' : '1'))
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
    const w = {'p': '♙', 'n': '♘', 'b': '♗', 'r': '♖', 'q': '♕', 'k': '♔'};
    const b = {'p': '♟', 'n': '♞', 'b': '♝', 'r': '♜', 'q': '♛', 'k': '♚'};
    return (piece.color == ch.Color.WHITE ? w : b)[piece.type.name] ?? '?';
  }

  // ── Move history strip ────────────────────────────────────────────────────

  Widget _buildMoveHistory() {
    // Pair half-moves: (white, black?)
    final pairs = <(String, String?)>[];
    for (int i = 0; i < _moveHistory.length; i += 2) {
      pairs.add((_moveHistory[i],
          i + 1 < _moveHistory.length ? _moveHistory[i + 1] : null));
    }

    return Container(
      height: 108,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(children: [
                  const Icon(Icons.format_list_numbered_rounded,
                      color: Color(0xFF6366F1), size: 15),
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
                                color: Colors.white.withOpacity(0.28),
                                fontSize: 12)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: pairs.length,
                        itemBuilder: (_, i) {
                          final p = pairs[i];
                          return Container(
                            margin: const EdgeInsets.only(right: 6, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF6366F1).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF6366F1)
                                      .withOpacity(0.22)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${i + 1}.',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.35),
                                        fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(p.$1,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                if (p.$2 != null) ...[
                                  const SizedBox(width: 5),
                                  Text(p.$2!,
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.6),
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
}
