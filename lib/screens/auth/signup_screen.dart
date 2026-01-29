import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/assessment');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.error ?? 'Signup failed',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: ThemeConfig.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive spacing
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      resizeToAvoidBottomInset: false, // Ensure layout doesn't break on keyboard, user requested "no scrollable"
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: isSmallScreen ? 1 : 2),
                
                // Icon Logo - Smaller
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.psychology_alt,
                        size: 28,
                        color: ThemeConfig.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join MindCare',
                          style: GoogleFonts.montserrat(
                            fontSize: 20, // Reduced
                            fontWeight: FontWeight.w800,
                            color: ThemeConfig.darkText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Begin your journey',
                          style: GoogleFonts.montserrat(
                            fontSize: 12, // Reduced
                            color: ThemeConfig.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                Spacer(flex: 2),

                // Full Name Field
                _buildFieldLabel('Full Name'),
                const SizedBox(height: 4),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter your name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 12),

                // Email Field
                _buildFieldLabel('Email Address'),
                const SizedBox(height: 4),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 12),

                // Password Field
                _buildFieldLabel('Password'),
                const SizedBox(height: 4),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: ThemeConfig.mutedText.withOpacity(0.5),
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),

                // Confirm Password Field
                _buildFieldLabel('Confirm Password'),
                const SizedBox(height: 4),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Repeat password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: ThemeConfig.mutedText.withOpacity(0.5),
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                ),
                
                const SizedBox(height: 24),

                // Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => GestureDetector(
                    onTap: auth.isLoading ? null : _signup,
                    child: Container(
                      width: double.infinity,
                      height: 50, // Reduced height
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryTeal,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeConfig.primaryTeal.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Create Account',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16, // Reduced
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                
                Spacer(flex: 3),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.montserrat(
                        color: ThemeConfig.mutedText,
                        fontSize: 12, // Reduced
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Log in ',
                        style: GoogleFonts.montserrat(
                          color: ThemeConfig.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12, // Reduced
          fontWeight: FontWeight.w700,
          color: ThemeConfig.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 48, // Fixed height for tighter layout
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontSize: 13, // Reduced
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(
            color: ThemeConfig.mutedText.withOpacity(0.6),
            fontSize: 12,
          ),
          prefixIcon: Icon(prefixIcon, color: ThemeConfig.mutedText.withOpacity(0.6), size: 18),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: ThemeConfig.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ThemeConfig.primaryTeal, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // Centered text vertically
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: ThemeConfig.darkText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
