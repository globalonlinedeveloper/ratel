import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Delete account — mock Page-1 · screen 19 (destructive, reversible-30-days).
/// Design-only (no backend yet).
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.xl,
              0,
              RatelSpacing.xl,
              RatelSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: RatelMedallion(
                      icon: Icons.warning_amber_rounded,
                      background: tk.dangerBg,
                      foreground: tk.danger,
                      size: 58,
                      iconSize: 30,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t('delete_title', 'Delete your account?'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RatelSpacing.md,
                      vertical: RatelSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: tk.dangerBg,
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: Text(
                      S.t(
                        'delete_warning',
                        'Erases your streak, XP & history. Reversible for 30 days, then permanent.',
                      ),
                      style: TextStyle(color: tk.danger, fontSize: 11, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _SelectField(label: S.t('delete_reason', 'Reason (optional)')),
                  const SizedBox(height: RatelSpacing.md),
                  RatelField(
                    controller: _password,
                    hint: S.t('delete_password', 'Re-enter password'),
                    obscure: true,
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'delete_note',
                      'Also at ratel.app/delete · revokes Sign in with Apple',
                    ),
                    style: TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.dangerFilled(
                    label: S.t('delete_cta', 'Delete account'),
                    onPressed: () {},
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

/// Presentational select row (bordered, trailing chevron) — design-only.
class _SelectField extends StatelessWidget {
  const _SelectField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tk.radiusMd),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(tk.radiusMd),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: tk.border, width: tk.hairline),
            borderRadius: BorderRadius.circular(tk.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: tk.textMuted, fontSize: 12),
                ),
              ),
              Icon(Icons.expand_more, size: 18, color: tk.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
