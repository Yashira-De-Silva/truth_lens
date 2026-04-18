import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../news/news_feed_screen.dart';
import '../search/search_screen.dart';
import '../digest/digest_screen.dart';
import '../chat/chats_list_screen.dart';
import '../profile/profile_screen.dart';
import '../ai_assistant/screens/ai_chat_screen.dart';
import '../chat/call_provider.dart';
import '../chat/incoming_call_screen.dart';
import '../auth/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  bool _isIncomingCallShowing = false;

  final List<Widget> _pages = [
    const NewsFeedScreen(),
    const SearchScreen(),
    DigestScreen(),
    const ChatsListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final myIdStr = authState.user?['id']?.toString();

    ref.listen(callProvider, (previous, next) {
      if (next.activeCall != null && next.activeCall!['status'] == 'ringing') {
        final callerId = next.activeCall!['caller_id']?.toString();
        if (callerId == myIdStr) {
          // I am the caller! So I don't show incoming call screen.
          return;
        }
        
        if (!_isIncomingCallShowing) {
          _isIncomingCallShowing = true;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(callData: next.activeCall!),
            ),
          ).then((_) => _isIncomingCallShowing = false);
        }
      } else if (next.activeCall == null) {
        if (_isIncomingCallShowing) {
          Navigator.pop(context); // Dismiss ringing if caller hangs up
          _isIncomingCallShowing = false;
        }
      }
    });

    return Scaffold(
      body: _pages[_index],
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatScreen()),
          );
        },
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _ModernNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _ModernNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;

    final horizontalMargin = screenWidth > 600 ? 24.0 : 16.0;

    final bottomMargin = bottomPadding > 15 ? 8.0 : 16.0;

    final verticalPadding = screenWidth > 600 ? 14.0 : 12.0;

    return Container(
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        bottomMargin + bottomPadding,
      ),
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.article_outlined,
            activeIcon: Icons.article,
            label: AppLocalizations.of(context)!.news,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: AppLocalizations.of(context)!.explore,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: AppLocalizations.of(context)!.digest,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: AppLocalizations.of(context)!.chat,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: AppLocalizations.of(context)!.profile,
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth > 600 ? 26.0 : 24.0;
    final fontSize = screenWidth > 600 ? 12.0 : 11.0;
    final horizontalPadding = screenWidth > 600
        ? 18.0
        : (isActive ? 16.0 : 12.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.secondary
                  : Colors.white.withValues(alpha: 0.6),
              size: iconSize,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.secondary
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: fontSize,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
