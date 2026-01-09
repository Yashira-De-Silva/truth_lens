import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import 'edit_profile_screen.dart';
import 'profile_provider.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userName;
  final String userEmail;
  final String? userBio;
  final String? profileVisibility;
  final bool isOwnProfile;
  final bool isPremium;

  const PublicProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userBio,
    this.profileVisibility = 'public',
    this.isOwnProfile = false,
    this.isPremium = false,
  });

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  String? _currentVisibility;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    if (widget.isOwnProfile) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentVisibility = prefs.getString('profile_visibility') ?? 'public';
      });
    } else {
      setState(() {
        _currentVisibility = widget.profileVisibility;
      });
    }
  }

  Future<void> _showVisibilityDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text(
          'Profile Visibility',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisibilityOption(
              ctx,
              'public',
              'Public',
              'Anyone can see your profile',
              Icons.public,
            ),
            const SizedBox(height: 12),
            _buildVisibilityOption(
              ctx,
              'friends',
              'Friends Only',
              'Only your friends can see your profile',
              Icons.people,
            ),
            const SizedBox(height: 12),
            _buildVisibilityOption(
              ctx,
              'private',
              'Private',
              'Only you can see your profile',
              Icons.lock,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_visibility', result);
      setState(() {
        _currentVisibility = result;
      });
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          'Profile visibility updated to ${_getVisibilityLabel(result)}',
        );
      }
    }
  }

  Widget _buildVisibilityOption(
    BuildContext ctx,
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _currentVisibility == value;
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? _getVisibilityColor(value).withValues(alpha: 0.2)
              : const Color(0xFF1A1F3A).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _getVisibilityColor(value)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? _getVisibilityColor(value)
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? _getVisibilityColor(value)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: _getVisibilityColor(value)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final stats = {'Articles Read': '127', 'Comments': '45', 'Bookmarks': '23'};

    // If viewing own profile, use live data from profile provider
    final profile = widget.isOwnProfile ? ref.watch(profileProvider) : null;
    final displayName = widget.isOwnProfile ? profile!.name : widget.userName;
    final displayEmail = widget.isOwnProfile
        ? profile!.email
        : widget.userEmail;
    final displayBio = widget.isOwnProfile
        ? profile!.bio
        : (widget.userBio ?? '');
    final displayVisibility =
        _currentVisibility ?? widget.profileVisibility ?? 'public';

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
                        widget.isOwnProfile
                            ? 'Profile Preview'
                            : 'User Profile',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (widget.isOwnProfile) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Preview',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0B1220,
                            ).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Icon(
                                Icons.edit,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (widget.isOwnProfile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'This is how others see your profile',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Profile Picture and Info
                      Container(
                        padding: const EdgeInsets.all(24),
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
                            child: Column(
                              children: [
                                // Avatar (shows saved image for own profile)
                                Consumer(
                                  builder: (context, ref, _) {
                                    final profile = ref.watch(profileProvider);
                                    final avatarPath = widget.isOwnProfile
                                        ? profile.avatarPath
                                        : null;

                                    if (avatarPath != null && avatarPath.isNotEmpty && File(avatarPath).existsSync()) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: FileImage(File(avatarPath)),
                                        ),
                                      );
                                    }

                                    // Fallback to initial if no avatar image
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.secondary.withValues(
                                              alpha: 0.6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          displayName.isNotEmpty
                                              ? displayName[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (displayVisibility == 'public' ||
                                    displayVisibility == 'friends')
                                  Text(
                                    displayEmail,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                if (displayBio.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    displayBio,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                // Badges Row
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    // Premium Badge
                                    if (widget.isPremium)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFD700),
                                              Color(0xFFFFA500),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.workspace_premium,
                                              size: 14,
                                              color: Color(0xFF1A1F3A),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Premium',
                                              style: TextStyle(
                                                color: Color(0xFF1A1F3A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Visibility Badge - Make it clickable if own profile
                                    GestureDetector(
                                      onTap: widget.isOwnProfile
                                          ? _showVisibilityDialog
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getVisibilityColor(
                                            displayVisibility,
                                          ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _getVisibilityColor(
                                              displayVisibility,
                                            ).withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getVisibilityIcon(
                                                displayVisibility,
                                              ),
                                              size: 14,
                                              color: _getVisibilityColor(
                                                displayVisibility,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _getVisibilityLabel(
                                                displayVisibility,
                                              ),
                                              style: TextStyle(
                                                color: _getVisibilityColor(
                                                  displayVisibility,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (widget.isOwnProfile) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.edit,
                                                size: 12,
                                                color: _getVisibilityColor(
                                                  displayVisibility,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: stats.entries.map((stat) {
                                return Column(
                                  children: [
                                    Text(
                                      stat.value,
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      stat.key,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Recent Activity
                      _buildSectionTitle('Recent Activity'),
                      const SizedBox(height: 12),
                      _buildActivityItem(
                        'Commented on',
                        'AI Revolutionizes News Verification',
                        '2h ago',
                      ),
                      const SizedBox(height: 8),
                      _buildActivityItem(
                        'Bookmarked',
                        'Political Summit Addresses Climate Change',
                        '5h ago',
                      ),
                      const SizedBox(height: 8),
                      _buildActivityItem(
                        'Read',
                        'Stock Market Reaches New Heights',
                        '1d ago',
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActivityItem(String action, String article, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(action),
              color: AppColors.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      action,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  article,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String action) {
    switch (action.toLowerCase()) {
      case 'commented on':
        return Icons.comment;
      case 'bookmarked':
        return Icons.bookmark;
      case 'read':
        return Icons.article;
      default:
        return Icons.circle;
    }
  }

  Color _getVisibilityColor(String visibility) {
    switch (visibility) {
      case 'public':
        return AppColors.success;
      case 'friends':
        return AppColors.accent;
      case 'private':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'public':
        return Icons.public;
      case 'friends':
        return Icons.people;
      case 'private':
        return Icons.lock;
      default:
        return Icons.public;
    }
  }

  String _getVisibilityLabel(String visibility) {
    switch (visibility) {
      case 'public':
        return 'Public';
      case 'friends':
        return 'Friends Only';
      case 'private':
        return 'Private';
      default:
        return 'Public';
    }
  }
}
