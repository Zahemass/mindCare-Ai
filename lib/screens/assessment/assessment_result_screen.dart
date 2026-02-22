import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme_config.dart';
import '../../widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

class AssessmentResultScreen extends StatelessWidget {
  final int score;
  final String riskLevel;

  const AssessmentResultScreen({
    super.key,
    required this.score,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacingL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getRiskColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRiskIcon(),
                        color: _getRiskColor(),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spacingM),
                    Text(
                      'Your Mental Wellness Score',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: ThemeConfig.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spacingS),
                    Text(
                      '$score',
                      style: GoogleFonts.montserrat(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _getRiskColor(),
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getRiskColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        riskLevel.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spacingL),
                    Text(
                      _getRiskDescription(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: ThemeConfig.darkText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingXL),
              CustomButton(
                text: 'Go to Dashboard',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return const Color(0xFF48C9B0);
      case 'moderate':
        return Colors.orange;
      case 'high':
        return ThemeConfig.errorRed;
      default:
        return ThemeConfig.primaryTeal;
    }
  }

  IconData _getRiskIcon() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Icons.sentiment_very_satisfied;
      case 'moderate':
        return Icons.sentiment_satisfied;
      case 'high':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.psychology;
    }
  }

  String _getRiskDescription() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return "You're doing great! Keep up your mindfulness practice and maintain your mental well-being.";
      case 'moderate':
        return "You're experiencing some challenges. We've customized some activities to help you feel better.";
      case 'high':
        return "It looks like you're going through a tough time. We recommend chatting with our AI or seeking professional support.";
      default:
        return "Thank you for completing the assessment. We've personalized your experience based on your results.";
    }
  }
}
