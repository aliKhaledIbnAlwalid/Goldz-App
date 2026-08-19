import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/widgets/gold_button.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/widgets/auth_card.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context
          .read<AuthBloc>()
          .add(PasswordResetRequested(_emailController.text.trim()));
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
            if (state is PasswordResetSent) {
              setState(() => _sent = true);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: c.negative,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: AuthCard(
                  child: _sent
                      ? _buildSentView(c, l)
                      : _buildFormView(c, l, isLoading),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormView(AppPalette c, dynamic l, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: c.brass, width: 1.2),
              ),
              child: Icon(Icons.lock_reset_rounded, size: 28, color: c.brass),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l.resetPasswordTitle,
            textAlign: TextAlign.center,
            style: AppText.heading(24, color: c.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            l.resetPasswordSubtitle,
            textAlign: TextAlign.center,
            style: AppText.label(13, color: c.textSecondary),
          ),
          const SizedBox(height: 28),
          Text(
            l.email,
            style:
                AppText.label(12.5, color: c.brass, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            style: AppText.label(14, color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon:
                  Icon(Icons.alternate_email, size: 19, color: c.textMuted),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l.emailRequired;
              if (!v.contains('@') || !v.contains('.')) return l.emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 28),
          GoldButton(
            label: l.sendResetLink,
            isLoading: isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                l.backToLogin,
                style: AppText.label(13,
                    color: c.brass, weight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentView(AppPalette c, dynamic l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.positiveSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_email_read_outlined,
                size: 32, color: c.positive),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l.checkYourInbox,
          textAlign: TextAlign.center,
          style: AppText.heading(24, color: c.textPrimary),
        ),
        const SizedBox(height: 10),
        Text(
          l.resetEmailSentBody,
          textAlign: TextAlign.center,
          style: AppText.label(13, color: c.textSecondary),
        ),
        const SizedBox(height: 28),
        GoldButton(
          label: l.backToLogin,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}