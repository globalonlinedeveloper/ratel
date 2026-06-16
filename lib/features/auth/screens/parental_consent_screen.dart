import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Parental consent — mock Page-1 · screen 10 (under-18 gate, region-adaptive
/// verification). Design-only (no backend yet).
class ParentalConsentScreen extends StatefulWidget {
  const ParentalConsentScreen({super.key});

  @override
  State<ParentalConsentScreen> createState() => _ParentalConsentScreenState();
}

class _ParentalConsentScreenState extends State<ParentalConsentScreen> {
  final TextEditingController _parentEmail = TextEditingController();

  @override
  void dispose() {
    _parentEmail.dispose();
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
                      icon: Icons.group_outlined,
                      background: tk.infoBg,
                      foreground: tk.info,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('parent_title', 'Ask a parent to continue'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t(
                      'parent_sub',
                      "Because you're under 18, a parent needs to approve your account.",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelField(
                    controller: _parentEmail,
                    hint: S.t('parent_email', "Parent's email"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.neutral(
                    icon: Icons.badge_outlined,
                    label: S.t('parent_digilocker', 'Verify via DigiLocker'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('parent_send', 'Send request'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t(
                      'parent_note',
                      'Region-adaptive: DigiLocker (IN) · card/ID (US) · vendor (RoW) — adults-only at launch',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 10, height: 1.4),
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
