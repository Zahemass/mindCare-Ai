import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class SelfCareScreen extends StatelessWidget {
  const SelfCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Use a specific teal color from the reference image, or fall back to theme
    final Color tealColor = const Color(0xFF1ABC9C); 

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                // If it's a tab, back might not be needed, but reference shows it.
                // If it is in a tab, maybe navigate to home tab?
                // For now, empty or pop if pushed.
              },
            ),
          ),
        ),
        title: Text(
          'Self-Care',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
              child: IconButton(
                icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black),
                onPressed: () {},
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? ThemeConfig.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Find an activity...',
                  hintStyle: TextStyle(color: ThemeConfig.mutedText),
                  prefixIcon: Icon(Icons.search, color: ThemeConfig.mutedText),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All Activities', true, tealColor, isDark),
                  _buildCategoryChip('Meditation', false, tealColor, isDark),
                  _buildCategoryChip('Breathing', false, tealColor, isDark),
                  _buildCategoryChip('Stories', false, tealColor, isDark),
                  _buildCategoryChip('Ambient', false, tealColor, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Today
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Today',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See all',
                    style: TextStyle(color: tealColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeaturedCard(context, tealColor),
            const SizedBox(height: 24),

            // Popular Activities
            Text(
              'Popular Activities',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Adjust card aspect ratio
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActivityCard(
                  context,
                  '5-min Breathing',
                  'Stress Relief',
                  'BEGINNER',
                  const Color(0xFFA57C5B), // Brownish
                  true,
                  tealColor,
                  isDark,
                ),
                _buildActivityCard(
                  context,
                  'Daily Affirmations',
                  'Self Confidence',
                  'ALL LEVELS',
                  const Color(0xFFFACC9B), // Beige
                  false,
                  tealColor,
                  isDark,
                ),
                _buildActivityCard(
                  context,
                  'Guided Zen',
                  'Meditation',
                  '20 MIN',
                  const Color(0xFF2C3E3A), // Dark Green
                  true,
                  tealColor,
                  isDark,
                ),
                _buildActivityCard(
                  context,
                  'Forest...',
                  'Sleep & Focus',
                  'AMBIENT',
                  const Color(0xFF8D8D5A), // Olive
                  false,
                  tealColor,
                  isDark,
                ),
              ],
            ),
            // Add some padding at the bottom for scrolling past the FAB or bottom bar
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, Color activeColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: isSelected ? activeColor : (isDark ? ThemeConfig.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.grey[800]),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Color accentColor) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1506126613408-eca07ce68773?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'), // Placeholder yoga/meditation image
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'RECOMMENDED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Morning Mindset Blast',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    const Text('12 min', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.bolt, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    const Text('High Energy', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const Spacer(),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String title, String subtitle, String tag, Color bgColor, bool isDarkBg, Color accentColor, bool isAppDark) {
    return Container(
      decoration: BoxDecoration(
        color: isAppDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Color Placeholder
            Expanded(
              flex: 4, // More space for image
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      image: bgColor == const Color(0xFFFACC9B) ? 
                        const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1544367563-12123d8965cd?auto=format&fit=crop&w=400&q=80'), fit: BoxFit.cover) : 
                        null,
                    ),
                    child: bgColor != const Color(0xFFFACC9B) ? 
                      Center(
                        child: Icon(
                          Icons.spa, // Placeholder icon
                          color: Colors.white.withOpacity(0.5),
                          size: 40,
                        ),
                      ) : null,
                  ),
                   Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2), // Semi-transparent backing
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: ThemeConfig.mutedText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
