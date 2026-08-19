import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/features/gold_prices/presentation/screens/calculator_screen.dart';

import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/shell/shell_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../gold_prices/presentation/screens/all_prices_screen.dart';
import '../../../gold_prices/presentation/screens/home_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: BlocBuilder<ShellCubit, int>(
        builder: (context, index) {
          return Scaffold(
            backgroundColor: c.background,
            // IndexedStack keeps every tab alive, so scroll positions
            // and typed input survive tab switches.
            body: IndexedStack(
              index: index,
              children: const [
                HomeScreen(),
                AllPricesScreen(),
                CalculatorScreen(),
              ],
            ),
            bottomNavigationBar: _BottomNav(
              index: index,
              onTap: (i) {
                if (i == 3) {
                  _showSettingsSheet(context);
                } else {
                  context.read<ShellCubit>().goTo(i);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l10n;

    final items = <(IconData, String)>[
      (Icons.trending_up_rounded, l.market),
      (Icons.list_alt_rounded, l.allPrices),
      (Icons.calculate_outlined, l.calculator),
      (Icons.settings_outlined, l.settings),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          // Settings opens a sheet, so it never becomes the active tab.
          final selected = i == index && i != 3;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? c.brass : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    items[i].$1,
                    size: 21,
                    color: selected ? c.onBrass : c.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].$2,
                  style: AppText.label(
                    10.5,
                    color: selected ? c.brass : c.textMuted,
                    weight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ───────────────────── Settings sheet ─────────────────────

void _showSettingsSheet(BuildContext context) {
  final c = context.c;
  final l = context.l10n;

  // Captured before the sheet opens so the callbacks stay valid.
  final settingsCubit = context.read<SettingsCubit>();
  final authBloc = context.read<AuthBloc>();

  final authState = authBloc.state;
  final user = authState is AuthSuccess ? authState.user : null;

  showModalBottomSheet(
    context: context,
    backgroundColor: c.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return BlocBuilder<SettingsCubit, SettingsState>(
        bloc: settingsCubit,
        builder: (_, settings) {
          final themeLabel = switch (settings.themeMode) {
            ThemeMode.light => l.themeLight,
            ThemeMode.dark => l.themeDark,
            ThemeMode.system => l.themeSystem,
          };

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Account row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: c.brass,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            (user?.greetingName ?? 'G')
                                .characters
                                .first
                                .toUpperCase(),
                            style: AppText.heading(20, color: c.onBrass),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.greetingName ?? l.guest,
                              style:
                                  AppText.heading(17, color: c.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user == null || user.isGuest
                                  ? l.guestSession
                                  : user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.label(12.5,
                                  color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Settings rows ──
                _sheetRow(
                  context,
                  Icons.language_rounded,
                  l.language,
                  settings.locale.languageCode == 'ar'
                      ? 'العربية'
                      : 'English',
                  () => _showPicker(context, [
                    (
                      'English',
                      () => settingsCubit.setLocale(const Locale('en'))
                    ),
                    (
                      'العربية',
                      () => settingsCubit.setLocale(const Locale('ar'))
                    ),
                  ]),
                ),
                _sheetRow(
                  context,
                  Icons.contrast_rounded,
                  l.theme,
                  themeLabel,
                  () => _showPicker(context, [
                    (
                      l.themeLight,
                      () => settingsCubit.setTheme(ThemeMode.light)
                    ),
                    (
                      l.themeDark,
                      () => settingsCubit.setTheme(ThemeMode.dark)
                    ),
                    (
                      l.themeSystem,
                      () => settingsCubit.setTheme(ThemeMode.system)
                    ),
                  ]),
                ),
                _sheetRow(
                  context,
                  Icons.notifications_active_outlined,
                  l.priceAlerts,
                  '',
                  () {},
                ),
                _sheetRow(
                  context,
                  Icons.star_outline_rounded,
                  l.rateApp,
                  '',
                  () {},
                ),
                const SizedBox(height: 18),

                // ── Sign out ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        authBloc.add(const SignOutRequested());
                      },
                      icon: Icon(Icons.logout_rounded,
                          size: 17, color: c.negative),
                      label: Text(l.signOut,
                          style: AppText.micro(11.5, color: c.negative)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.negative),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _sheetRow(
  BuildContext context,
  IconData icon,
  String title,
  String trailing,
  VoidCallback onTap,
) {
  final c = context.c;

  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 19, color: c.textPrimary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: AppText.label(14, color: c.textPrimary)),
              ),
              if (trailing.isNotEmpty)
                Text(trailing,
                    style: AppText.label(13, color: c.textSecondary)),
              const SizedBox(width: 6),
              Icon(
                context.isRtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 18,
                color: c.textMuted,
              ),
            ],
          ),
        ),
      ),
      Divider(height: 1, color: c.divider, indent: 20),
    ],
  );
}

void _showPicker(
  BuildContext context,
  List<(String, VoidCallback)> options,
) {
  final c = context.c;

  showModalBottomSheet(
    context: context,
    backgroundColor: c.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (pickerContext) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (option) => ListTile(
                title: Text(option.$1,
                    style: AppText.label(15, color: c.textPrimary)),
                onTap: () {
                  option.$2();
                  Navigator.pop(pickerContext);
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}