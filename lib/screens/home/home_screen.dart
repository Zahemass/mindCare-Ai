import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme_config.dart';
import '../../widgets/glass_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/meditation_provider.dart';
import '../../providers/navigation_provider.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _meditationController;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'label': 'SAD', 'color': Color(0xFF6C757D)},
    {'emoji': '😞', 'label': 'LOW', 'color': Color(0xFF95A5A6)},
    {'emoji': '😊', 'label': 'HAPPY', 'color': Color(0xFF48C9B0)},
    {'emoji': '😌', 'label': 'CALM', 'color': Color(0xFF5DADE2)},
    {'emoji': '🤩', 'label': 'GREAT', 'color': Color(0xFFE74C3C)},
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _meditationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().fetchFromBackend();
      context.read<JournalProvider>().fetchFromBackend();
      context.read<MeditationProvider>().fetchSessions();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _meditationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? ThemeConfig.darkBackground : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A6B5A),
                    const Color(0xFF152030),
                    ThemeConfig.darkBackground,
                  ]
                : [
                    const Color(0xFF48C9B0),
                    const Color(0xFF48C9B0),
                    const Color(0xFFF5F7FA),
                  ],
            stops: const [0.0, 0.25, 0.4],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.name?.split(' ').first ?? "Alex"}!',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Let\'s check in with yourself today',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w400,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // No more nightlight icon as requested
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Mood Check-in Card
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildMoodCard(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Daily Progress Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Progress',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                                letterSpacing: 0.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/insights'),
                              child: Text(
                                'View Analytics',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF48C9B0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildProgressCard(),

                        const SizedBox(height: 32),

                        // Explore Section
                        Text(
                          'Explore',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAICompanionCard(context),
                        const SizedBox(height: 14),
                        _buildMeditationCard(),

                        const SizedBox(height: 32),

                        // Quick Activities Section
                        Text(
                          'Quick Activities',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActivityCard(
                                'Journaling',
                                '5MIN',
                                Icons.edit_note_rounded,
                                const Color(0xFFE3F2FD),
                                const Color(0xFF5DADE2),
                                onTap: () => context.push('/journals'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildActivityCard(
                                'Wellness Library',
                                'READ',
                                Icons.menu_book_rounded,
                                const Color(0xFFF3E5F5),
                                const Color(0xFFA569BD),
                                onTap: () => context.push('/resources'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildMoodCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodProvider = context.watch<MoodProvider>();
    final todayEntry = moodProvider.getTodayEntry();
    final isTracked = todayEntry != null;
    final streak = moodProvider.getMoodStreak();

    return GestureDetector(
      onTap: isTracked ? null : () => context.push('/mood-check-in'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: ThemeConfig.darkBorder) : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
        ),
        child: isTracked 
          ? Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      todayEntry.moodEmoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Tracked!',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${streak} Day Streak. Keep it up! 🔥',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: ThemeConfig.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: ThemeConfig.primaryTeal, size: 28),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How are you feeling?',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track your daily progress',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: isDark ? ThemeConfig.darkTextSecondary : const Color(0xFF95A5A6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryTeal,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'GO',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: moods.map((mood) {
                    return Opacity(
                      opacity: 0.6,
                      child: Column(
                        children: [
                          Text(
                            mood['emoji'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['label'] as String,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFBDC3C7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Consumer3<MoodProvider, JournalProvider, MeditationProvider>(
      builder: (context, moodProvider, journalProvider, meditationProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        // Calculate real data
        bool hasMood = moodProvider.getTodayEntry() != null;
        bool hasJournal = journalProvider.hasJournaledToday;
        bool hasMeditation = meditationProvider.hasCompletedMeditationToday;

        int completedGoals = 0;
        if (hasMood) completedGoals++;
        if (hasJournal) completedGoals++;
        if (hasMeditation) completedGoals++;

        const int totalGoals = 3;
        double progressPercent = completedGoals / totalGoals;

        String description;
        if (completedGoals == totalGoals) {
          description = 'Amazing! You\'ve completed all your daily mindfulness goals.';
        } else if (completedGoals == 0) {
          description = 'Start your first activity to begin your daily progress.';
        } else {
          description = '$completedGoals of $totalGoals daily mindfulness goals completed.';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? ThemeConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isDark ? Border.all(color: ThemeConfig.darkBorder) : null,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated Circular Progress
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: progressPercent),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: const Size(70, 70),
                          painter: CircularProgressPainter(
                            progress: value,
                            progressColor: const Color(0xFF48C9B0),
                            backgroundColor: isDark ? ThemeConfig.darkCard : const Color(0xFFF0F0F0),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF48C9B0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completedGoals == totalGoals ? 'Perfect Day!' : 'You\'re doing great!',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: isDark ? ThemeConfig.darkTextSecondary : const Color(0xFF7F8C8D),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAICompanionCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/chat'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF48C9B0),
              Color(0xFF38B8A0),
              Color(0xFF2FA890),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF48C9B0).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'AI COMPANION',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Chat with Aria',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Need someone to listen?\nAria is here for you 24/7.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Color(0xFF48C9B0),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: ThemeConfig.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image Section with Smooth Breathing Animation
            AnimatedBuilder(
              animation: _meditationController,
              builder: (context, child) {
                return Container(
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF48C9B0).withOpacity(0.1 + (0.1 * _meditationController.value)),
                        const Color(0xFF5DADE2).withOpacity(0.1 + (0.1 * _meditationController.value)),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer breathing circle
                        Container(
                          width: 50 + (20 * _meditationController.value),
                          height: 50 + (20 * _meditationController.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF48C9B0).withOpacity(0.15),
                            border: Border.all(
                              color: const Color(0xFF48C9B0).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                        ),
                        // Inner circle with icon
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF48C9B0).withOpacity(0.2),
                          ),
                          child: Transform.scale(
                            scale: 0.9 + (0.1 * _meditationController.value),
                            child: const Icon(
                              Icons.self_improvement_rounded,
                              size: 28,
                              color: Color(0xFF48C9B0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zen Morning',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '10 min',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBDC3C7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Guided Meditation',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: const Color(0xFF7F8C8D),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () {
                        context.read<NavigationProvider>().setIndex(2);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF48C9B0),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF48C9B0).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Start Activity',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
      String title,
      String duration,
      IconData icon,
      Color bgColor,
      Color iconColor, {
        VoidCallback? onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 140,
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: ThemeConfig.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : iconColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? iconColor.withOpacity(0.15) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(isDark ? 0.1 : 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? ThemeConfig.darkTextSecondary : const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// Circular Progress Painter
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 4, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          progressColor,
          progressColor.withOpacity(0.7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}