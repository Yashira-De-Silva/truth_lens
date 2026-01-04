import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key});

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int? selectedRow;
  int? selectedCol;
  bool isWhiteTurn = true;
  List<String> moveHistory = [];
  bool gameOver = false;
  String? winner;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(8, (i) => List.generate(8, (j) => null));

    // Set up black pieces
    board[0] = [
      ChessPiece(PieceType.rook, false),
      ChessPiece(PieceType.knight, false),
      ChessPiece(PieceType.bishop, false),
      ChessPiece(PieceType.queen, false),
      ChessPiece(PieceType.king, false),
      ChessPiece(PieceType.bishop, false),
      ChessPiece(PieceType.knight, false),
      ChessPiece(PieceType.rook, false),
    ];
    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(PieceType.pawn, false);
    }

    // Set up white pieces
    for (int i = 0; i < 8; i++) {
      board[6][i] = ChessPiece(PieceType.pawn, true);
    }
    board[7] = [
      ChessPiece(PieceType.rook, true),
      ChessPiece(PieceType.knight, true),
      ChessPiece(PieceType.bishop, true),
      ChessPiece(PieceType.queen, true),
      ChessPiece(PieceType.king, true),
      ChessPiece(PieceType.bishop, true),
      ChessPiece(PieceType.knight, true),
      ChessPiece(PieceType.rook, true),
    ];
  }

  bool _isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (toRow < 0 || toRow > 7 || toCol < 0 || toCol > 7) return false;

    final piece = board[fromRow][fromCol];
    if (piece == null) return false;

    final targetPiece = board[toRow][toCol];
    if (targetPiece != null && targetPiece.isWhite == piece.isWhite) {
      return false;
    }

    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();

    switch (piece.type) {
      case PieceType.pawn:
        final direction = piece.isWhite ? -1 : 1;
        final startRow = piece.isWhite ? 6 : 1;

        // Move forward
        if (fromCol == toCol && targetPiece == null) {
          if (toRow == fromRow + direction) return true;
          if (fromRow == startRow && toRow == fromRow + (2 * direction)) {
            if (board[fromRow + direction][fromCol] == null) return true;
          }
        }
        // Capture diagonally
        if (colDiff == 1 &&
            toRow == fromRow + direction &&
            targetPiece != null) {
          return true;
        }
        return false;

      case PieceType.rook:
        if (rowDiff == 0 || colDiff == 0) {
          return _isPathClear(fromRow, fromCol, toRow, toCol);
        }
        return false;

      case PieceType.knight:
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

      case PieceType.bishop:
        if (rowDiff == colDiff) {
          return _isPathClear(fromRow, fromCol, toRow, toCol);
        }
        return false;

      case PieceType.queen:
        if (rowDiff == colDiff || rowDiff == 0 || colDiff == 0) {
          return _isPathClear(fromRow, fromCol, toRow, toCol);
        }
        return false;

      case PieceType.king:
        return rowDiff <= 1 && colDiff <= 1;
    }
  }

  bool _isPathClear(int fromRow, int fromCol, int toRow, int toCol) {
    final rowStep = toRow > fromRow ? 1 : (toRow < fromRow ? -1 : 0);
    final colStep = toCol > fromCol ? 1 : (toCol < fromCol ? -1 : 0);

    int currentRow = fromRow + rowStep;
    int currentCol = fromCol + colStep;

    while (currentRow != toRow || currentCol != toCol) {
      if (board[currentRow][currentCol] != null) return false;
      currentRow += rowStep;
      currentCol += colStep;
    }
    return true;
  }

  void _makeMove(int toRow, int toCol) {
    if (selectedPiece == null || selectedRow == null || selectedCol == null) {
      return;
    }

    if (!_isValidMove(selectedRow!, selectedCol!, toRow, toCol)) {
      setState(() {
        selectedPiece = null;
        selectedRow = null;
        selectedCol = null;
      });
      return;
    }

    // Check if capturing a king
    final capturedPiece = board[toRow][toCol];
    if (capturedPiece?.type == PieceType.king) {
      setState(() {
        gameOver = true;
        winner = isWhiteTurn ? 'White' : 'Black';
      });
    }

    // Move the piece
    setState(() {
      board[toRow][toCol] = selectedPiece;
      board[selectedRow!][selectedCol!] = null;

      // Record move
      final from =
          '${String.fromCharCode(97 + selectedCol!)}${8 - selectedRow!}';
      final to = '${String.fromCharCode(97 + toCol)}${8 - toRow}';
      moveHistory.add('${isWhiteTurn ? 'White' : 'Black'}: $from → $to');

      isWhiteTurn = !isWhiteTurn;
      selectedPiece = null;
      selectedRow = null;
      selectedCol = null;
    });
  }

  void _selectPiece(int row, int col) {
    final piece = board[row][col];

    if (selectedPiece == null) {
      // Select piece
      if (piece != null && piece.isWhite == isWhiteTurn) {
        setState(() {
          selectedPiece = piece;
          selectedRow = row;
          selectedCol = col;
        });
      }
    } else {
      // Move piece or select different piece
      if (piece != null && piece.isWhite == isWhiteTurn) {
        setState(() {
          selectedPiece = piece;
          selectedRow = row;
          selectedCol = col;
        });
      } else {
        _makeMove(row, col);
      }
    }
  }

  void _resetGame() {
    setState(() {
      _initializeBoard();
      selectedPiece = null;
      selectedRow = null;
      selectedCol = null;
      isWhiteTurn = true;
      moveHistory.clear();
      gameOver = false;
      winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _buildChessBoard(),
                        ),
                      ),
                    ),
                    Expanded(child: _buildSidebar()),
                  ],
                ),
              ),
            ],
          ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  gameOver
                      ? '$winner wins!'
                      : '${isWhiteTurn ? 'White' : 'Black'}\'s turn',
                  style: TextStyle(
                    color: gameOver
                        ? const Color(0xFFFBBF24)
                        : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: gameOver ? FontWeight.bold : FontWeight.normal,
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
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
            final row = index ~/ 8;
            final col = index % 8;
            final isLight = (row + col) % 2 == 0;
            final piece = board[row][col];
            final isSelected = selectedRow == row && selectedCol == col;

            return GestureDetector(
              onTap: gameOver ? null : () => _selectPiece(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFBBF24)
                      : (isLight
                            ? const Color(0xFFF0D9B5)
                            : const Color(0xFFB58863)),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: piece != null
                    ? Center(
                        child: Text(
                          _getPieceSymbol(piece),
                          style: TextStyle(
                            fontSize: 32,
                            color: piece.isWhite ? Colors.white : Colors.black,
                            shadows: [
                              Shadow(
                                color: piece.isWhite
                                    ? Colors.black
                                    : Colors.white,
                                blurRadius: 2,
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

  Widget _buildSidebar() {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
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
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Move History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: moveHistory.isEmpty
                      ? Center(
                          child: Text(
                            'No moves yet',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: moveHistory.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final reversedIndex =
                                moveHistory.length - 1 - index;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${reversedIndex + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      moveHistory[reversedIndex],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
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

  String _getPieceSymbol(ChessPiece piece) {
    const whiteSymbols = {
      PieceType.king: '♔',
      PieceType.queen: '♕',
      PieceType.rook: '♖',
      PieceType.bishop: '♗',
      PieceType.knight: '♘',
      PieceType.pawn: '♙',
    };

    const blackSymbols = {
      PieceType.king: '♚',
      PieceType.queen: '♛',
      PieceType.rook: '♜',
      PieceType.bishop: '♝',
      PieceType.knight: '♞',
      PieceType.pawn: '♟',
    };

    return piece.isWhite
        ? whiteSymbols[piece.type]!
        : blackSymbols[piece.type]!;
  }
}

enum PieceType { king, queen, rook, bishop, knight, pawn }

class ChessPiece {
  final PieceType type;
  final bool isWhite;

  ChessPiece(this.type, this.isWhite);
}
