import 'package:flutter/material.dart';
import '../theme.dart';
import 'ratel_field.dart';
import 'ratel_button.dart';

/// Neutral age gate (adults-only at launch). Collects year of birth and
/// reports it on confirm; the caller decides eligibility. No judgement copy.
class AgeGate extends StatefulWidget {
  const AgeGate({
    super.key,
    required this.onConfirm,
    this.title = 'Your year of birth',
    this.cta = 'Continue',
  });

  final ValueChanged<int> onConfirm;
  final String title;
  final String cta;

  @override
  State<AgeGate> createState() => _AgeGateState();
}

class _AgeGateState extends State<AgeGate> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final y = int.tryParse(_c.text.trim());
    final now = DateTime.now().year;
    if (y == null || y < 1900 || y > now) {
      setState(() => _error = 'Enter a valid year');
      return;
    }
    setState(() => _error = null);
    widget.onConfirm(y);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RatelField(
          controller: _c,
          label: widget.title,
          hint: 'YYYY',
          error: _error,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: RatelSpacing.md),
        RatelButton.filled(label: widget.cta, onPressed: _submit),
      ],
    );
  }
}
