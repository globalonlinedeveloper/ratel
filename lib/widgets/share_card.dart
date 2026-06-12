import 'package:flutter/material.dart';
import '../strings.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../theme.dart';
import '../content.dart';
import '../milestones.dart';
import '../widgets/streak_flame.dart';

/// A shareable streak card: a screenshot-worthy visual + one-tap copy of the
/// invite text (image export ships with the store build).
String shareScoreLine() {
  final int totalLessons = [
    for (final u in course) u.lessons.length
  ].fold(0, (a, b) => a + b);
  final int score = currentEnglishScore(
      appState.completedCount, totalLessons, appState.streak);
  return '$score/100 (${cefrFor(score)})';
}
Future<void> showShareCard(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2A2A), Color(0xFF4A3B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/ratel-herojump.webp',
                    width: 110,
                    height: 110,
                    errorBuilder: (_, _, _) =>
                        const SizedBox(width: 110, height: 110)),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreakFlame(streak: appState.streak, size: 30),
                    const SizedBox(width: 8),
                    Text('${appState.streak}${S.instance.t('sh_days', '-day streak')}',
                        style: const TextStyle(
                            color: RatelColors.cream,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
              '${appState.xp} '
              '${S.instance.t('sh_line', 'XP · learning English fearlessly')}',
                    style: TextStyle(
                        color: RatelColors.cream.withValues(alpha: 0.8),
                        fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                    S.instance
                        .t('sh_code', 'ratel · friend code {code}')
                        .replaceAll('{code}', appState.friendCode),
                    style: TextStyle(
                        color: RatelColors.cream.withValues(alpha: 0.6),
                        fontSize: 11,
                        letterSpacing: 1.1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text:
                      "My Ratel English Score: "
                      '${shareScoreLine()}. '
                      "I'm on a ${appState.streak}-day English streak with "
                      'Ratel the honey badger! Join me: '
                      'https://globalonlinedeveloper.github.io/ratel/'
                      '?friend=${appState.friendCode} — or add my friend code '
                      '${appState.friendCode} at '
                      'https://globalonlinedeveloper.github.io/ratel/'));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(S.instance
            .t('sh_copied', 'Invite copied — paste it anywhere!'))));
            },
            icon: const Icon(Icons.copy, size: 18),
            label: Text(S.instance.t('sh_copy', 'Copy invite text')),
          ),
        ],
      ),
    ),
  );
}
