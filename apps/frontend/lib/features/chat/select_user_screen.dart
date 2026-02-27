import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';
import 'chat_provider.dart';
import 'chat_service.dart' as svc;
import 'chat_screen.dart';

class SelectUserScreen extends ConsumerStatefulWidget {
  const SelectUserScreen({super.key});

  @override
  ConsumerState<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends ConsumerState<SelectUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openChat(svc.BackendUser user) async {
    if (_navigating) return;
    setState(() => _navigating = true);
    try {
      final token = ref.read(authProvider).token ?? '';
      final conv = await svc.getOrCreateConversation(token, user.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.conversationId,
            otherUser: conv.otherUser,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _navigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(chatUsersProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0A2540)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'New Message',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5)),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.white.withValues(alpha: 0.5)),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => _searchController.clear(),
                                  child: Icon(Icons.clear,
                                      color: Colors.white
                                          .withValues(alpha: 0.5)),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Users list
              Expanded(
                child: usersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60,
                            color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load users',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(chatUsersProvider),
                          child: Text('Retry',
                              style:
                                  TextStyle(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                  ),
                  data: (users) {
                    final filtered = _query.isEmpty
                        ? users
                        : users
                            .where((u) =>
                                u.name.toLowerCase().contains(_query) ||
                                u.email.toLowerCase().contains(_query))
                            .toList();

                    if (filtered.isEmpty) return _buildEmptyState();

                    return Stack(
                      children: [
                        ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _buildUserCard(filtered[index]),
                        ),
                        if (_navigating)
                          Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                      ],
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

  Widget _buildUserCard(svc.BackendUser user) {
    return GestureDetector(
      onTap: () => _openChat(user),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search,
              size: 80, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different name or email',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
