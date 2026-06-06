import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  UserRole _selectedRole = UserRole.teamMember;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final user = await _authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      role: _selectedRole,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(authService: _authService)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account already exists with this email', style: AppText.body(14)),
          backgroundColor: AppColors.urgent.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Account', style: AppText.display(18, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Join your crew.', style: AppText.display(28, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Create your field account', style: AppText.body(14, color: AppColors.textSecondary)),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _nameController,
                  style: AppText.body(14),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 18, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),

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

                // Role selector
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: _selectedRole,
                      dropdownColor: AppColors.surfaceHigh,
                      style: AppText.body(14),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 20),
                      hint: Text('Select Role', style: AppText.body(14, color: AppColors.textMuted)),
                      items: [
                        _roleItem(UserRole.teamMember,    'Team Member',    AppColors.tm),
                        _roleItem(UserRole.teamLead,      'Team Lead',      AppColors.tl),
                        _roleItem(UserRole.siteManager,   'Site Manager',   AppColors.sm),
                        _roleItem(UserRole.projectManager,'Project Manager',AppColors.pm),
                      ],
                      onChanged: (v) { if (v != null) setState(() => _selectedRole = v); },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppText.body(14),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.textMuted),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: AppText.body(14),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.textMuted),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  label: 'Create Account',
                  color: AppColors.pm,
                  loading: _isLoading,
                  fullWidth: true,
                  onPressed: _signUp,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppText.body(13, color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 28)),
                      child: Text('Sign In', style: AppText.body(13, color: AppColors.pm, weight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<UserRole> _roleItem(UserRole role, String label, Color dot) {
    return DropdownMenuItem(
      value: role,
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: AppText.body(14)),
        ],
      ),
    );
  }
}
