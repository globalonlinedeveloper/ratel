import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../widgets/legal_doc_view.dart';

/// Terms of Service (`/terms`) — design-phase SCAFFOLD with a visible draft
/// banner. Real counsel-approved copy is a later owner task; swap the `S.t`
/// defaults below when it arrives (keys are immortal).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocView(
      title: S.t('terms_title', 'Terms of Service'),
      sections: <List<String>>[
        <String>[
          S.t('terms_s1_h', '1. Using Ratel'),
          S.t('terms_s1_b',
              'This is placeholder text. The final Terms of Service will replace it before store submission. Use Ratel to learn responsibly and respect other learners.'),
        ],
        <String>[
          S.t('terms_s2_h', '2. Your account'),
          S.t('terms_s2_b',
              'Keep your login details secure; you are responsible for activity on your account. Placeholder copy pending legal review.'),
        ],
        <String>[
          S.t('terms_s3_h', '3. Subscriptions & payments'),
          S.t('terms_s3_b',
              'Subscriptions renew until cancelled; cancel anytime in Settings → Account or your app store. Placeholder copy pending legal review.'),
        ],
      ],
    );
  }
}
