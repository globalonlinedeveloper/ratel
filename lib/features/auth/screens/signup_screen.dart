import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_link.dart';
import '../../../design_system/components/ratel_password_strength.dart';
import '../validators.dart';

/// Sign-up — mock Page-1 · screen 6 (create account). Design-only (no backend
/// until phase 3). The CTA stays disabled until name + email + password are all
/// valid AND the agree checkbox is ticked; a field's inline error reveals once
/// that field is non-empty (we don't shout on untouched fields). The strength
/// meter is live (driven by `passwordStrength`).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid =>
      validateName(_name.text) == null &&
      validateEmail(_email.text) == null &&
      validatePassword(_password.text) == null;

  String? _errorFor(String text, String? Function(String) v) =>
      text.isEmpty ? null : v(text);

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RatelSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    S.t('signup_title', 'Create your account'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelField(
                    controller: _name,
                    hint: S.t('signup_name', 'Name'),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    errorText: _errorFor(_name.text, validateName),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelField(
                    controller: _email,
                    hint: S.t('signup_email', 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    errorText: _errorFor(_email.text, validateEmail),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelField(
                    controller: _password,
                    hint: S.t('signup_password', 'Password'),
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    errorText: _errorFor(_password.text, validatePassword),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelPasswordStrength(
                    strength: passwordStrength(_password.text),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'signup_password_hint',
                      'Length beats symbols — a passphrase is great (NIST 2026).',
                    ),
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _AgreeRow(
                    value: _agree,
                    onChanged: () => setState(() => _agree = !_agree),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('signup_cta', 'Create account'),
                    onPressed: (_agree && _valid)
                        ? () => context.go('/onboarding/language')
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Terms agreement row: tappable checkbox + linked Terms & Privacy.
class _AgreeRow extends StatelessWidget {
  const _AgreeRow({required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: onChanged,
          borderRadius: BorderRadius.circular(tk.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: value ? tk.primary : tk.textMuted,
            ),
          ),
        ),
        const SizedBox(width: RatelSpacing.sm),
        Flexible(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                S.t('signup_agree', 'I agree to the '),
                style: TextStyle(color: tk.textMuted, fontSize: 12),
              ),
              RatelLink(
                label: S.t('signup_terms', 'Terms & Privacy'),
                onTap: () {},
                fontSize: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
