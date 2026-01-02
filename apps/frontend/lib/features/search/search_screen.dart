import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../l10n/app_localizations.dart';
import '../news/article_model.dart';
import '../news/bookmarks_provider.dart';
import '../article/article_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Article> _searchResults = [];
  bool _isSearching = false;

  final List<String> _categories = [
    'All',
    'Politics',
    'Business',
    'Technology',
    'Science',
    'Health',
    'Sports',
    'Entertainment'
  ];

  // Mock search data
  final List<Article> _mockArticles = [
    Article(id: 1, title: 'Breaking: AI Revolutionizes News Verification', summary: 'New AI technology can detect fake news with 98% accuracy using advanced machine learning algorithms.', source: 'Tech News'),
    Article(id: 2, title: 'Political Summit Addresses Climate Change', summary: 'World leaders gather to discuss climate action and sustainable development goals for 2026.', source: 'World Politics'),
    Article(id: 3, title: 'Stock Market Reaches New Heights', summary: 'Technology stocks lead market gains as investors show confidence in AI sector growth.', source: 'Business Today'),
    Article(id: 4, title: 'Medical Breakthrough in Cancer Treatment', summary: 'Scientists develop new immunotherapy that shows promising results in clinical trials.', source: 'Health News'),
    Article(id: 5, title: 'SpaceX Announces Mars Mission Timeline', summary: 'Elon Musk reveals updated plans for the first crewed mission to Mars in 2028.', source: 'Space Journal'),
    Article(id: 6, title: 'Olympics 2026 Preparations Underway', summary: 'Host city unveils state-of-the-art facilities for upcoming Olympic Games.', source: 'Sports World'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with all articles
    _searchResults = _mockArticles;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
      _searchQuery = _searchController.text.toLowerCase();
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      setState(() {
        _searchResults = _mockArticles.where((article) {
          final matchesQuery = _searchQuery.isEmpty ||
              article.title.toLowerCase().contains(_searchQuery) ||
              article.summary.toLowerCase().contains(_searchQuery) ||
              article.source.toLowerCase().contains(_searchQuery);
          
          final matchesCategory = _selectedCategory == 'All' ||
              article.source.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
              article.title.toLowerCase().contains(_selectedCategory.toLowerCase());
          
          return matchesQuery && matchesCategory;
        }).toList();
        _isSearching = false;
      });

      if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.showError(context, '${l10n.noResultsFound} "$_searchQuery"');
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _searchResults = [];
      _selectedCategory = 'All';
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/logo/truthlenslogo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.explore,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Search for articles by keyword or category',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildModernSearchBar(),
              ),

              const SizedBox(height: 16),

              // Category Pills & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildCategoryFilter(),
              ),

              const SizedBox(height: 16),

              // Results
              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Search by keyword',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: AppColors.secondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.6)),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
              if (value.isEmpty) {
                _clearSearch();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildCategoryChip(category, isSelected),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.2)
              : const Color(0xFF0B1220).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppColors.secondary : Colors.white.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _performSearch,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary,
        ),
      );
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildResultCard(_searchResults[index]);
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or categories',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Article article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailsScreen(article: article),
            ),
          );
        },
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.source,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, _) {
                            final bookmarks = ref.watch(bookmarksProvider);
                            final isSaved = bookmarks.any((a) => a.id == article.id);
                            
                            return GestureDetector(
                              onTap: () async {
                                final l10n = AppLocalizations.of(context)!;
                                if (isSaved) {
                                  await ref.read(bookmarksProvider.notifier).removeById(article.id);
                                  if (context.mounted) {
                                    AppSnackbar.showSuccess(context, l10n.removedFromBookmarks);
                                  }
                                } else {
                                  await ref.read(bookmarksProvider.notifier).add(article);
                                  if (context.mounted) {
                                    AppSnackbar.showSuccess(context, l10n.savedToBookmarks);
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                  size: 20,
                                  color: isSaved 
                                      ? AppColors.accent 
                                      : Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2 hours ago',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
