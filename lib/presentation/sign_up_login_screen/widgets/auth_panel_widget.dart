import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/auth_store.dart';
import '../../../core/booking_store.dart';
import '../../../theme/app_theme.dart';

class AuthPanelWidget extends StatefulWidget {
  final VoidCallback onAuthSuccess;
  final VoidCallback? onAdminAccess;

  const AuthPanelWidget({
    required this.onAuthSuccess,
    this.onAdminAccess,
    super.key,
  });

  @override
  State<AuthPanelWidget> createState() => _AuthPanelWidgetState();
}

class _AuthPanelWidgetState extends State<AuthPanelWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Sign In form
  final _signInFormKey = GlobalKey<FormState>();
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up form
  final _signUpFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // In-memory user store (simulates a real auth backend)
  static final Map<String, Map<String, String>> _registeredUsers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _fullNameController.dispose();
    _signUpEmailController.dispose();
    _phoneController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isLoading = false);
      final email = _signInEmailController.text.trim().toLowerCase();
      final password = _signInPasswordController.text;
      final user = _registeredUsers[email];
      if (user != null && user['password'] == password) {
        AuthStore.setCurrentUser(user);
        widget.onAuthSuccess();
      } else if (user == null) {
        _showError('No account found. Please sign up first.');
      } else {
        _showError('Incorrect password. Please try again.');
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      final email = _signUpEmailController.text.trim().toLowerCase();
      if (_registeredUsers.containsKey(email)) {
        _showError(
          'An account with this email already exists. Please sign in.',
        );
        _tabController.animateTo(0);
        return;
      }
      final user = <String, String>{
        'fullName': _fullNameController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'password': _signUpPasswordController.text,
        'role': 'customer',
      };
      _registeredUsers[email] = user;
      AuthStore.setCurrentUser(user);
      BookingStore.addCustomer(
        name: user['fullName']!,
        email: email,
        phone: user['phone']!,
      );
      _showSuccess('Account created! Welcome to E-RELAX.');
      widget.onAuthSuccess();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans(color: Colors.black)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.mutedText.withAlpha(102),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Tab bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: AppTheme.mutedText,
                labelStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
          ),
          // Tab content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: TabBarView(
              controller: _tabController,
              children: [_buildSignInForm(), _buildSignUpForm()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to book your session',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _signInEmailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: 'your@email.com',
                prefixIcon: 'email_outlined',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _signInPasswordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: '••••••••',
                prefixIcon: 'lock_outline',
                suffixIcon: _obscurePassword
                    ? 'visibility_off_outlined'
                    : 'visibility_outlined',
                onSuffixTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  _showError('Password reset: Please contact support.');
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPrimaryButton(
              label: 'Sign In',
              onTap: _handleSignIn,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.mutedText,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.onAdminAccess != null) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: widget.onAdminAccess,
                  child: Text(
                    'Admin access',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create account',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Join E-RELAX for seamless bookings',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: 'Juan Dela Cruz',
                prefixIcon: 'person_outline',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Full name is required';
                }
                if (v.trim().length < 2) return 'Enter your full name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: 'your@email.com',
                prefixIcon: 'email_outlined',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Phone Number'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: '+63 9XX XXX XXXX',
                prefixIcon: 'phone_outlined',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Phone number is required';
                if (v.length < 10) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: 'Min. 8 characters',
                prefixIcon: 'lock_outline',
                suffixIcon: _obscurePassword
                    ? 'visibility_off_outlined'
                    : 'visibility_outlined',
                onSuffixTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Confirm Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: GoogleFonts.dmSans(
                color: AppTheme.onSurfaceDark,
                fontSize: 15,
              ),
              decoration: _fieldDecoration(
                hint: 'Repeat your password',
                prefixIcon: 'lock_outline',
                suffixIcon: _obscureConfirmPassword
                    ? 'visibility_off_outlined'
                    : 'visibility_outlined',
                onSuffixTap: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your password';
                }
                if (v != _signUpPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                  children: [
                    const TextSpan(text: 'By signing up, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPrimaryButton(
              label: 'Create Account',
              onTap: _handleSignUp,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.mutedText,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required String prefixIcon,
    String? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: AppTheme.mutedText, fontSize: 14),
      filled: true,
      fillColor: AppTheme.surfaceVariantDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: CustomIconWidget(
          iconName: prefixIcon,
          color: AppTheme.mutedText,
          size: 20,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffixIcon != null
          ? GestureDetector(
              onTap: onSuffixTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CustomIconWidget(
                  iconName: suffixIcon,
                  color: AppTheme.mutedText,
                  size: 20,
                ),
              ),
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 48),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.primary.withAlpha(128),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
