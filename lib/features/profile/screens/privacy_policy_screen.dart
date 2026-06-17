import 'package:flutter/material.dart';
import '../../../core/i18n/strings.dart';
import '../widgets/legal_doc_view.dart';

/// Privacy Policy (`/privacy-policy` — `/privacy` & `/privacy-data` are taken).
/// Design-phase SCAFFOLD with a visible draft banner; real policy copy is a
/// later owner task (swap the `S.t` defaults; keys are immortal).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocView(
      title: S.t('privacy_policy_title', 'Privacy Policy'),
      sections: <List<String>>[
        <String>[
          S.t('pp_s1_h', '1. Data we collect'),
          S.t('pp_s1_b',
              'Placeholder: account details and learning progress you choose to provide. Final policy pending legal review.'),
        ],
        <String>[
          S.t('pp_s2_h', '2. How we use it'),
          S.t('pp_s2_b',
              'Placeholder: to run lessons, track streaks, and improve the app. We never sell your data. Final policy pending review.'),
        ],
        <String>[
          S.t('pp_s3_h', '3. Your rights'),
          S.t('pp_s3_b',
              'Placeholder: request a copy of, or deletion of, your data from Settings → Account. Final policy pending review.'),
        ],
        <String>[
          S.t('pp_s4_h', '4. Contact'),
          S.t('pp_s4_b',
              'Placeholder: reach us at support@ratel.app. Final policy pending legal review.'),
        ],
      ],
    );
  }
}
