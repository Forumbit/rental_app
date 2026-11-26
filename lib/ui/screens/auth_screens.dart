import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Centered card on wide screens, full-bleed on phones.
class _AuthLayout extends StatelessWidget {
  const _AuthLayout({required this.icon, required this.title, required this.subtitle, required this.child});

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(icon, size: 32, color: scheme.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 32),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    this.newPassword = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final bool newPassword;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _hidden,
    autofillHints: [widget.newPassword ? AutofillHints.newPassword : AutofillHints.password],
    textInputAction: widget.onSubmitted == null ? TextInputAction.next : TextInputAction.done,
    onFieldSubmitted: (_) => widget.onSubmitted?.call(),
    validator: widget.validator,
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        tooltip: _hidden ? context.l10n.showPassword : context.l10n.hidePassword,
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      ),
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(message!, style: TextStyle(color: scheme.onErrorContainer)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: busy
          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
          : Text(label),
    ),
  );
}

// ------------------------------------------------------------------- login

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.from, this.email});

  /// Where to return after signing in.
  final String? from;
  final String? email;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).login(_email.text, _password.text);
      TextInput.finishAutofillContext();
      if (mounted) context.go(widget.from ?? '/my');
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.kind == ApiErrorKind.forbidden) {
        // Registered but not verified: continue straight to the code screen.
        context.go(Uri(path: '/verify', queryParameters: {'email': _email.text.trim()}).toString());
        return;
      }
      setState(() => _error = context.l10n.error(e));
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AuthLayout(
      icon: Icons.login_rounded,
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ErrorBanner(_error),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.alternate_email_rounded)),
              validator: (v) => _emailPattern.hasMatch(v?.trim() ?? '') ? null : l10n.emailInvalid,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _password,
              label: l10n.password,
              onSubmitted: _submit,
              validator: (v) => (v?.isEmpty ?? true) ? l10n.formRequired : null,
            ),
            const SizedBox(height: 24),
            _SubmitButton(label: l10n.login, busy: _busy, onPressed: _submit),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.noAccount),
                TextButton(onPressed: () => context.go('/register'), child: Text(l10n.register)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- register

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim().toLowerCase();
    try {
      await ref
          .read(authRepositoryProvider)
          .register(fullName: _name.text.trim(), email: email, password: _password.text);
      if (mounted) context.go(Uri(path: '/verify', queryParameters: {'email': email}).toString());
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AuthLayout(
      icon: Icons.person_add_alt_rounded,
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ErrorBanner(_error),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.fullName, prefixIcon: const Icon(Icons.badge_outlined)),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return l10n.formRequired;
                return value.length > 150 ? l10n.formTooLong(150) : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.alternate_email_rounded)),
              validator: (v) => _emailPattern.hasMatch(v?.trim() ?? '') ? null : l10n.emailInvalid,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _password,
              label: l10n.password,
              newPassword: true,
              validator: (v) {
                // The server limit is 72 bytes (bcrypt), not characters.
                final bytes = utf8Length(v ?? '');
                if (bytes < 8) return l10n.passwordTooShort;
                return bytes > 72 ? l10n.passwordTooLong : null;
              },
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _repeat,
              label: l10n.passwordRepeat,
              newPassword: true,
              onSubmitted: _submit,
              validator: (v) => v == _password.text ? null : l10n.passwordsDiffer,
            ),
            const SizedBox(height: 24),
            _SubmitButton(label: l10n.register, busy: _busy, onPressed: _submit),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.haveAccount),
                TextButton(onPressed: () => context.go('/login'), child: Text(l10n.login)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int utf8Length(String s) {
  var bytes = 0;
  for (final rune in s.runes) {
    bytes += rune < 0x80 ? 1 : (rune < 0x800 ? 2 : (rune < 0x10000 ? 3 : 4));
  }
  return bytes;
}

// ------------------------------------------------------------------ verify

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  int _cooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown(60);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) timer.cancel();
      if (mounted) setState(() => _cooldown--);
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = l10n.verifyCodeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyEmail(widget.email, code);
      if (!mounted) return;
      showMessage(context, l10n.verifyDone);
      context.go(Uri(path: '/login', queryParameters: {'email': widget.email}).toString());
    } catch (e) {
      if (mounted) setState(() => _error = l10n.error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final l10n = context.l10n;
    try {
      await ref.read(authRepositoryProvider).resendVerification(widget.email);
      if (!mounted) return;
      showMessage(context, l10n.verifyResent);
      _startCooldown(60);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.retryAfter != null) _startCooldown(e.retryAfter!.inSeconds);
      showMessage(context, l10n.error(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return _AuthLayout(
      icon: Icons.mark_email_unread_outlined,
      title: l10n.verifyTitle,
      subtitle: l10n.verifyBody(widget.email),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ErrorBanner(_error),
          TextField(
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 12),
            decoration: InputDecoration(hintText: '••••••', labelText: l10n.verifyCode),
            onChanged: (value) {
              if (value.length == 6) _submit();
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          _SubmitButton(label: l10n.verifySubmit, busy: _busy, onPressed: _submit),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _cooldown > 0 ? null : _resend,
            child: Text(_cooldown > 0 ? l10n.verifyResendIn(_cooldown) : l10n.verifyResend),
          ),
        ],
      ),
    );
  }
}
