import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../l10n/app_localizations.dart';
import 'edit_profile_screen.dart';
import 'language_screen.dart';
import 'privacy_security_screen.dart';
import 'categories_screen.dart';
import 'profile_provider.dart';
import 'settings_provider.dart';
import 'public_profile_screen.dart';
import '../search/user_search_screen.dart';
import 'subscription_screen.dart';
import '../game/fact_fiction_game_screen.dart';
import '../game/news_quiz_game_screen.dart';
import '../game/chess_game_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _subscriptionPlan = 'basic';

  @override
  void initState() {
    super.initState();
    _loadSubscriptionPlan();
  }

  Future<void> _loadSubscriptionPlan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _subscriptionPlan = prefs.getString('subscription_plan') ?? 'basic';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Search Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profile,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.manageAccount,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserSearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
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
                            child: Icon(
                              Icons.person_search,
                              color: AppColors.secondary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // User Card
                _buildGlassContainer(
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: ref.watch(profileProvider).avatarPath == null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.secondary.withValues(alpha: 0.3),
                                  AppColors.primary.withValues(alpha: 0.3),
                                ],
                              )
                            : null,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: ref.watch(profileProvider).avatarPath != null
                            ? DecorationImage(
                                image: FileImage(File(ref.watch(profileProvider).avatarPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        ),
                        child: ref.watch(profileProvider).avatarPath == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(profileProvider).name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ref.watch(profileProvider).email,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                            if (ref.watch(profileProvider).bio.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                ref.watch(profileProvider).bio,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (_subscriptionPlan == 'premium')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Premium User',
                                  style: TextStyle(
                                    color: Color(0xFF1A1F3A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── API Key Card ──────────────────────────────────────────
                _buildApiKeyCard(context),
                const SizedBox(height: 24),

                // Preview Profile Button
                GestureDetector(
                  onTap: () async {
                    final profile = ref.read(profileProvider);
                    final prefs = await SharedPreferences.getInstance();
                    final visibility =
                        prefs.getString('profile_visibility') ?? 'public';

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicProfileScreen(
                            userName: profile.name,
                            userEmail: profile.email,
                            userBio: profile.bio,
                            profileVisibility: visibility,
                            isOwnProfile: true,
                            isPremium: _subscriptionPlan == 'premium',
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.preview_outlined,
                                color: AppColors.secondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Preview My Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'See how others view your profile',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Preferences Section
                _buildSectionHeader(l10n.preferences),
                const SizedBox(height: 12),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_active,
                        title: l10n.notifications,
                        subtitle: l10n.notificationsSubtitle,
                        value: ref.watch(settingsProvider).notifications,
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .setNotifications(v),
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.category,
                        title: l10n.preferredCategories,
                        subtitle: l10n.customizeNewsFeed,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CategoriesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Section
                _buildSectionHeader(l10n.account),
                const SizedBox(height: 12),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.bookmark,
                        title: 'Bookmarks',
                        subtitle: 'View your saved articles',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookmarksScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.workspace_premium,
                        title: 'Subscription',
                        subtitle: _subscriptionPlan == 'premium'
                            ? 'Premium Plan'
                            : 'Basic Plan - Upgrade now',
                        iconColor: _subscriptionPlan == 'premium'
                            ? const Color(0xFFFFD700)
                            : null,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen(),
                            ),
                          );
                          // Reload subscription plan when returning
                          _loadSubscriptionPlan();
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.security,
                        title: l10n.privacySecurity,
                        subtitle: l10n.privacySettings,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacySecurityScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.language,
                        title: l10n.language,
                        subtitle: ref
                            .watch(settingsProvider)
                            .languageDisplayName,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fun & Games Section
                _buildSectionHeader('Fun & Games'),
                const SizedBox(height: 12),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.games,
                        title: 'Fact vs Fiction',
                        subtitle: 'Test your news verification skills',
                        iconColor: const Color(0xFFFFD700),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FactFictionGameScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.quiz,
                        title: 'News Quiz Challenge',
                        subtitle: 'Test your news literacy knowledge',
                        iconColor: const Color(0xFF6366F1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewsQuizGameScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.extension,
                        title: 'Chess Game',
                        subtitle: 'Play a classic game of chess',
                        iconColor: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChessGameScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader(l10n.about),
                const SizedBox(height: 12),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.help_outline,
                        title: l10n.help,
                        subtitle: l10n.getHelp,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: l10n.aboutApp,
                        subtitle: l10n.appInfo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.logout,
                        title: l10n.logout,
                        subtitle: l10n.logoutAccount,
                        iconColor: AppColors.error,
                        titleColor: AppColors.error,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildApiKeyCard(BuildContext context) {
    final apiKey = ref.watch(profileProvider).apiKey;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.vpn_key_outlined,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your API Key',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apiKey ?? '------',
                        style: TextStyle(
                          color: apiKey != null
                              ? AppColors.secondary
                              : Colors.white38,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                // Copy button
                if (apiKey != null)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: apiKey));
                      AppSnackbar.showSuccess(context, 'API key copied!');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.copy_outlined,
                        color: AppColors.secondary,
                        size: 18,
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

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(padding: const EdgeInsets.all(20.0), child: child),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondary,
          activeTrackColor: AppColors.secondary.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.secondary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
    );
  }
}
