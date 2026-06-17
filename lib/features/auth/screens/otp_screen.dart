import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_medallion.dart';
import '../validators.dart';

/// OTP entry — mock Page-1 · screen 12 (6-digit code fallback). Design-only
/// (no backend yet); the boxes fill as you type. Stateful so it can read the
/// entered code and keep Verify disabled until all six digits are present
/// (`isOtpComplete`).
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';

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
                      icon: Icons.sms_outlined,
                      background: tk.infoBg,
                      foreground: tk.info,
                      size: 60,
                      iconSize: 32,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('otp_title', 'Enter the 6-digit code'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(
                    S.t('otp_sent', 'sent to +91 ***** 12345'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  Center(
                    child: _OtpBoxes(
                      onChanged: (String v) => setState(() => _code = v),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Text(
                    S.t('otp_resend', 'Resend in 0:24'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tk.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                  RatelButton.filled(
                    label: S.t('otp_verify', 'Verify'),
                    onPressed: isOtpComplete(_code) ? () {} : null,
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

const int _kOtpLength = 6;

/// Six segmented code boxes backed by one hidden field; the active box is
/// outlined in the primary colour and digits appear as you type. Reports the
/// current code up via [onChanged] so the screen can gate Verify.
class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final String text = _code.text;
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(_kOtpLength, (int i) {
              final bool filled = i < text.length;
              final bool active = i == text.length;
              return Container(
                width: 34,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: active ? tk.primary : tk.border,
                    width: active ? 1.5 : tk.hairline,
                  ),
                  borderRadius: BorderRadius.circular(tk.radiusSm),
                ),
                child: Text(
                  filled ? text[i] : '',
                  style: TextStyle(
                    color: tk.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                key: const ValueKey<String>('otp_input'),
                controller: _code,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: _kOtpLength,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (String v) {
                  setState(() {});
                  widget.onChanged(v);
                },
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
