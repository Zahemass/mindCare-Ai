import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/journal_provider.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (mounted) {
        // Trigger data fetch for the new user
        context.read<MoodProvider>().fetchFromBackend();
        context.read<JournalProvider>().fetchFromBackend();
        context.read<ChatProvider>().fetchFromBackend();
      }
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.error ?? 'Login failed',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: ThemeConfig.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen height helper to adjust spacing dynamically if needed
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard opens to keep layout stable, or true if we want it to push up (but user asked for no scroll) -> actually false might hide fields. 
      // User asked for "no scrollable", implying the static layout fits. 
      // If keyboard appears, it usually covers bottom. We'll use false and let user dismiss keyboard or use top fields.
      // Better approach for "fit screen": Use a Column with Expanded/Spacer.
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 32,
                    color: ThemeConfig.primaryTeal,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Welcome Text - Smaller
                Text(
                  'Welcome Back',
                  style: GoogleFonts.montserrat(
                    fontSize: 24, // Reduced
                    fontWeight: FontWeight.w800,
                    color: ThemeConfig.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your mental wellness\ncompanion',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13, // Reduced
                    color: ThemeConfig.mutedText,
                    height: 1.4,
                  ),
                ),
                Spacer(flex: isSmallScreen ? 1 : 2),

                // Email Field
                _buildFieldLabel('Email Address'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel('Password'),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(
                          color: ThemeConfig.primaryTeal,
                          fontWeight: FontWeight.w600,
                          fontSize: 12, // Reduced
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: ThemeConfig.mutedText.withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Password'),
                ),
                const SizedBox(height: 24),

                // Log In Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => GestureDetector(
                    onTap: auth.isLoading ? null : _login,
                    child: Container(
                      width: double.infinity,
                      height: 50, // Reduced height
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryTeal,
                        borderRadius: BorderRadius.circular(14), // Reduced radius
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
                                'Log In',
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
                const SizedBox(height: 24),

                const Spacer(flex: 3),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.montserrat(
                        color: ThemeConfig.mutedText,
                        fontSize: 12, // Reduced
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.montserrat(
                          color: ThemeConfig.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Reduced
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
          fontSize: 13, // Reduced
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
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.montserrat(
        color: ThemeConfig.darkText,
        fontSize: 13, // Reduced
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(
          color: ThemeConfig.mutedText.withOpacity(0.6),
          fontSize: 13, // Reduced
        ),
        prefixIcon: Icon(prefixIcon, color: ThemeConfig.mutedText.withOpacity(0.6), size: 20),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Reduced padding
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Container(
      height: 48, // Reduced height
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
          Icon(icon, color: color, size: 24), // Reduced size
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: ThemeConfig.darkText,
              fontSize: 13, // Reduced
            ),
          ),
        ],
      ),
    );
  }
}
