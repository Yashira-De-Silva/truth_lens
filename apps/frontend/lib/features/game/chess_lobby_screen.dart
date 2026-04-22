import 'dart:ui';
import 'package:flutter/material.dart';
import 'chess_game_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChessLobbyScreen
// One-stop entry point:
//   • Choose mode  : vs AI  |  Local 2P
//   • Choose level : Beginner | Intermediate | Professional  (vs AI only)
//   • Choose color : White | Black  (vs AI only)
// Everything is passed to ChessGameScreen so it starts immediately.
// ─────────────────────────────────────────────────────────────────────────────

class ChessLobbyScreen extends StatefulWidget {
  final int initialMode;
  const ChessLobbyScreen({super.key, this.initialMode = 0});

  @override
  State<ChessLobbyScreen> createState() => _ChessLobbyScreenState();
}

class _ChessLobbyScreenState extends State<ChessLobbyScreen>
    with SingleTickerProviderStateMixin {

  late int _modeIndex;                         // 0=vs AI, 1=multiplayer
  AiDifficulty _difficulty = AiDifficulty.beginner;
  bool _playAsWhite = true;                   // colour choice (vs AI)

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _modeIndex = widget.initialMode;
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessGameScreen(
          isMultiplayer: _modeIndex == 1,
          difficulty: _modeIndex == 1 ? AiDifficulty.beginner : _difficulty,
          // null = multiplayer (both human); true/false = player colour vs AI
          playerColor: _modeIndex == 1 ? null : _playAsWhite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0D1128)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ── Back button ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ── Hero ─────────────────────────────────────────────
                        const Text('♟', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 8),
                        const Text('Chess',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('Configure your game',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.38),
                                fontSize: 13)),
                        const SizedBox(height: 30),

                        // ── Mode cards ───────────────────────────────────────
                        _sectionLabel('Game Mode'),
                        const SizedBox(height: 10),
                        _buildModeSelector(),
                        const SizedBox(height: 22),

                        // ── Difficulty / colour (vs AI) OR info (multiplayer) ─
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _modeIndex == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionLabel('Difficulty'),
                                    const SizedBox(height: 10),
                                    _buildDifficultyPicker(),
                                    const SizedBox(height: 22),
                                    _sectionLabel('Play As'),
                                    const SizedBox(height: 10),
                                    _buildColorPicker(),
                                  ],
                                )
                              : _buildMultiplayerInfo(),
                        ),

                        const SizedBox(height: 30),

                        // ── Start button ─────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor:
                                  const Color(0xFF6366F1).withOpacity(0.45),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow_rounded, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  _modeIndex == 1
                                      ? 'Start Multiplayer'
                                      : 'Play vs AI',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8),
      );

  // ── Mode selector ──────────────────────────────────────────────────────────

  Widget _buildModeSelector() {
    return Row(children: [
      Expanded(
          child: _buildModeCard(
              0, Icons.smart_toy_rounded, 'vs AI', 'Challenge the computer')),
      const SizedBox(width: 12),
      Expanded(
          child: _buildModeCard(
              1, Icons.people_rounded, 'Local 2P', 'Pass & play, one device')),
    ]);
  }

  Widget _buildModeCard(int idx, IconData icon, String title, String sub) {
    final sel = _modeIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _modeIndex = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          gradient: sel
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)])
              : LinearGradient(colors: [
                  const Color(0xFF1A1F3A).withOpacity(0.8),
                  const Color(0xFF131829).withOpacity(0.8),
                ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.08),
            width: sel ? 2 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 2)
                ]
              : [],
        ),
        child: Column(children: [
          Icon(icon, color: sel ? Colors.white : Colors.white38, size: 30),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  color: sel ? Colors.white : Colors.white60,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: (sel ? Colors.white : Colors.white38).withOpacity(0.65),
                  fontSize: 10)),
        ]),
      ),
    );
  }

  // ── Difficulty picker ─────────────────────────────────────────────────────

  Widget _buildDifficultyPicker() {
    return Column(children: [
      for (final d in AiDifficulty.values) _buildDifficultyTile(d),
    ]);
  }

  Widget _buildDifficultyTile(AiDifficulty d) {
    final sel = _difficulty == d;
    final cfg = _diffConfig(d);
    return GestureDetector(
      onTap: () => setState(() => _difficulty = d),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel
              ? cfg.color.withOpacity(0.13)
              : const Color(0xFF1A1F3A).withOpacity(0.55),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: sel ? cfg.color.withOpacity(0.65) : Colors.white.withOpacity(0.06),
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cfg.color.withOpacity(0.13),
              border: Border.all(color: cfg.color.withOpacity(0.35), width: 1.5),
            ),
            child: Center(child: Text(cfg.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cfg.label,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(cfg.desc,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35), fontSize: 10)),
                ]),
          ),
          if (sel)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cfg.color.withOpacity(0.18),
                  border: Border.all(color: cfg.color, width: 1.5)),
              child: Icon(Icons.check, size: 11, color: cfg.color),
            ),
        ]),
      ),
    );
  }

  // ── Color picker ──────────────────────────────────────────────────────────

  Widget _buildColorPicker() {
    return Row(children: [
      Expanded(child: _buildColorTile(true)),
      const SizedBox(width: 12),
      Expanded(child: _buildColorTile(false)),
    ]);
  }

  Widget _buildColorTile(bool isWhite) {
    final sel = _playAsWhite == isWhite;
    return GestureDetector(
      onTap: () => setState(() => _playAsWhite = isWhite),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: sel
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isWhite
                      ? [const Color(0xFFF0EAD6), const Color(0xFFD4C99A)]
                      : [const Color(0xFF4A3728), const Color(0xFF1A0E08)])
              : LinearGradient(colors: [
                  const Color(0xFF1A1F3A).withOpacity(0.7),
                  const Color(0xFF131829).withOpacity(0.7),
                ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel
                ? (isWhite ? const Color(0xFFD4C99A) : const Color(0xFF6366F1))
                : Colors.white.withOpacity(0.07),
            width: sel ? 2 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.25),
                      blurRadius: 12)
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isWhite ? '♔' : '♚',
                style: TextStyle(
                    fontSize: 36,
                    color: sel
                        ? (isWhite ? Colors.black87 : Colors.white)
                        : Colors.white38)),
            const SizedBox(height: 6),
            Text(isWhite ? 'White' : 'Black',
                style: TextStyle(
                    color: sel
                        ? (isWhite ? Colors.black87 : Colors.white)
                        : Colors.white38,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(isWhite ? 'Go first' : 'AI goes first',
                style: TextStyle(
                    color: (sel
                            ? (isWhite ? Colors.black : Colors.white)
                            : Colors.white)
                        .withOpacity(0.38),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Multiplayer info ──────────────────────────────────────────────────────

  Widget _buildMultiplayerInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A).withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF34D399).withOpacity(0.1),
            border: Border.all(
                color: const Color(0xFF34D399).withOpacity(0.35), width: 1.5),
          ),
          child: const Center(child: Text('🤝', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Pass & Play',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                'Two players take turns on the same device. '
                'The board flips automatically after each move.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.38), fontSize: 11)),
          ]),
        ),
      ]),
    );
  }

  // ── Difficulty config ─────────────────────────────────────────────────────

  _DiffConfig _diffConfig(AiDifficulty d) {
    return switch (d) {
      AiDifficulty.beginner => _DiffConfig(
          label: 'Beginner',
          desc: 'Random moves — perfect for learning',
          emoji: '🌱',
          color: const Color(0xFF34D399)),
      AiDifficulty.intermediate => _DiffConfig(
          label: 'Intermediate',
          desc: 'Captures & checks first — a real challenge',
          emoji: '⚔️',
          color: const Color(0xFFFBBF24)),
      AiDifficulty.professional => _DiffConfig(
          label: 'Professional',
          desc: 'Minimax search — plays like an expert',
          emoji: '🏆',
          color: const Color(0xFFEF4444)),
    };
  }
}

class _DiffConfig {
  final String label, desc, emoji;
  final Color color;
  _DiffConfig(
      {required this.label,
      required this.desc,
      required this.emoji,
      required this.color});
}
