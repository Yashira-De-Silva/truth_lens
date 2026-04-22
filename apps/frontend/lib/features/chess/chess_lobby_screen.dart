import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/services/follow_service.dart' as svc;
import '../social/follow_provider.dart';
import 'chess_provider.dart';
import 'chess_screen.dart';
import 'chess_service.dart' as chess;
import '../game/chess_lobby_screen.dart' as offline_lobby;

class ChessLobbyScreen extends ConsumerWidget {
  const ChessLobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesState = ref.watch(chessGamesProvider);
    final followingAsync = ref.watch(followingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '♟ Chess',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Play with your followers',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          ref.refresh(chessGamesProvider.notifier).load(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Solo Modes ───────────────────────────────
                      _sectionHeader('Solo Play'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SoloModeCard(
                              title: 'Play vs AI',
                              subtitle: 'Challenge the CPU',
                              icon: '🤖',
                              color: const Color(0xFF6366F1),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const offline_lobby.ChessLobbyScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SoloModeCard(
                              title: 'Local 2P',
                              subtitle: 'Pass & Play',
                              icon: '🤝',
                              color: const Color(0xFF34D399),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const offline_lobby.ChessLobbyScreen(initialMode: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Active / Pending Games ─────────────────────
                      if (gamesState.isLoading) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ] else if (gamesState.games.isNotEmpty) ...[
                        _sectionHeader('My Games'),
                        const SizedBox(height: 10),
                        ...gamesState.games.map(
                          (g) => _GameCard(
                            game: g,
                            onTap: () => _openGame(context, ref, g),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Challenge a Follower ───────────────────────
                      _sectionHeader('Challenge a Follower'),
                      const SizedBox(height: 10),
                      followingAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        error: (_, __) => Center(
                          child: Text(
                            'Could not load followers',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        data: (users) => users.isEmpty
                            ? _emptyFollowing()
                            : Column(
                                children: users
                                    .map(
                                      (u) => _FollowerChallengeTile(
                                        user: u,
                                        onChallenge: () =>
                                            _challenge(context, ref, u),
                                      ),
                                    )
                                    .toList(),
                              ),
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

  Widget _sectionHeader(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _emptyFollowing() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 56,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 14),
          Text(
            'Follow people to challenge them',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );

  void _openGame(
    BuildContext context,
    WidgetRef ref,
    chess.ChessGameModel game,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChessScreen(gameId: game.id)),
    ).then((_) => ref.read(chessGamesProvider.notifier).load());
  }

  Future<void> _challenge(
    BuildContext context,
    WidgetRef ref,
    svc.FollowUser user,
  ) async {
    final game = await ref.read(chessGamesProvider.notifier).challenge(user.id);
    if (context.mounted) {
      if (game != null) {
        AppSnackbar.showSuccess(context, 'Challenge sent to ${user.name}!');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChessScreen(gameId: game.id)),
        ).then((_) => ref.read(chessGamesProvider.notifier).load());
      } else {
        final err = ref.read(chessGamesProvider).error ?? 'Failed to challenge';
        AppSnackbar.showError(context, err);
      }
    }
  }
}

// ── Solo Mode Card ────────────────────────────────────────────────────────────

class _SoloModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _SoloModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Game List Card ────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final chess.ChessGameModel game;
  final VoidCallback onTap;
  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (game.status) {
      case 'waiting':
        statusColor = Colors.orange;
        statusLabel = '⏳ Waiting';
        break;
      case 'active':
        statusColor = AppColors.success;
        statusLabel = game.isMyTurn ? '🟢 Your Turn' : '⏸ Their Turn';
        break;
      case 'finished':
        statusColor = Colors.grey;
        statusLabel = '🏁 Finished';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = game.status;
    }

    final opponent = game.myColor == 'white'
        ? game.blackPlayer
        : game.whitePlayer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: game.isMyTurn && game.status == 'active'
                  ? AppColors.success.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              const Text('♟', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${opponent.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You play ${game.myColor ?? "—"} · ${game.moves.length} moves',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Follower Challenge Tile ───────────────────────────────────────────────────

class _FollowerChallengeTile extends StatelessWidget {
  final svc.FollowUser user;
  final VoidCallback onChallenge;
  const _FollowerChallengeTile({required this.user, required this.onChallenge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
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
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: onChallenge,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('♟', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
}
