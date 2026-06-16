import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_field.dart';
import '../../../design_system/components/ratel_medallion.dart';

/// Phone verify — mock Page-1 · screen 11 (silent network verify first, code
/// fallback via WhatsApp/SMS). Design-only (no backend yet).
class PhoneVerifyScreen extends StatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
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
                      icon: Icons.smartphone,
                      background: tk.successBg,
                      foreground: tk.primary,
                      size: 60,
                      iconSize: 32,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('phone_title', 'Verify your number'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelField(
                    controller: _phone,
                    hint: S.t('phone_hint', '+91 · phone number'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    icon: Icons.verified_user_outlined,
                    label: S.t('phone_auto', 'Verify automatically'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t('phone_auto_note', 'Silent network check — no code to type'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 10),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  _OrDivider(label: S.t('phone_or', 'or get a code')),
                  const SizedBox(height: RatelSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RatelButton.neutral(
                          icon: Icons.chat_outlined,
                          label: S.t('phone_whatsapp', 'WhatsApp'),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(
                        child: RatelButton.neutral(
                          icon: Icons.sms_outlined,
                          label: S.t('phone_sms', 'SMS'),
                          onPressed: () {},
                        ),
                      ),
                    ],
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

/// A centred "or …" divider with hairline rules on each side.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final Widget rule = Expanded(
      child: Divider(color: tk.border, height: tk.hairline, thickness: tk.hairline),
    );
    return Row(
      children: <Widget>[
        rule,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.sm),
          child: Text(
            label,
            style: TextStyle(color: tk.textMuted, fontSize: 10),
          ),
        ),
        rule,
      ],
    );
  }
}
