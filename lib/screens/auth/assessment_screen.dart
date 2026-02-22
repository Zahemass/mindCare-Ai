import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_container.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Assessment Data
  String? _selectedFocus;
  final List<String> _selectedChallenges = [];
  String? _moodFrequency;

  final List<String> _focusOptions = [
    'Anxiety Management',
    'Stress Reduction',
    'Better Sleep',
    'Emotional Balance',
    'Self-Esteem',
    'Productivity',
  ];

  final List<String> _challengeOptions = [
    'Negative Thinking',
    'Social Anxiety',
    'Work Stress',
    'Sleep Issues',
    'Low Motivation',
    'Relationship Issues',
    'Focus & Concentration',
  ];

  final List<String> _frequencyOptions = [
    'Rarely',
    'Sometimes',
    'Frequently',
    'Almost Always',
  ];

  Future<void> _completeAssessment() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = ApiService();
    final List<Map<String, dynamic>> answers = [
      {'question': 'Primary Focus', 'score': _focusOptions.indexOf(_selectedFocus!) + 1},
      {'question': 'Challenges', 'score': _selectedChallenges.length},
      {'question': 'Frequency of feeling overwhelmed', 'score': _frequencyOptions.indexOf(_moodFrequency!) + 1},
      // Real clinical questions can be added here
      {'question': 'How often do you feel sad?', 'score': 3},
      {'question': 'Do you have trouble sleeping?', 'score': 4},
    ];

    try {
      final result = await apiService.submitAssessment(answers);
      
      // Also update isAssessmentCompleted on user model
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final updatedUser = authProvider.currentUser!.copyWith(
          isAssessmentCompleted: true,
          mentalHealthGoals: [_selectedFocus ?? 'General Well-being', ..._selectedChallenges],
        );
        await authProvider.updateProfile(updatedUser);
      }

      if (mounted) {
        context.go('/assessment-result', extra: {
          'score': result['score'],
          'riskLevel': result['riskLevel'] ?? 'Moderate',
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: ThemeConfig.errorRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isLoading = false;

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAssessment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ThemeConfig.lightBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(ThemeConfig.spacingM, ThemeConfig.spacingM, ThemeConfig.spacingM, 0),
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? ThemeConfig.primaryTeal
                              : ThemeConfig.primaryTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(ThemeConfig.spacingM, 0, ThemeConfig.spacingM, ThemeConfig.spacingM),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          isOutlined: true,
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: ThemeConfig.spacingS),
                    Expanded(
                      child: CustomButton(
                        text: _currentStep == 2 ? 'Complete' : 'Next',
                        onPressed: _canGoNext() ? _nextStep : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canGoNext() {
    if (_currentStep == 0) return _selectedFocus != null;
    if (_currentStep == 1) return _selectedChallenges.isNotEmpty;
    if (_currentStep == 2) return _moodFrequency != null;
    return false;
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your primary focus?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkText,
            ),
          ),
          const SizedBox(height: ThemeConfig.spacingS),
          const Text(
            'Tell us what brings you to MindCare AI so we can personalize your experience.',
            style: TextStyle(fontSize: 14, color: ThemeConfig.mutedText),
          ),
          const SizedBox(height: ThemeConfig.spacingM),
          Expanded(
            child: ListView.builder(
              itemCount: _focusOptions.length,
              itemBuilder: (context, index) {
                final option = _focusOptions[index];
                final isSelected = _selectedFocus == option;
                return Padding(
                  padding: const EdgeInsets.only(bottom: ThemeConfig.spacingS),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFocus = option),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingM, vertical: ThemeConfig.spacingS),
                      color: isSelected ? ThemeConfig.primaryTeal : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What challenges do you face?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkText,
            ),
          ),
          const SizedBox(height: ThemeConfig.spacingS),
          const Text(
            'Select all that apply. This helps us suggest the best activities for you.',
            style: TextStyle(fontSize: 14, color: ThemeConfig.mutedText),
          ),
          const SizedBox(height: ThemeConfig.spacingM),
          Expanded(
            child: ListView.builder(
              itemCount: _challengeOptions.length,
              itemBuilder: (context, index) {
                final option = _challengeOptions[index];
                final isSelected = _selectedChallenges.contains(option);
                return Padding(
                  padding: const EdgeInsets.only(bottom: ThemeConfig.spacingS),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedChallenges.remove(option);
                        } else {
                          _selectedChallenges.add(option);
                        }
                      });
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingM, vertical: ThemeConfig.spacingS),
                      color: isSelected ? ThemeConfig.primaryTeal : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How often do you feel overwhelmed?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.darkText,
            ),
          ),
          const SizedBox(height: ThemeConfig.spacingS),
          const Text(
            'Be honest - we\'re here to help, not to judge.',
            style: TextStyle(fontSize: 14, color: ThemeConfig.mutedText),
          ),
          const SizedBox(height: ThemeConfig.spacingM),
          Expanded(
            child: ListView(
              children: _frequencyOptions.map((option) {
                final isSelected = _moodFrequency == option;
                return Padding(
                  padding: const EdgeInsets.only(bottom: ThemeConfig.spacingS),
                  child: InkWell(
                    onTap: () => setState(() => _moodFrequency = option),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacingM, vertical: ThemeConfig.spacingS),
                      color: isSelected ? ThemeConfig.primaryTeal : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
