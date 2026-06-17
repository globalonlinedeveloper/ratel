import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_link.dart';
import '../validators.dart';

/// Email login — mock Page-1 · screen 5. Design-only (no backend until phase 3).
/// Validation: the CTA stays disabled until email + password are valid; a
/// field's inline error reveals once that field is non-empty (we don't shout
/// errors on untouched fields). On valid submit it navigates exactly as before.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid =>
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
                    S.t('login_title', 'Welcome back'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelField(
                    controller: _email,
                    hint: S.t('login_email', 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    errorText: _errorFor(_email.text, validateEmail),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelField(
                    controller: _password,
                    hint: S.t('login_password', 'Password'),
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    errorText: _errorFor(_password.text, validatePassword),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RatelLink(
                      label: S.t('login_forgot', 'Forgot?'),
                      onTap: () => context.push('/forgot'),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('login_cta', 'Log in'),
                    onPressed: _valid ? () => context.go('/app') : null,
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          S.t('login_new', 'New here? '),
                          style: TextStyle(color: tk.textMuted, fontSize: 13),
                        ),
                        RatelLink(
                          label: S.t('login_create', 'Create an account'),
                          onTap: () => context.push('/signup'),
                        ),
                      ],
                    ),
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
