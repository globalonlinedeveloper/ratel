import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../content.dart';
import '../../models.dart';
import '../../strings.dart';
import '../../theme.dart';
import '../../widgets/hearts_sheet.dart';
import '../../widgets/mistakes_review.dart';
import '../../widgets/smart_practice.dart';
import '../../widgets/transitions.dart';
import '../lesson_screen.dart';
import '../timed_challenge_screen.dart';

/// Practice tab body (home tab-shell, index 1).
///
/// Extracted from the `home_screen` god-screen in the Standardization Master
/// Plan, Phase 1 (Inc 169). A tab body is NOT a pushed route, so it carries
/// no [RatelScaffold]/back header — it renders directly inside the tab shell.
/// Migration scope (lossless): spacing literals -> [RatelSpacing] (exact
/// match), decorative icons wrapped in [ExcludeSemantics]; colours were
/// already tokenised. No state-trio: `course` has a built-in offline
/// fallback and the cards own their own data states.
class PracticeTab extends StatelessWidget {
  const PracticeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RatelSpacing.lg),
      children: [
        Text(S.instance.t('nav_practice', 'Practice'),
            style: const TextStyle(
                fontSize: 20,
                fontFamily: kDisplayFont,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: RatelSpacing.md),
        const SmartPracticeCard(),
        Container(
          margin: const EdgeInsets.only(bottom: RatelSpacing.md),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.tintC(RatelColors.coral),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.faintBorderC),
          ),
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.timer_outlined, color: RatelColors.coral),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.instance.t('tc_card_title', 'Timed challenge'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                        S.instance.t('tc_card_sub',
                            'Beat the clock — no hearts at risk'),
                        style: const TextStyle(
                            color: RatelColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: RatelColors.coral,
                    visualDensity: VisualDensity.compact),
                onPressed: () => Navigator.of(context)
                    .push(ratelRoute(const TimedChallengeScreen())),
                child: Text(S.instance.t('btn_go', 'Go')),
              ),
            ],
          ),
        ),
        const MistakesReview(),
        Text(S.instance.t('rv_title', 'Revisit lessons'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: RatelSpacing.xs),
        Text(S.instance.t('rv_sub', 'Replay any lesson to sharpen up.'),
            style: const TextStyle(color: RatelColors.textMuted)),
        const SizedBox(height: RatelSpacing.md),
        ...List.generate(course.length, (u) {
          final unit = course[u];
          final int doneCount =
              unit.lessons.where((l) => appState.isCompleted(l.id)).length;
          final bool hasCurrent =
              unit.lessons.any((l) => !appState.isCompleted(l.id)) &&
                  (u == 0 ||
                      course[u - 1]
                          .lessons
                          .every((l) => appState.isCompleted(l.id)));
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.surfaceC,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderC),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              type: MaterialType.transparency,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: hasCurrent,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: unitAccent(u),
                    child: Text('${u + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                  title: Text(unit.subtitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text(
                      S.instance
                          .t('n_lessons', '{a}/{b} lessons')
                          .replaceAll('{a}', '$doneCount')
                          .replaceAll('{b}', '${unit.lessons.length}'),
                      style: const TextStyle(
                          color: RatelColors.textMuted, fontSize: 12)),
                  children: [
                    for (final l in unit.lessons) _practiceRow(context, l),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _practiceRow(BuildContext context, Lesson l) {
    final bool done = appState.isCompleted(l.id);
    return InkWell(
      onTap: () {
        if (appState.hearts <= 0 && !appState.isPro) {
          showHeartsSheet(context);
          return;
        }
        Navigator.of(context).push(ratelRoute(LessonScreen(lesson: l)));
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: RatelSpacing.lg, vertical: RatelSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: done ? RatelColors.teal : RatelColors.honey,
              child: Icon(done ? Icons.check : Icons.play_arrow,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: RatelSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(
                      S.instance
                          .t('n_exercises', '{n} exercises')
                          .replaceAll('{n}', '${l.exercises.length}'),
                      style: const TextStyle(
                          color: RatelColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const ExcludeSemantics(
              child: Icon(Icons.chevron_right, color: RatelColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
