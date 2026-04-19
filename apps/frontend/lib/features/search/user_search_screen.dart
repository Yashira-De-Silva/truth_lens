import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../profile/public_profile_screen.dart';
import '../../core/services/follow_service.dart' as fsvc;
import '../auth/auth_provider.dart';
import '../../core/services/follow_service.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FollowUser> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final token = ref.read(authProvider).token;
      if (token == null) return;

      print('DEBUG: Searching for "$query"...');
      final results = await fsvc.searchUsers(token, query);
      print('DEBUG: Found ${results.length} results.');
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Search Users',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: _isSearching
                    ? _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  'No users found',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  return _buildUserCard(_searchResults[index]);
                                },
                              )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for users',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter a name or email to get started',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
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

  Widget _buildUserCard(FollowUser user) {
    bool canViewProfile = true; // For now all searchable users are public

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicProfileScreen(
                userId: user.id,
                userName: user.name,
                userEmail: user.email,
                userBio: user.bio,
              ),
            ),
          );
        },
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
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (canViewProfile) ...[
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                          if (user.bio != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.bio!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ] else ...[
                          Row(
                            children: [
                              Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Private Profile',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.article,
                              size: 14,
                              color: AppColors.secondary.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.articlesReadCount ?? 0} articles read',
                              style: TextStyle(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (canViewProfile)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

