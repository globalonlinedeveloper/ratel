import 'dart:math';
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'strings.dart';

enum QuestMetric { xp, lessons }

class Quest {
  const Quest(this.metric, this.target, this.title, this.icon);
  final QuestMetric metric;
  final int target;
  final String title;
  final IconData icon;
}

/// Two quests for today — stable within the day (seeded by the date), fresh the
/// next. Progress reads from today's live counters in [AppState].
List<Quest> questsForToday() {
  final now = DateTime.now();
  final r = Random(now.year * 1000 + now.month * 50 + now.day);
  final xp = const [20, 30, 40, 50][r.nextInt(4)];
  final lessons = const [1, 2, 3][r.nextInt(3)];
  return [
    Quest(QuestMetric.xp, xp,
        S.instance.t('q_earn', 'Earn {n} XP').replaceAll('{n}', '$xp'),
        Icons.bolt),
    Quest(
        QuestMetric.lessons,
        lessons,
        (lessons == 1
                ? S.instance.t('q_finish_one', 'Finish {n} lesson')
                : S.instance.t('q_finish_many', 'Finish {n} lessons'))
            .replaceAll('{n}', '$lessons'),
        Icons.menu_book),
  ];
}

int questProgress(Quest q, AppState s) =>
    q.metric == QuestMetric.xp ? s.todayXp : s.lessonsToday;

bool questDone(Quest q, AppState s) => questProgress(q, s) >= q.target;
