import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme_config.dart';
import '../../providers/meditation_provider.dart';
import '../../models/meditation_session.dart';

class SelfCareScreen extends StatefulWidget {
  const SelfCareScreen({super.key});

  @override
  State<SelfCareScreen> createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends State<SelfCareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeditationProvider>().fetchSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color tealColor = const Color(0xFF1ABC9C);

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                centerTitle: true,
                toolbarHeight: 60,
                backgroundColor: isDark ? ThemeConfig.darkBackground : const Color(0xFFF8F9FA),
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, size: 18, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                title: Text(
                  'Keep Mind Calm',
                  style: GoogleFonts.montserrat(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Today
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Recommended Music',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('See all', style: TextStyle(color: tealColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFeaturedCard(context, tealColor),
                      const SizedBox(height: 32),

                      // popular activities 
                      Text(
                        'Mood-Based Music',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      Consumer<MeditationProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading && provider.sessions.isEmpty) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          
                          final sessions = provider.sessions;

                          if (sessions.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  Icon(Icons.spa_outlined, size: 60, color: ThemeConfig.mutedText.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text('No activities found.', style: TextStyle(color: ThemeConfig.mutedText)),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              return _buildActivityCard(context, session, tealColor, isDark);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 140), // More space for expanded mini player
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Mini Player
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildMiniPlayer(tealColor, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Color accentColor) {
    return Consumer<MeditationProvider>(
      builder: (context, provider, _) {
        final session = provider.sessions.isNotEmpty ? provider.sessions.first : null;
        if (session == null) return const SizedBox();

        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: NetworkImage(session.imageUrl ?? 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=800&q=80'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                      child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text(session.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () => provider.playSession(session),
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                            child: Icon(
                              provider.currentSession?.id == session.id && provider.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white
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
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, MeditationSession session, Color accentColor, bool isDark) {
    return Consumer<MeditationProvider>(
      builder: (context, provider, _) {
        final isPlaying = provider.currentSession?.id == session.id && provider.isPlaying;

        return GestureDetector(
          onTap: () => provider.playSession(session),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? ThemeConfig.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: session.imageUrl != null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(session.imageUrl!, fit: BoxFit.cover),
                              )
                            : Center(child: Icon(Icons.spa, color: accentColor, size: 40)),
                        ),
                        if (isPlaying)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.equalizer, color: Colors.white, size: 30),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: accentColor, size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer(Color accentColor, bool isDark) {
    return Consumer<MeditationProvider>(
      builder: (context, provider, _) {
        final session = provider.currentSession;
        if (session == null) return const SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? ThemeConfig.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      session.imageUrl ?? 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=100',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          provider.isPlaying ? 'Now Playing' : 'Paused',
                          style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.description,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 10,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: accentColor),
                    onPressed: () => provider.playSession(session),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop_rounded, color: Colors.redAccent),
                    onPressed: () => provider.stopSession(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: accentColor,
                  inactiveTrackColor: accentColor.withOpacity(0.2),
                  thumbColor: accentColor,
                ),
                child: Slider(
                  value: provider.position.inSeconds.toDouble(),
                  max: provider.totalDuration.inSeconds.toDouble() > 0 
                  ? provider.totalDuration.inSeconds.toDouble() 
                  : 1,
                  onChanged: (val) {
                    provider.seek(Duration(seconds: val.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(provider.position), style: TextStyle(fontSize: 10, color: ThemeConfig.mutedText)),
                    Text(_formatDuration(provider.totalDuration), style: TextStyle(fontSize: 10, color: ThemeConfig.mutedText)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
