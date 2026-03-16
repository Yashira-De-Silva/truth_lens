import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/app_snackbar.dart';
import 'settings_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final List<CategoryItem> _categories = [
    CategoryItem(
      id: 'all',
      icon: Icons.dashboard,
      nameEn: 'All',
      nameSi: 'සියල්ල',
      nameTa: 'அனைத்தும்',
    ),
    CategoryItem(
      id: 'politics',
      icon: Icons.account_balance,
      nameEn: 'Politics',
      nameSi: 'දේශපාලනය',
      nameTa: 'அரசியல்',
    ),
    CategoryItem(
      id: 'technology',
      icon: Icons.computer,
      nameEn: 'Technology',
      nameSi: 'තාක්ෂණය',
      nameTa: 'தொழில்நுட்பம்',
    ),
    CategoryItem(
      id: 'sports',
      icon: Icons.sports_soccer,
      nameEn: 'Sports',
      nameSi: 'ක්‍රීඩා',
      nameTa: 'விளையாட்டு',
    ),
    CategoryItem(
      id: 'business',
      icon: Icons.business_center,
      nameEn: 'Business',
      nameSi: 'ව්‍යාපාර',
      nameTa: 'வணிகம்',
    ),
    CategoryItem(
      id: 'health',
      icon: Icons.health_and_safety,
      nameEn: 'Health',
      nameSi: 'සෞඛ්‍යය',
      nameTa: 'சுகாதாரம்',
    ),
    CategoryItem(
      id: 'entertainment',
      icon: Icons.movie,
      nameEn: 'Entertainment',
      nameSi: 'විනෝදාස්වාදය',
      nameTa: 'பொழுதுபோக்கு',
    ),
    CategoryItem(
      id: 'science',
      icon: Icons.science,
      nameEn: 'Science',
      nameSi: 'විද්‍යාව',
      nameTa: 'அறிவியல்',
    ),
  ];

  Set<String> _selectedCategories = {'all'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedCategories = ref.read(settingsProvider).preferredCategories;
      setState(() {
        _selectedCategories = Set<String>.from(savedCategories);
      });
    });
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (categoryId == 'all') {
        _selectedCategories = {'all'};
      } else {
        _selectedCategories.remove('all');
        
        if (_selectedCategories.contains(categoryId)) {
          _selectedCategories.remove(categoryId);
          if (_selectedCategories.isEmpty) {
            _selectedCategories.add('all');
          }
        } else {
          _selectedCategories.add(categoryId);
        }
      }
    });
  }

  void _savePreferences() {
    ref.read(settingsProvider.notifier).setPreferredCategories(_selectedCategories);
    
    final l10n = AppLocalizations.of(context)!;
    final message = _selectedCategories.length == 1
        ? '${_selectedCategories.length} ${l10n.categorySelected}'
        : '${_selectedCategories.length} ${l10n.categoriesSelected}';
    
    AppSnackbar.showSuccess(context, message);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = ref.watch(settingsProvider).language;

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
                        l10n.preferredCategories,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  l10n.customizeNewsFeed,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategories.contains(category.id);
                    final categoryName = languageCode == 'si'
                        ? category.nameSi
                        : languageCode == 'ta'
                            ? category.nameTa
                            : category.nameEn;

                    return _buildCategoryCard(
                      category: category,
                      categoryName: categoryName,
                      isSelected: isSelected,
                      onTap: () => _toggleCategory(category.id),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _savePreferences,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        l10n.saveChanges,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required CategoryItem category,
    required String categoryName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected
                            ? AppColors.secondary
                            : Colors.white.withValues(alpha: 0.7),
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoryName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
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
}

class CategoryItem {
  final String id;
  final IconData icon;
  final String nameEn;
  final String nameSi;
  final String nameTa;

  CategoryItem({
    required this.id,
    required this.icon,
    required this.nameEn,
    required this.nameSi,
    required this.nameTa,
  });
}
