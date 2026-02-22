import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme_config.dart';
import '../../providers/resource_provider.dart';
import '../../models/resource.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Anxiety',
    'Depression',
    'Sleep',
    'Stress',
    'Mindfulness',
    'Crisis',
    'Self-Care',
    'Relationships'
  ];

  @override
  void initState() {
    super.initState();
    // In this updated version, resources are already initialized in the provider
    // but we can still call fetch if we want to sync with backend 
    // context.read<ResourceProvider>().fetchResources();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Wellness Library',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.darkText,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: Consumer<ResourceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.resources.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final resources = _selectedCategory == 'All'
                    ? provider.resources
                    : provider.resources
                        .where((r) =>
                            r.category.toLowerCase() ==
                            _selectedCategory.toLowerCase())
                        .toList();

                if (resources.isEmpty) {
                  return Center(
                    child: Text('No resources found in this category.',
                        style: GoogleFonts.montserrat(
                            color: ThemeConfig.mutedText)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65, // Reduced from 0.8 to give more height
                  ),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    return _buildResourceCard(resources[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: ThemeConfig.primaryTeal,
              labelStyle: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : (isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.darkText),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
              side: isDark ? const BorderSide(color: ThemeConfig.darkBorder) : BorderSide.none,
              elevation: 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'anxiety':
        return Icons.psychology;
      case 'depression':
        return Icons.mood_bad;
      case 'stress':
        return Icons.bolt;
      case 'sleep':
        return Icons.nights_stay;
      case 'mindfulness':
        return Icons.spa;
      case 'crisis':
        return Icons.warning_rounded;
      case 'self-care':
        return Icons.favorite;
      case 'relationships':
        return Icons.people;
      default:
        return Icons.article;
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'anxiety':
        return const LinearGradient(
          colors: [Color(0xFF1ABC9C), Color(0xFF66D2CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'depression':
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'stress':
        return const LinearGradient(
          colors: [Color(0xFFE67E22), Color(0xFFD35400)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sleep':
        return const LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mindfulness':
        return const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'crisis':
        return const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'self-care':
        return const LinearGradient(
          colors: [Color(0xFFF06292), Color(0xFFEC407A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'relationships':
        return const LinearGradient(
          colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return ThemeConfig.primaryGradient;
    }
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  Widget _buildResourceCard(Resource resource) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: ThemeConfig.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchURL(resource.mediaUrl),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80, // Reduced from 100 to prevent overflow
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _getCategoryGradient(resource.category),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(resource.category),
                  size: 40, // Reduced from 50
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12), // Reduced from 16
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      resource.category.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 9, // Reduced from 10
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    resource.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 14, // Reduced from 16
                      fontWeight: FontWeight.bold,
                      color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText),
                      const SizedBox(width: 4),
                      Text(
                        '${resource.readTimeMinutes}m',
                        style: GoogleFonts.montserrat(
                            fontSize: 10, color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText),
                      ),
                      const Spacer(),
                      Text(
                        'Read',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryTeal,
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 14, color: ThemeConfig.primaryTeal),
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
}
