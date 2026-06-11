import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_state.dart';
import '../guest.dart';

/// Conversion sheet for guests: add email+password to the anonymous user.
/// Same uid -> all progress kept, nothing to migrate.
Future<void> showSaveAccountSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const SaveAccountSheetBody(),
    ),
  );
}

/// Public for direct widget-testing (modal geometry eats test taps).
class SaveAccountSheetBody extends StatefulWidget {
  const SaveAccountSheetBody({super.key});

  @override
  State<SaveAccountSheetBody> createState() => _SaveAccountSheetState();
}

class _SaveAccountSheetState extends State<SaveAccountSheetBody> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@') || password.length < 6) {
      setState(() => _message =
          'Enter a valid email and a password of 6+ characters.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await saveGuestAccount(
          email: email, password: password, name: _name.text.trim());
      appState.email = email;
      if (_name.text.trim().isNotEmpty) {
        appState.displayName = _name.text.trim();
      }
      appState.notify();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Progress saved — welcome to the sett!')));
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) {
        setState(
            () => _message = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Save your progress',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              'Add an email so your streak, XP and badges are safe on any '
              'device.',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Name (optional)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 10),
            Text(_message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 14),
          FilledButton(
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Save my progress'),
          ),
        ],
      ),
    );
  }
}
