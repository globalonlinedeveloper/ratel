import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';

/// Dictation — mock Page-4 · screen 11 (type what you hear, listening + spelling).
/// Design-only (no backend/audio yet).
class DictationScreen extends StatefulWidget {
  const DictationScreen({super.key});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  final TextEditingController _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(RatelSpacing.md, 0, RatelSpacing.md, RatelSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(S.t('dict_title', 'Type what you hear'), style: TextStyle(color: tk.text, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RatelSpacing.md),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 70,
                          height: 70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: tk.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.volume_up, size: 36, color: Colors.white),
                        ),
                        const SizedBox(height: RatelSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _Mini(icon: Icons.slow_motion_video, label: S.t('dict_slower', 'Slower')),
                            const SizedBox(width: RatelSpacing.lg),
                            _Mini(icon: Icons.repeat, label: S.t('dict_replay', 'Replay')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: tk.border, width: tk.hairline), borderRadius: BorderRadius.circular(tk.radiusMd)),
                    child: TextField(
                      controller: _answer,
                      maxLines: 2,
                      style: TextStyle(color: tk.text, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: S.t('dict_input', 'Type here…'),
                        hintStyle: TextStyle(color: tk.textMuted, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(RatelSpacing.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.xs),
                  Text(S.t('dict_note', 'builds listening + spelling together'), style: TextStyle(color: tk.textMuted, fontSize: 9.5)),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(label: S.t('dict_cta', 'Check'), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: tk.primary),
        const SizedBox(width: RatelSpacing.xs),
        Text(label, style: TextStyle(color: tk.primary, fontSize: 11)),
      ],
    );
  }
}
