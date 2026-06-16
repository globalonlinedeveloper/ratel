import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Set new password — mock Page-1 · screen 15 (post-reset). Design-only
/// (no backend yet).
class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
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
                      icon: Icons.lock_outline,
                      background: tk.warningBg,
                      foreground: tk.brand,
                      size: 58,
                      iconSize: 30,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: Text(
                      S.t('setpw_title', 'Set a new password'),
                      style: TextStyle(
                        color: tk.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelField(
                    controller: _password,
                    hint: S.t('setpw_new', 'New password'),
                    obscure: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelField(
                    controller: _confirm,
                    hint: S.t('setpw_confirm', 'Confirm password'),
                    obscure: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  const _StrengthBars(),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('setpw_save', 'Save password'),
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

/// Static three-bar strength indicator (all filled) — design-only.
class _StrengthBars extends StatelessWidget {
  const _StrengthBars();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    Widget bar() => Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: tk.success,
              borderRadius: BorderRadius.circular(tk.radiusSm),
            ),
          ),
        );
    return Row(
      children: <Widget>[
        bar(),
        const SizedBox(width: 4),
        bar(),
        const SizedBox(width: 4),
        bar(),
      ],
    );
  }
}
