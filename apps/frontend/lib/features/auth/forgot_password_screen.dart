import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_snackbar.dart';
import 'auth_service.dart' as svc;

enum ForgotPasswordStage { email, otp, reset }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordStage _stage = ForgotPasswordStage.email;
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackbar.showError(context, 'Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await svc.forgotPassword(email);
      AppSnackbar.showSuccess(context, 'Verification code sent to $email');
      setState(() => _stage = ForgotPasswordStage.otp);
    } catch (e) {
      AppSnackbar.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      AppSnackbar.showError(context, 'Enter 6-digit verification code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await svc.verifyOtp(_emailCtrl.text.trim(), otp);
      setState(() => _stage = ForgotPasswordStage.reset);
    } catch (e) {
      AppSnackbar.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (pass.length < 8) {
      AppSnackbar.showError(context, 'Password must be at least 8 characters');
      return;
    }
    if (pass != confirm) {
      AppSnackbar.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await svc.resetPassword(
        email: _emailCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
        password: pass,
      );
      AppSnackbar.showSuccess(context, 'Password reset successfully. Please login.');
      Navigator.pop(context);
    } catch (e) {
      AppSnackbar.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF07243A), Color(0xFF0A2540), Color(0xFF0B4F6A)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.all(28),
                      child: _buildStageContent(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          const Text(
            'Forgot Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case ForgotPasswordStage.email:
        return _buildEmailStage();
      case ForgotPasswordStage.otp:
        return _buildOtpStage();
      case ForgotPasswordStage.reset:
        return _buildResetStage();
    }
  }

  Widget _buildEmailStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset, color: AppColors.secondary, size: 64),
        const SizedBox(height: 20),
        const Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your email address and we will send you a verification code.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildField(
          controller: _emailCtrl,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        _buildButton(
          text: 'Send Verification Code',
          onPressed: _sendOtp,
          loading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildOtpStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined, color: AppColors.secondary, size: 64),
        const SizedBox(height: 20),
        const Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'We have sent a 6-digit code to ${_emailCtrl.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildField(
          controller: _otpCtrl,
          label: 'Verification Code',
          icon: Icons.vpn_key_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 32),
        _buildButton(
          text: 'Verify Code',
          onPressed: _verifyOtp,
          loading: _isLoading,
        ),
        TextButton(
          onPressed: _isLoading ? null : () => setState(() => _stage = ForgotPasswordStage.email),
          child: const Text('Resend Code', style: TextStyle(color: AppColors.secondary)),
        ),
      ],
    );
  }

  Widget _buildResetStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.security, color: AppColors.secondary, size: 64),
        const SizedBox(height: 20),
        const Text(
          'New Password',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Set your new secure password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildField(
          controller: _passCtrl,
          label: 'New Password',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 16),
        _buildField(
          controller: _confirmPassCtrl,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 32),
        _buildButton(
          text: 'Reset Password',
          onPressed: _resetPassword,
          loading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool loading,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
              )
            : Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }
}
