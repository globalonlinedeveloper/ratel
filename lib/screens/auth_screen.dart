import '../flags.dart';
import '../guest.dart';
import '../strings.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/ratel_mascot.dart';
import '../analytics.dart';

/// Email/password login + sign-up using Supabase Auth.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _message = 'Enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (_isSignUp) {
        final res = await auth.signUp(
          email: email,
          password: password,
          data: _name.text.trim().isEmpty ? null : {'full_name': _name.text.trim()},
        );
        Analytics.signUp();
        if (res.session == null && mounted) {
          setState(() =>
              _message = 'Account created. Check your email to confirm, then log in.');
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
        Analytics.login();
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) setState(() => _message = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _tryAsGuest() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await startGuestSession();
      Analytics.log('guest_start');
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _message =
            'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RatelMascot(pose: RatelPose.wave, size: 120),
                  const SizedBox(height: 8),
                  const Text('Ratel',
                      style: TextStyle(
                          fontSize: 30, fontFamily: kDisplayFont,
                          fontWeight: FontWeight.w800,
                          color: RatelColors.honey)),
                  Text(S.instance.t('auth_tagline', 'Learn English, fearlessly.'),
                      style: TextStyle(color: RatelColors.textMuted)),
                  const SizedBox(height: 24),
                  if (_isSignUp) ...[
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          labelText: S.instance.t('fld_name', 'Name'),
                          border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: S.instance.t('fld_email', 'Email'),
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: S.instance.t('fld_password', 'Password'),
                        border: const OutlineInputBorder()),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!,
                        style: const TextStyle(color: RatelColors.coral)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: RatelColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isSignUp
                              ? S.instance.t('btn_create', 'Create account')
                              : S.instance.t('btn_login', 'Log in')),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _isSignUp = !_isSignUp;
                              _message = null;
                            }),
                    child: Text(_isSignUp
                        ? S.instance
                            .t('auth_have', 'Have an account? Log in')
                        : S.instance.t(
                            'auth_new', 'New here? Create an account')),
                  ),
                  if (Flags.instance.flag('guest_mode', false)) ...[
                    const SizedBox(height: 2),
                    TextButton.icon(
                      onPressed: _loading ? null : _tryAsGuest,
                      icon: const Icon(Icons.bolt, size: 18),
                      label: Text(S.instance.t('guest_cta', 'Just let me try it')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
