import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme_config.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../models/mood_entry.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  final _uuid = const Uuid();
  String _selectedMoodLabel = 'HAPPY';
  double _stressLevel = 42.0;
  final List<String> _selectedInfluencers = ['Home'];

  final List<Map<String, String>> _moods = [
    {'label': 'SAD', 'emoji': '😢'},
    {'label': 'LOW', 'emoji': '😞'},
    {'label': 'HAPPY', 'emoji': '😊'},
    {'label': 'CALM', 'emoji': '😌'},
    {'label': 'GREAT', 'emoji': '🤩'},
  ];

  final List<Map<String, dynamic>> _influencerOptions = [
    {'label': 'Work', 'icon': '💼'},
    {'label': 'Home', 'icon': '🏠'},
    {'label': 'Health', 'icon': '🍎'},
    {'label': 'Friends', 'icon': '🤝'},
    {'label': 'Sleep', 'icon': '😴'},
    {'label': 'Exercise', 'icon': '🏃'},
  ];

  Future<void> _saveMoodEntry() async {
    final authProvider = context.read<AuthProvider>();
    final moodProvider = context.read<MoodProvider>();

    // Map label back to 1-10 scale
    int moodLevel = 5;
    if (_selectedMoodLabel == 'SAD') moodLevel = 2;
    if (_selectedMoodLabel == 'LOW') moodLevel = 4;
    if (_selectedMoodLabel == 'HAPPY') moodLevel = 6;
    if (_selectedMoodLabel == 'CALM') moodLevel = 8;
    if (_selectedMoodLabel == 'GREAT') moodLevel = 10;

    final entry = MoodEntry(
      id: _uuid.v4(),
      userId: authProvider.currentUser!.id,
      moodLevel: moodLevel,
      triggers: _selectedInfluencers,
      stressLevel: _stressLevel.toInt(),
    );

    await moodProvider.addEntry(entry);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Daily track updated!',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: ThemeConfig.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2C3E50)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your mood helps your AI companion\nunderstand you better.',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: const Color(0xFF7F8C8D),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Mood Selector
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _moods.map((mood) {
                          final isSelected = _selectedMoodLabel == mood['label'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMoodLabel = mood['label']!),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 60 : 50,
                                  height: isSelected ? 60 : 50,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFE0F7F4) : const Color(0xFFF8F9FA),
                                    shape: BoxShape.circle,
                                    border: isSelected 
                                      ? Border.all(color: ThemeConfig.primaryTeal, width: 2)
                                      : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      mood['emoji']!,
                                      style: TextStyle(fontSize: isSelected ? 28 : 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  mood['label']!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? ThemeConfig.primaryTeal : const Color(0xFFBDC3C7),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stress Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stress Level',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          '${_stressLevel.toInt()}%',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ThemeConfig.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'How much pressure do you feel?',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: const Color(0xFF95A5A6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                        activeTrackColor: ThemeConfig.primaryTeal,
                        inactiveTrackColor: const Color(0xFFE0E0E0),
                        thumbColor: ThemeConfig.primaryTeal,
                      ),
                      child: Slider(
                        value: _stressLevel,
                        min: 0,
                        max: 100,
                        onChanged: (value) => setState(() => _stressLevel = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLevelLabel('LOW'),
                          _buildLevelLabel('MEDIUM'),
                          _buildLevelLabel('HIGH'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Influencers
                    Text(
                      'What\'s influencing your mood?',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _influencerOptions.map((option) {
                        final isSelected = _selectedInfluencers.contains(option['label']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedInfluencers.remove(option['label']);
                              } else {
                                _selectedInfluencers.add(option['label']);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE0F7F4) : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected ? ThemeConfig.primaryTeal : const Color(0xFFF0F0F0),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(option['icon']!, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  option['label']!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? ThemeConfig.primaryTeal : const Color(0xFF7F8C8D),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  Icon(Icons.close, size: 14, color: ThemeConfig.primaryTeal),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Submit',
                onPressed: _saveMoodEntry,
                width: double.infinity,
                icon: Icons.check_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFBDC3C7),
        letterSpacing: 0.5,
      ),
    );
  }
}
