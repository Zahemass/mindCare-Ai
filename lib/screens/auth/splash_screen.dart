import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rippleController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  void _navigateToNext() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      if (authProvider.currentUser?.isAssessmentCompleted == true) {
        context.go('/home');
      } else {
        context.go('/assessment');
      }
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rippleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE8F5F5),
              const Color(0xFFD1EFEF),
              const Color(0xFFB8E8E8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft floating circles background
            ...List.generate(8, (index) {
              return AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  final offset = math.sin(_floatController.value * 2 * math.pi + index) * 20;
                  final size = 150.0 + (index * 30.0);
                  final opacity = 0.03 + (index % 3) * 0.02;

                  return Positioned(
                    left: (index % 3) * MediaQuery.of(context).size.width / 3 - size / 2,
                    top: (index ~/ 3) * MediaQuery.of(context).size.height / 3 - size / 2 + offset,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4DB8AC).withOpacity(opacity),
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo area with ripples
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple effects
                          ...List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _rippleController,
                              builder: (context, child) {
                                final delay = index * 0.33;
                                final value = (_rippleController.value - delay).clamp(0.0, 1.0);
                                final scale = 1.0 + (value * 0.8);

                                return Opacity(
                                  opacity: ((1.0 - value) * 0.25).clamp(0.0, 0.25),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF4DB8AC),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // Main logo circle
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              final float = math.sin(_floatController.value * 2 * math.pi) * 8;

                              return Transform.translate(
                                offset: Offset(0, float),
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4DB8AC).withOpacity(0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 80,
                                      color: Color(0xFF4DB8AC),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Decorative floating elements
                          ...List.generate(6, (index) {
                            return AnimatedBuilder(
                              animation: _rippleController,
                              builder: (context, child) {
                                final angle = (_rippleController.value * 2 * math.pi) + (index * math.pi / 3);
                                final radius = 110.0;
                                final x = radius * math.cos(angle);
                                final y = radius * math.sin(angle);
                                final scale = 1.0 + math.sin(_rippleController.value * 4 * math.pi + index) * 0.3;

                                return Transform.translate(
                                  offset: Offset(x, y),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4DB8AC).withOpacity(0.6),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4DB8AC).withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // App name
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              Text(
                                'MindCare AI',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF4DB8AC).withOpacity(0.1),
                                      offset: const Offset(0, 4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Your Mental Wellness Companion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(0xFF5A6C7D),
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 60),

                    // Get Started Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DB8AC).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _navigateToNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DB8AC),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
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

            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB8AC).withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Powered by Advanced AI',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF5A6C7D).withOpacity(0.7),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB8AC).withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
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
}
