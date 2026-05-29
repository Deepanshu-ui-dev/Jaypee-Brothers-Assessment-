import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authNotifierProvider.notifier).register(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            password: _passCtrl.text,
          );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) return _buildDesktop(context);
    return _buildMobile(context);
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: Row(
        children: [
          // ── Branding panel ──────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: context.colors.balanceCardGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text('FinTrack',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20)),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Join thousands\nwho track smarter.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 44,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'FinTrack helps you stay on top of every\nrupee — one entry at a time.',
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 56),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: [
                          _ChipBadge(label: '✅ Free forever'),
                          _ChipBadge(label: '🔒 Secure & private'),
                          _ChipBadge(label: '📱 Works everywhere'),
                          _ChipBadge(label: '🌙 Dark mode support'),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Form panel ──────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              color: context.colors.surface,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildForm(context, showLogo: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {bool showLogo = false}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLogo) ...[
            Center(
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: context.colors.balanceCardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 32),
          ],
          Text('Create account',
              style: context.textStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text('Start tracking your finances', style: context.textStyles.caption),
          const SizedBox(height: 40),

          TextFormField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            validator: Validators.name,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.next,
            validator: Validators.password,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(
                  _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18, color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            validator: Validators.confirmPassword(_passCtrl.text),
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18, color: context.colors.textSecondary,
                ),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.expenseBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.expenseRed.withValues(alpha: 0.3)),
              ),
              child: Text(_error!,
                  style: context.textStyles.caption
                      .copyWith(color: context.colors.expenseRed)),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: context.colors.onInk))
                  : const Text('Create Account'),
            ),
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ', style: context.textStyles.caption),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text('Sign In',
                    style: context.textStyles.caption.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }
}
