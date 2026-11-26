import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  user == null ? const _GuestCard() : _UserCard(user: user),
                  const SizedBox(height: 24),
                  _SectionTitle(l10n.settings),
                  const _SettingsCard(),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(l10n.about),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: l10n.appTitle,
                        applicationVersion: '1.0.0',
                        applicationIcon: Icon(Icons.forest_rounded, color: Theme.of(context).colorScheme.primary),
                        children: [Text(l10n.appTagline)],
                      ),
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () async {
                        final ok = await confirm(
                          context,
                          title: l10n.logoutConfirmTitle,
                          body: l10n.logoutConfirmBody,
                          action: l10n.logout,
                        );
                        if (ok) await ref.read(authProvider.notifier).logout();
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l10n.logout),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              child: Text(user.initials, style: theme.textTheme.titleLarge?.copyWith(color: scheme.onPrimary)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: theme.textTheme.titleLarge?.copyWith(color: scheme.onPrimaryContainer)),
                  const SizedBox(height: 2),
                  Text(user.email, style: TextStyle(color: scheme.onPrimaryContainer)),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.profileMemberSince(Formatters.monthYear(user.createdAt, context.localeName)),
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.profileGuest, style: theme.textTheme.titleLarge),
                      Text(l10n.profileGuestBody),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(onPressed: () => context.go('/login'), child: Text(l10n.login)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(onPressed: () => context.go('/register'), child: Text(l10n.register)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingLabel(icon: Icons.palette_outlined, text: l10n.theme),
            // Chips wrap onto new lines on narrow phones instead of squeezing labels.
            _Choices<ThemeMode>(
              selected: settings.themeMode,
              onSelected: controller.setThemeMode,
              options: [
                (ThemeMode.system, Icons.brightness_auto_outlined, l10n.themeSystem),
                (ThemeMode.light, Icons.light_mode_outlined, l10n.themeLight),
                (ThemeMode.dark, Icons.dark_mode_outlined, l10n.themeDark),
              ],
            ),
            const SizedBox(height: 24),
            _SettingLabel(icon: Icons.translate_rounded, text: l10n.language),
            _Choices<String>(
              selected: settings.locale?.languageCode ?? '',
              onSelected: (code) => controller.setLocale(code.isEmpty ? null : Locale(code)),
              options: [
                ('', Icons.phone_android_outlined, l10n.languageSystem),
                ('ru', null, 'Русский'),
                ('en', null, 'English'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}

/// Shown on account-only tabs to guests instead of redirecting away.
class SignInPrompt extends StatelessWidget {
  const SignInPrompt({super.key, required this.from});

  final String from;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMyListings)),
      body: EmptyState(
        icon: Icons.lock_person_outlined,
        title: l10n.signInRequiredTitle,
        body: l10n.signInRequiredBody,
        action: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: () => context.go(Uri(path: '/login', queryParameters: {'from': from}).toString()),
              child: Text(l10n.login),
            ),
            OutlinedButton(onPressed: () => context.go('/register'), child: Text(l10n.register)),
          ],
        ),
      ),
    );
  }
}

class _Choices<T> extends StatelessWidget {
  const _Choices({required this.selected, required this.onSelected, required this.options});

  final T selected;
  final ValueChanged<T> onSelected;
  final List<(T, IconData?, String)> options;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (value, icon, label) in options)
        ChoiceChip(
          avatar: icon == null ? null : Icon(icon),
          showCheckmark: icon == null,
          label: Text(label),
          selected: value == selected,
          onSelected: (_) => onSelected(value),
        ),
    ],
  );
}
