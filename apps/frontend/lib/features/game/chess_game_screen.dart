import 'dart:ui';
import 'dart:math';
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
  bool? playerColor; // null = not selected, true = white, false = black
  bool showColorSelection = true;
  
  // Track if pieces have moved for castling
  bool whiteKingMoved = false;
  bool whiteLeftRookMoved = false;
  bool whiteRightRookMoved = false;
  bool blackKingMoved = false;
  bool blackLeftRookMoved = false;
  bool blackRightRookMoved = false;

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
        // Normal king move
        if (rowDiff <= 1 && colDiff <= 1) return true;
        
        // Castling
        if (rowDiff == 0 && colDiff == 2) {
          return _canCastle(fromRow, fromCol, toRow, toCol);
        }
        return false;
    }
  }

  bool _canCastle(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board[fromRow][fromCol];
    if (piece == null || piece.type != PieceType.king) return false;

    // Check if king has moved
    if (piece.isWhite && whiteKingMoved) return false;
    if (!piece.isWhite && blackKingMoved) return false;

    // Kingside castling (right)
    if (toCol > fromCol) {
      // Check if right rook has moved
      if (piece.isWhite && whiteRightRookMoved) return false;
      if (!piece.isWhite && blackRightRookMoved) return false;

      // Check if rook is there
      final rook = board[fromRow][7];
      if (rook == null || rook.type != PieceType.rook || rook.isWhite != piece.isWhite) {
        return false;
      }

      // Check if path is clear
      if (board[fromRow][fromCol + 1] != null || board[fromRow][fromCol + 2] != null) {
        return false;
      }

      return true;
    }
    // Queenside castling (left)
    else {
      // Check if left rook has moved
      if (piece.isWhite && whiteLeftRookMoved) return false;
      if (!piece.isWhite && blackLeftRookMoved) return false;

      // Check if rook is there
      final rook = board[fromRow][0];
      if (rook == null || rook.type != PieceType.rook || rook.isWhite != piece.isWhite) {
        return false;
      }

      // Check if path is clear
      if (board[fromRow][fromCol - 1] != null || 
          board[fromRow][fromCol - 2] != null ||
          board[fromRow][fromCol - 3] != null) {
        return false;
      }

      return true;
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

    // Check if this is a castling move
    final isCastling = selectedPiece?.type == PieceType.king &&
        (toCol - selectedCol!).abs() == 2;

    // Move the piece
    setState(() {
      board[toRow][toCol] = selectedPiece;
      board[selectedRow!][selectedCol!] = null;

      // Handle castling - move the rook too
      if (isCastling) {
        if (toCol > selectedCol!) {
          // Kingside castling - move right rook
          board[toRow][toCol - 1] = board[toRow][7];
          board[toRow][7] = null;
        } else {
          // Queenside castling - move left rook
          board[toRow][toCol + 1] = board[toRow][0];
          board[toRow][0] = null;
        }
      }

      // Track piece movements for castling
      if (selectedPiece?.type == PieceType.king) {
        if (selectedPiece!.isWhite) {
          whiteKingMoved = true;
        } else {
          blackKingMoved = true;
        }
      } else if (selectedPiece?.type == PieceType.rook) {
        if (selectedPiece!.isWhite) {
          if (selectedCol == 0) whiteLeftRookMoved = true;
          if (selectedCol == 7) whiteRightRookMoved = true;
        } else {
          if (selectedCol == 0) blackLeftRookMoved = true;
          if (selectedCol == 7) blackRightRookMoved = true;
        }
      }

      // Record move
      final from =
          '${String.fromCharCode(97 + selectedCol!)}${8 - selectedRow!}';
      final to = '${String.fromCharCode(97 + toCol)}${8 - toRow}';
      final moveNotation = isCastling 
          ? (toCol > selectedCol! ? 'O-O' : 'O-O-O')
          : '$from → $to';
      moveHistory.add('${isWhiteTurn ? 'White' : 'Black'}: $moveNotation');

      isWhiteTurn = !isWhiteTurn;
      selectedPiece = null;
      selectedRow = null;
      selectedCol = null;
    });

    // After player moves, make AI move
    if (!gameOver && isWhiteTurn != playerColor) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeAIMove();
      });
    }
  }

  void _makeAIMove() {
    if (gameOver) return;

    // Find all valid moves for AI
    final validMoves = <Map<String, int>>[];

    for (int fromRow = 0; fromRow < 8; fromRow++) {
      for (int fromCol = 0; fromCol < 8; fromCol++) {
        final piece = board[fromRow][fromCol];
        if (piece != null && piece.isWhite == isWhiteTurn) {
          // Check all possible destination squares
          for (int toRow = 0; toRow < 8; toRow++) {
            for (int toCol = 0; toCol < 8; toCol++) {
              if (_isValidMove(fromRow, fromCol, toRow, toCol)) {
                validMoves.add({
                  'fromRow': fromRow,
                  'fromCol': fromCol,
                  'toRow': toRow,
                  'toCol': toCol,
                });
              }
            }
          }
        }
      }
    }

    if (validMoves.isEmpty) {
      setState(() {
        gameOver = true;
        winner = playerColor == true ? 'White' : 'Black';
      });
      return;
    }

    // Pick a random valid move
    final random = Random();
    final move = validMoves[random.nextInt(validMoves.length)];

    final piece = board[move['fromRow']!][move['fromCol']!];
    final capturedPiece = board[move['toRow']!][move['toCol']!];

    // Check if capturing a king
    if (capturedPiece?.type == PieceType.king) {
      setState(() {
        gameOver = true;
        winner = isWhiteTurn ? 'White' : 'Black';
      });
    }

    // Check if this is a castling move
    final isCastling = piece?.type == PieceType.king &&
        (move['toCol']! - move['fromCol']!).abs() == 2;

    setState(() {
      board[move['toRow']!][move['toCol']!] = piece;
      board[move['fromRow']!][move['fromCol']!] = null;

      // Handle castling - move the rook too
      if (isCastling) {
        final toRow = move['toRow']!;
        final toCol = move['toCol']!;
        final fromCol = move['fromCol']!;
        
        if (toCol > fromCol) {
          // Kingside castling - move right rook
          board[toRow][toCol - 1] = board[toRow][7];
          board[toRow][7] = null;
        } else {
          // Queenside castling - move left rook
          board[toRow][toCol + 1] = board[toRow][0];
          board[toRow][0] = null;
        }
      }

      // Track piece movements for castling
      if (piece?.type == PieceType.king) {
        if (piece!.isWhite) {
          whiteKingMoved = true;
        } else {
          blackKingMoved = true;
        }
      } else if (piece?.type == PieceType.rook) {
        if (piece!.isWhite) {
          if (move['fromCol'] == 0) whiteLeftRookMoved = true;
          if (move['fromCol'] == 7) whiteRightRookMoved = true;
        } else {
          if (move['fromCol'] == 0) blackLeftRookMoved = true;
          if (move['fromCol'] == 7) blackRightRookMoved = true;
        }
      }

      // Record move
      final from =
          '${String.fromCharCode(97 + move['fromCol']!)}${8 - move['fromRow']!}';
      final to =
          '${String.fromCharCode(97 + move['toCol']!)}${8 - move['toRow']!}';
      final moveNotation = isCastling 
          ? (move['toCol']! > move['fromCol']! ? 'O-O' : 'O-O-O')
          : '$from → $to';
      moveHistory.add('${isWhiteTurn ? 'White' : 'Black'}: $moveNotation');

      isWhiteTurn = !isWhiteTurn;
    });
  }

  void _selectPiece(int row, int col) {
    // Only allow moves for the player's color
    if (playerColor != null && isWhiteTurn != playerColor) {
      return; // Not player's turn
    }

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
      playerColor = null;
      showColorSelection = true;
      
      // Reset castling flags
      whiteKingMoved = false;
      whiteLeftRookMoved = false;
      whiteRightRookMoved = false;
      blackKingMoved = false;
      blackLeftRookMoved = false;
      blackRightRookMoved = false;
    });
  }

  void _selectColor(bool isWhite) {
    setState(() {
      playerColor = isWhite;
      showColorSelection = false;
    });

    // If player chose black, AI (white) makes first move
    if (!isWhite) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeAIMove();
      });
    }
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
            // If player is black, rotate the board
            int row, col;
            if (playerColor == false) {
              // Black player - flip the board
              row = 7 - (index ~/ 8);
              col = 7 - (index % 8);
            } else {
              // White player - normal orientation
              row = index ~/ 8;
              col = index % 8;
            }

            final isLight = (row + col) % 2 == 0;
            final piece = board[row][col];
            final isSelected = selectedRow == row && selectedCol == col;

            return GestureDetector(
              onTap: gameOver ? null : () => _selectPiece(row, col),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFFFA500)],
                        )
                      : LinearGradient(
                          colors: isLight
                              ? [
                                  const Color(0xFF4F46E5).withOpacity(0.3),
                                  const Color(0xFF6366F1).withOpacity(0.2),
                                ]
                              : [
                                  const Color(0xFF1E1B4B).withOpacity(0.8),
                                  const Color(0xFF312E81).withOpacity(0.6),
                                ],
                        ),
                  border: isSelected
                      ? Border.all(color: const Color(0xFFFBBF24), width: 3)
                      : Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
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
                                    : const Color(0xFF6366F1),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Move History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${moveHistory.length} moves',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
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
                          scrollDirection: Axis.horizontal,
                          itemCount: moveHistory.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    moveHistory[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Chess Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.extension,
                          color: Color(0xFF8B5CF6),
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Choose Your Color',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select which side you want to play',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          children: [
                            Expanded(
                              child: _buildColorOption(
                                'White',
                                '♔',
                                true,
                                Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildColorOption(
                                'Black',
                                '♚',
                                false,
                                Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(
    String label,
    String symbol,
    bool isWhite,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _selectColor(isWhite),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 80,
                    color: color,
                    shadows: [
                      Shadow(
                        color: isWhite ? Colors.black : Colors.white,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isWhite ? 'Move First' : 'Move Second',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
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
