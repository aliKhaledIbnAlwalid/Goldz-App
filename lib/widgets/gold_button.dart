import 'package:flutter/material.dart';
import 'package:goldz/core/theme/app_palette.dart';
import 'package:goldz/core/theme/app_text.dart';


class GoldButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const GoldButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brass,
          disabledBackgroundColor: c.brass.withOpacity(0.5),
          foregroundColor: c.onBrass,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.onBrass,
                ),
              )
            : Text(
                label,
                style: AppText.label(
                  15,
                  color: c.onBrass,
                  weight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}