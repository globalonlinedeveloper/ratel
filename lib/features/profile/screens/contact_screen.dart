import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../design_system/components/ratel_button.dart';
import '../../../design_system/components/ratel_select_field.dart';

/// Contact & report-a-bug (`/contact`) — mock Page-6. Design-phase: the topic
/// picker and Send are stubs; the message field is real local state but isn't
/// submitted anywhere until phase 3.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
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
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              RatelSpacing.md,
              0,
              RatelSpacing.md,
              RatelSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    S.t('contact_title', 'Contact us'),
                    style: TextStyle(
                      color: tk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelSelectField(
                    leadingIcon: Icons.label_outline,
                    label: S.t('contact_topic', 'Topic · Report a bug'),
                    onTap: () {},
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: tk.border, width: tk.hairline),
                      borderRadius: BorderRadius.circular(tk.radiusMd),
                    ),
                    child: TextField(
                      controller: _message,
                      maxLines: 4,
                      style: TextStyle(color: tk.text, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: S.t('contact_hint', 'Describe the issue…'),
                        hintStyle: TextStyle(color: tk.textMuted, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(RatelSpacing.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Text(
                    S.t(
                      'contact_note',
                      'We usually reply within 2 working days.',
                    ),
                    style: TextStyle(
                      color: tk.textMuted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: RatelSpacing.md),
                  RatelButton.filled(
                    label: S.t('contact_send', 'Send'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  Center(
                    child: Text(
                      S.t('contact_email', 'Or email support@ratel.app'),
                      style: TextStyle(color: tk.textMuted, fontSize: 10),
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
