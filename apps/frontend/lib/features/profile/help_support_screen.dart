import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label, String copiedMsg) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label $copiedMsg'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
          child: Column(
            children: [
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.help,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.getHelp,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, l10n.contactUs),
                      const SizedBox(height: 12),
                      _buildGlassContainer(
                        child: Column(
                          children: [
                            _buildContactTile(
                              icon: Icons.email_outlined,
                              title: l10n.emailSupport,
                              subtitle: 'support@truthlens.com',
                              onTap: () => _copyToClipboard(
                                context,
                                'support@truthlens.com',
                                l10n.emailSupport,
                                l10n.copiedToClipboard,
                              ),
                            ),
                            _buildDivider(),
                            _buildContactTile(
                              icon: Icons.language,
                              title: l10n.visitWebsite,
                              subtitle: 'www.truthlens.com',
                              onTap: () => _copyToClipboard(
                                context,
                                'www.truthlens.com',
                                l10n.visitWebsite,
                                l10n.copiedToClipboard,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader(context, l10n.frequentlyAskedQuestions),
                      const SizedBox(height: 12),
                      _buildGlassContainer(
                        child: Column(
                          children: [
                            _buildFAQTile(
                              context,
                              question: l10n.faq1Q,
                              answer: l10n.faq1A,
                            ),
                            _buildDivider(),
                            _buildFAQTile(
                              context,
                              question: l10n.faq2Q,
                              answer: l10n.faq2A,
                            ),
                            _buildDivider(),
                            _buildFAQTile(
                              context,
                              question: l10n.faq3Q,
                              answer: l10n.faq3A,
                            ),
                            _buildDivider(),
                            _buildFAQTile(
                              context,
                              question: l10n.faq4Q,
                              answer: l10n.faq4A,
                            ),
                            _buildDivider(),
                            _buildFAQTile(
                              context,
                              question: l10n.faq5Q,
                              answer: l10n.faq5A,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader(context, l10n.resources),
                      const SizedBox(height: 12),
                      _buildGlassContainer(
                        child: Column(
                          children: [
                            _buildResourceTile(
                              icon: Icons.menu_book,
                              title: l10n.userGuide,
                              subtitle: l10n.learnHowToUse,
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildResourceTile(
                              icon: Icons.privacy_tip_outlined,
                              title: l10n.privacyPolicy,
                              subtitle: l10n.readPrivacyPolicy,
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildResourceTile(
                              icon: Icons.description_outlined,
                              title: l10n.termsOfService,
                              subtitle: l10n.readTermsOfService,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Truth Lens',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
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
          child: child,
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.secondary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white.withValues(alpha: 0.3),
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFAQTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        iconColor: AppColors.secondary,
        collapsedIconColor: Colors.white.withValues(alpha: 0.6),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.secondary,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white.withValues(alpha: 0.3),
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}
