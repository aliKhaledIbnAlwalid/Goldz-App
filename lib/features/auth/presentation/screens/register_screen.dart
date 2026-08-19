import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/widgets/gold_button.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              name: _nameController.text.trim(),
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    Text(l.createYourAccount,
                        style: AppText.heading(28, color: c.textPrimary)),
                    const SizedBox(height: 8),
                    Text(l.createAccountSubtitle,
                        style: AppText.label(13.5, color: c.brass)),
                    const SizedBox(height: 34),

                    _field(
                      label: l.fullName,
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l.nameRequired;
                        }
                        if (v.trim().length < 3) return l.nameTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),

                    _field(
                      label: l.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(height: 22),

                    _field(
                      label: l.password,
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 19,
                          color: c.textMuted,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l.passwordRequired;
                        }
                        if (v.length < 6) return l.passwordTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),

                    _field(
                      label: l.confirmPassword,
                      controller: _confirmController,
                      obscure: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return l.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 36),

                    GoldButton(
                      label: l.createAccount,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.haveAccount,
                            style:
                                AppText.label(13, color: c.textSecondary)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(l.logIn,
                              style: AppText.label(13,
                                  color: c.brass,
                                  weight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Underlined field style from the Stitch mockup.
  Widget _field({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    final c = context.c;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppText.label(12.5,
                color: c.brass, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: AppText.label(15, color: c.textPrimary),
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: suffix,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: c.brass, width: 1.4),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: c.negative),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: c.negative, width: 1.4),
            ),
            errorStyle: AppText.label(11.5, color: c.negative),
          ),
        ),
      ],
    );
  }
}