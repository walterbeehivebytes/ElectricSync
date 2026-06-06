import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'signup_screen.dart';
import 'password_recovery_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final user = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => HomeScreen(authService: _authService),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password', style: AppText.body(14)),
          backgroundColor: AppColors.urgent.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Geometric accent
            Positioned(
              right: -50, top: -50,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.pm.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Brand header
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.pm.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.pm.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(Icons.bolt, size: 24, color: AppColors.pm),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: 'ELECTRIC', style: AppText.display(22, weight: FontWeight.w900, letterSpacing: 2)),
                            TextSpan(text: 'SYNC',     style: AppText.display(22, weight: FontWeight.w300, color: AppColors.pm, letterSpacing: 2)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),

                    Text('Welcome back.', style: AppText.display(34, weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Sign in to your field account', style: AppText.body(14, color: AppColors.textSecondary)),
                    const SizedBox(height: 32),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppText.body(14),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppColors.textMuted),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppText.body(14),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordRecoveryScreen())),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 28)),
                        child: Text('Forgot Password?', style: AppText.body(13, color: AppColors.pm)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign in button
                    PrimaryButton(
                      label: 'Sign In',
                      color: AppColors.pm,
                      loading: _isLoading,
                      fullWidth: true,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 32),

                    // Demo accounts
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.bolt, size: 15, color: AppColors.pm),
                            const SizedBox(width: 8),
                            Text('DEMO ACCOUNTS', style: AppText.display(11, color: AppColors.textSecondary, letterSpacing: 2, weight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 14),
                          _buildDemoRow(AppColors.pm, 'Project Manager', 'pm@esync.com'),
                          _buildDemoRow(AppColors.sm, 'Site Manager',    'site@esync.com'),
                          _buildDemoRow(AppColors.tl, 'Team Lead',       'lead@esync.com'),
                          _buildDemoRow(AppColors.tm, 'Team Member',     'member@esync.com'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text('password: password123', style: AppText.body(12, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppText.body(13, color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 28)),
                          child: Text('Sign Up', style: AppText.body(13, color: AppColors.pm, weight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ].animate(interval: 40.ms).fade(duration: 380.ms).slideY(begin: 0.08, curve: Curves.easeOutCubic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoRow(Color dot, String role, String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(role, style: AppText.body(13, weight: FontWeight.w600))),
          Text(email, style: AppText.body(12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
