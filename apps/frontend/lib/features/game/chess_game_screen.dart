import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen> {
  late chess_lib.Chess chess;
  String? selectedSquare;
  bool? playerColor; // true = white, false = black
  bool showColorSelection = true;
  List<String> moveHistory = [];
  
  @override
  void initState() {
    super.initState();
    chess = chess_lib.Chess();
  }

  void _selectColor(bool isWhite) {
    setState(() {
      playerColor = isWhite;
      showColorSelection = false;
    });
    
    // If player chose black, AI makes first move
    if (!isWhite) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeAIMove();
      });
    }
  }

  void _onSquareTapped(String square) {
    if (chess.game_over) return;
    
    // Check if it's player's turn
    if ((chess.turn == chess_lib.Color.WHITE && playerColor != true) ||
        (chess.turn == chess_lib.Color.BLACK && playerColor != false)) {
      return;
    }

    setState(() {
      if (selectedSquare == null) {
        // Select a piece
        final piece = chess.get(square);
        if (piece != null && 
            ((chess.turn == chess_lib.Color.WHITE && piece.color == chess_lib.Color.WHITE) ||
             (chess.turn == chess_lib.Color.BLACK && piece.color == chess_lib.Color.BLACK))) {
          selectedSquare = square;
        }
      } else {
        // Try to make a move
        final moveStr = selectedSquare! + square;
        
        if (chess.move(moveStr)) {
          moveHistory.add(moveStr);
          selectedSquare = null;
          
          // Check for game over
          if (chess.in_checkmate) {
            _showVictoryDialog();
          } else if (chess.in_draw || chess.in_stalemate) {
            _showDrawDialog();
          } else {
            // AI's turn
            Future.delayed(const Duration(milliseconds: 300), () {
              _makeAIMove();
            });
          }
        } else {
          // Invalid move, try selecting a different piece
          final piece = chess.get(square);
          if (piece != null &&
              ((chess.turn == chess_lib.Color.WHITE && piece.color == chess_lib.Color.WHITE) ||
               (chess.turn == chess_lib.Color.BLACK && piece.color == chess_lib.Color.BLACK))) {
            selectedSquare = square;
          } else {
            selectedSquare = null;
          }
        }
      }
    });
  }

  void _makeAIMove() {
    if (chess.game_over) return;

    final moves = chess.moves();
    if (moves.isEmpty) return;

    // Simple AI: Pick a random move
    final selectedMove = moves[Random().nextInt(moves.length)];

    setState(() {
      chess.move(selectedMove);
      moveHistory.add(selectedMove);
      
      if (chess.in_checkmate) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showDefeatDialog();
        });
      } else if (chess.in_draw || chess.in_stalemate) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showDrawDialog();
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      chess.reset();
      selectedSquare = null;
      moveHistory.clear();
      playerColor = null;
      showColorSelection = true;
    });
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
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
                    const Color(0xFF1A1F3A).withOpacity(0.95),
                    const Color(0xFF0A0E27).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events, size: 60, color: Color(0xFF1A1F3A)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "🎉 Congratulations! 🎉",
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text("You Won!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                    "Checkmate! Well played!",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Play Again", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Exit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDefeatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
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
                    const Color(0xFF1A1F3A).withOpacity(0.95),
                    const Color(0xFF0A0E27).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEF4444), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sentiment_dissatisfied, size: 60, color: Color(0xFFEF4444)),
                  const SizedBox(height: 24),
                  const Text(
                    "Game Over",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Better luck next time!",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Play Again", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Exit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
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
                    const Color(0xFF1A1F3A).withOpacity(0.95),
                    const Color(0xFF0A0E27).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF6366F1), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.handshake, size: 60, color: Color(0xFF6366F1)),
                  const SizedBox(height: 24),
                  const Text(
                    "It's a Draw!",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Well played!",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Play Again", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Exit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showColorSelection) {
      return _buildColorSelection();
    }
    
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
                    padding: const EdgeInsets.all(16.0),
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Chess Game',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Choose Your Color',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildColorOption(true),
                          const SizedBox(width: 32),
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
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWhite
                ? [Colors.white, Colors.grey.shade300]
                : [Colors.grey.shade800, Colors.black],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6366F1), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWhite ? '♔' : '♚',
              style: TextStyle(
                fontSize: 64,
                color: isWhite ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isWhite ? 'WHITE' : 'BLACK',
              style: TextStyle(
                color: isWhite ? Colors.black : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chess Game',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  chess.in_check
                      ? 'CHECK!'
                      : chess.turn == chess_lib.Color.WHITE
                          ? "White's turn"
                          : "Black's turn",
                  style: TextStyle(
                    color: chess.in_check ? const Color(0xFFEF4444) : Colors.white70,
                    fontSize: 14,
                    fontWeight: chess.in_check ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'New Game',
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard() {
    var squares = <String>[];
    for (int rank = 7; rank >= 0; rank--) {
      for (int file = 0; file < 8; file++) {
        squares.add(String.fromCharCode(97 + file) + (rank + 1).toString());
      }
    }

    // Flip board if player is black
    if (playerColor == false) {
      squares = squares.reversed.toList();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
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
          itemBuilder: (context, index) {
            final square = squares[index];
            final file = square.codeUnitAt(0) - 97;
            final rank = int.parse(square[1]) - 1;
            final isLight = (rank + file) % 2 == 0;
            final piece = chess.get(square);
            final isSelected = selectedSquare == square;
            final isInCheck = chess.in_check && piece?.type.name == 'k' && 
                              ((chess.turn == chess_lib.Color.WHITE && piece?.color == chess_lib.Color.WHITE) ||
                               (chess.turn == chess_lib.Color.BLACK && piece?.color == chess_lib.Color.BLACK));

            return GestureDetector(
              onTap: () => _onSquareTapped(square),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isInCheck
                      ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
                      : isSelected
                          ? const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFFFA500)])
                          : LinearGradient(
                              colors: isLight
                                  ? [const Color(0xFF4F46E5).withOpacity(0.3), const Color(0xFF6366F1).withOpacity(0.2)]
                                  : [const Color(0xFF1E1B4B).withOpacity(0.8), const Color(0xFF312E81).withOpacity(0.6)],
                            ),
                  border: isInCheck
                      ? Border.all(color: const Color(0xFFEF4444), width: 3)
                      : isSelected
                          ? Border.all(color: const Color(0xFFFBBF24), width: 3)
                          : Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                  boxShadow: isInCheck
                      ? [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.6), blurRadius: 10, spreadRadius: 2)]
                      : null,
                ),
                child: piece != null
                    ? Center(
                        child: Text(
                          _getPieceSymbol(piece),
                          style: TextStyle(
                            fontSize: 32,
                            color: piece.color == chess_lib.Color.WHITE ? Colors.white : Colors.black,
                            shadows: [
                              Shadow(
                                color: piece.color == chess_lib.Color.WHITE ? Colors.black : const Color(0xFF6366F1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getPieceSymbol(chess_lib.Piece piece) {
    final symbols = {
      'p': piece.color == chess_lib.Color.WHITE ? '♙' : '♟',
      'n': piece.color == chess_lib.Color.WHITE ? '♘' : '♞',
      'b': piece.color == chess_lib.Color.WHITE ? '♗' : '♝',
      'r': piece.color == chess_lib.Color.WHITE ? '♖' : '♜',
      'q': piece.color == chess_lib.Color.WHITE ? '♕' : '♛',
      'k': piece.color == chess_lib.Color.WHITE ? '♔' : '♚',
    };
    return symbols[piece.type.name] ?? '';
  }

  Widget _buildMoveHistory() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1F3A).withOpacity(0.8),
                  const Color(0xFF0A0E27).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Color(0xFF6366F1), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Move History',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${moveHistory.length} moves',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: moveHistory.isEmpty
                      ? Center(
                          child: Text(
                            'No moves yet',
                            style: TextStyle(color: Colors.white.withOpacity(0.4)),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: moveHistory.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8, bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.2),
                                    const Color(0xFF4F46E5).withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    moveHistory[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
      ),
    );
  }
}
