import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goldz/features/auth/presentation/bloc/auth_event.dart';
import 'package:goldz/features/auth/presentation/bloc/auth_state.dart';
import 'package:goldz/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:goldz/features/auth/presentation/screens/register_screen.dart';
import 'package:goldz/widgets/gold_button.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/widgets/auth_card.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l10n;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: c.negative,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is AuthSuccess) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Logo ──
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: c.surfaceAlt,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.brass, width: 1.2),
                            ),
                            child: Icon(Icons.workspace_premium_rounded,
                                size: 26, color: c.brass),
                          ),
                        ),
                        const SizedBox(height: 22),

                        Text(
                          l.welcomeBack,
                          textAlign: TextAlign.center,
                          style: AppText.heading(26, color: c.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.signInSubtitle,
                          textAlign: TextAlign.center,
                          style: AppText.label(13, color: c.brass),
                        ),
                        const SizedBox(height: 30),

                        // ── Email ──
                        Text(l.email,
                            style: AppText.label(12.5,
                                color: c.brass, weight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: AppText.label(14, color: c.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            prefixIcon: Icon(Icons.alternate_email,
                                size: 19, color: c.textMuted),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l.emailRequired;
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return l.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // ── Password ──
                        Row(
                          children: [
                            Text(l.password,
                                style: AppText.label(12.5,
                                    color: c.brass,
                                    weight: FontWeight.w600)),
                            const Spacer(),
                                                        GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen(),
                                ),
                              ),
                              child: Text(l.forgotPassword,
                                  style: AppText.label(12.5,
                                      color: c.brass,
                                      weight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          style: AppText.label(14, color: c.textPrimary),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline,
                                size: 19, color: c.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return l.passwordRequired;
                            }
                            if (v.length < 6) return l.passwordTooShort;
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        GoldButton(
                          label: l.signIn,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(child: Divider(color: c.divider)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              child: Text(l.or,
                                  style: AppText.micro(11,
                                      color: c.textMuted)),
                            ),
                            Expanded(child: Divider(color: c.divider)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const GuestSignInRequested()),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: c.border),
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(l.continueAsGuest,
                              style: AppText.label(14,
                                  color: c.textPrimary,
                                  weight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l.noAccount,
                                style: AppText.label(13,
                                    color: c.textSecondary)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              ),
                              child: Text(l.signUp,
                                  style: AppText.label(13,
                                      color: c.brass,
                                      weight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}