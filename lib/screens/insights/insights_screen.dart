import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../config/theme_config.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _moodInsights;
  Map<String, dynamic>? _activityInsights;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      _moodInsights = await apiService.getMoodInsights(days: 7);
      _activityInsights = await apiService.getActivityInsights();
    } catch (e) {
      debugPrint('Error fetching insights: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Analytics & Insights',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ThemeConfig.darkText,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInsights,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMoodSection(),
                    const SizedBox(height: 30),
                    _buildActivitySection(),
                    const SizedBox(height: 30),
                    _buildRecommendationsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMoodSection() {
    final summary = _moodInsights?['summary'];
    final distribution = summary?['moodDistribution'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: distribution.isEmpty
                ? const Center(child: Text('Not enough data yet'))
                : PieChart(
                    PieChartData(
                      sections: distribution.entries.map((entry) {
                        return PieChartSectionData(
                          value: (entry.value as num).toDouble(),
                          title: entry.key.toUpperCase(),
                          color: _getMoodColor(entry.key),
                          radius: 50,
                          titleStyle: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total Entries', '${summary?['totalEntries'] ?? 0}'),
              _buildStatCard('Primary Mood', _getTopMood(distribution)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    final totalActivities = _activityInsights?['totalActivities'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Progress',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have completed $totalActivities activities so far!',
            style: GoogleFonts.montserrat(color: ThemeConfig.mutedText),
          ),
          const SizedBox(height: 20),
          // Simple completion bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (totalActivities / 10).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: ThemeConfig.lightSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(ThemeConfig.primaryTeal),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level 1', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Next Level: 10 activities', style: GoogleFonts.montserrat(fontSize: 12, color: ThemeConfig.mutedText)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Personalized For You',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.darkText,
          ),
        ),
        const SizedBox(height: 16),
        _buildRecCard(
          'Mindful Morning',
          'Based on your recent "Anxious" mood, try this 5-min breathing exercise.',
          Icons.air_rounded,
          const Color(0xFF5DADE2),
        ),
        const SizedBox(height: 12),
        _buildRecCard(
          'Gratitude Journaling',
          'You haven\'t journaled today. Expressing gratitude can boost your mood score by 15%.',
          Icons.rate_review_rounded,
          const Color(0xFFF4D03F),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ThemeConfig.primaryTeal,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: ThemeConfig.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildRecCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(fontSize: 12, color: ThemeConfig.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return const Color(0xFF48C9B0);
      case 'sad': return const Color(0xFF5DADE2);
      case 'anxious': return const Color(0xFFF4D03F);
      case 'calm': return const Color(0xFFA569BD);
      case 'angry': return const Color(0xFFE74C3C);
      default: return Colors.grey;
    }
  }

  String _getTopMood(Map<String, dynamic> distribution) {
    if (distribution.isEmpty) return 'N/A';
    String topMood = distribution.keys.first;
    num maxVal = distribution[topMood];
    
    distribution.forEach((key, value) {
      if (value > maxVal) {
        maxVal = value;
        topMood = key;
      }
    });
    
    return topMood.toUpperCase();
  }
}
