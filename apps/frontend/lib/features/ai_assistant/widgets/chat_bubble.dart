import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../models/ai_message.dart';

class ChatBubble extends StatelessWidget {
  final AiMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // ── Main chat bubble ──────────────────────────────────────────────
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary
                  : const Color(0xFF0B1220).withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 16),
              ),
              border: isUser
                  ? null
                  : Border.all(color: AppColors.secondary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),

        // ── Related news cards (only for bot messages) ────────────────────
        if (!isUser && message.relatedNews.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 2),
            child: Row(
              children: [
                Icon(Icons.newspaper_rounded,
                    size: 13, color: AppColors.secondary.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  'Related News',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 145,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              itemCount: message.relatedNews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final news = message.relatedNews[index];
                return _NewsCard(news: news);
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ── News card ────────────────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final RelatedNewsItem news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail or fallback header
            if (news.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  news.thumbnail,
                  height: 65,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackHeader(),
                ),
              )
            else
              _fallbackHeader(),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _sourceIcon(news.source),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          news.source,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewsDetailSheet(news: news),
    );
  }

  Widget _fallbackHeader() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Icon(Icons.article_rounded, color: Colors.white54, size: 22),
    );
  }

  Widget _sourceIcon(String source) {
    if (source == 'Ada Derana') {
      return Icon(Icons.newspaper_rounded, size: 11, color: Colors.redAccent);
    }
    return Icon(Icons.link, size: 11, color: AppColors.secondary);
  }
}

// ── News detail bottom sheet ─────────────────────────────────────────────────

class _NewsDetailSheet extends StatelessWidget {
  final RelatedNewsItem news;
  const _NewsDetailSheet({required this.news});

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      // Try to launch via platform channel (works without url_launcher)
      await SystemChannels.platform.invokeMethod<void>(
        'SystemNavigator.openUrl',
        url,
      );
    } catch (_) {
      // Fallback: show copyable URL dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF0A1628),
            title: const Text('Open Article',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Copy this link to open the article:',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                SelectableText(url,
                    style: TextStyle(
                        color: AppColors.secondary, fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied!')),
                  );
                },
                child: const Text('Copy Link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A1628),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Source badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: news.source == 'Ada Derana'
                                ? Colors.red.withOpacity(0.2)
                                : AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: news.source == 'Ada Derana'
                                  ? Colors.redAccent.withOpacity(0.5)
                                  : AppColors.secondary.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                news.source == 'Ada Derana'
                                    ? Icons.newspaper_rounded
                                    : Icons.public,
                                size: 12,
                                color: news.source == 'Ada Derana'
                                    ? Colors.redAccent
                                    : AppColors.secondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                news.source,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: news.source == 'Ada Derana'
                                      ? Colors.redAccent
                                      : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Thumbnail
                    if (news.thumbnail.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          news.thumbnail,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Divider
                    Divider(color: Colors.white12),

                    const SizedBox(height: 12),

                    // Description
                    if (news.description.isNotEmpty)
                      Text(
                        news.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Read full article button
                    if (news.url.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(context, news.url),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Read Full Article'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
