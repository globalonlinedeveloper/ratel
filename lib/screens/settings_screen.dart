import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../locales.dart';
import '../milestones.dart';
import '../push.dart';
import '../sfx.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/mascot_anim.dart';
import '../widgets/ratel_chip.dart';
import '../widgets/ratel_list_row.dart';
import '../widgets/ratel_mascot.dart';
import '../widgets/ratel_scaffold.dart';
import '../widgets/ratel_toggle_row.dart';

/// Dedicated Settings page (Standardization Master Plan, Phase 1 -- Pillar D,
/// Inc 175). The preference controls (audio / learning / appearance /
/// reminders) were lifted verbatim out of the Profile tab body into this
/// pushed route, reached by a gear entry in Profile -- decluttering the tab.
/// A pushed route with a title+back header => the [RatelScaffold] fit (unlike
/// the in-body-header screens that keep a raw Scaffold). StatefulWidget for the
/// `_listenOn` pref + the setState-driven toggles (moved with their widgets).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _listenOn = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() => _listenOn = p.getBool('listen_on') ?? true);
    });
  }

  /// Native name for [code] from the enabled registry (else the code itself).
  String _localeName(String code) {
    for (final e in Locales.instance.enabled) {
      if (e.code == code) return e.nativeName;
    }
    return code;
  }

  /// Native name + English name for the current-language tile (mirrors the
  /// picker rows). The English part is dropped when absent or identical (the
  /// English/en-* variants whose native name already reads in English).
  String _localeLabel(String code) {
    final native = _localeName(code);
    final en = Locales.englishNameFor(code);
    return (en.isEmpty || en == native) ? native : '$native \u00b7 $en';
  }

  /// Scalable App-language picker over the enabled registry (`locales.enabled`):
  /// a tap-to-open dialog list of native names. Works for the two locales today
  /// AND the ~50-locale LTR set as they enable (a SegmentedButton would
  /// overflow). The pick drives [S.setLocale]; the resolver honours it via the
  /// fallback chain, so an accent variant shows its deltas and inherits the rest.
  Future<void> _pickLanguage() async {
    final current = S.instance.locale;
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(S.instance.t('set_language', 'App language')),
        children: [
          for (final e in Locales.instance.enabled)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.code),
              child: Row(
                children: [
                  Icon(
                    e.code == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: RatelColors.teal,
                    size: 20,
                  ),
                  const SizedBox(width: RatelSpacing.md),
                  Text(
                    Locales.flagFor(e.code),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: RatelSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.nativeName),
                        if (Locales.englishNameFor(e.code).isNotEmpty &&
                            Locales.englishNameFor(e.code) != e.nativeName)
                          Text(
                            Locales.englishNameFor(e.code),
                            style: const TextStyle(
                              fontSize: 12,
                              color: RatelColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen != null) {
      await S.instance.setLocale(chosen);
      // Inc 194 FIX (locale propagation): re-inflate the home's locale-keyed
      // subtree so EVERY tab re-localizes immediately. SettingsScreen is a
      // pushed route, so its own setState() only re-localizes THIS page; the
      // tabs underneath rebuild on `appState` (home_screen's ListenableBuilder
      // -> KeyedSubtree(ValueKey('locale-..'))) which nothing was notifying, so
      // they stayed in the OLD language until a full reload. Affects all langs.
      appState.notify();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RatelScaffold(
      title: S.instance.t('set_title', 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.lg,
          vertical: RatelSpacing.md,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.lg),
            child: Column(
              children: [
                RatelToggleRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm,
                  ),
                  leading: const Icon(
                    Icons.volume_up,
                    color: RatelColors.honey,
                  ),
                  title: S.instance.t('set_sound', 'Sound effects'),
                  value: Sfx.instance.soundOn,
                  onChanged: (v) {
                    Sfx.instance.setSoundOn(v);
                    setState(() {});
                  },
                ),
                RatelToggleRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm,
                  ),
                  leading: const Icon(Icons.vibration, color: RatelColors.teal),
                  title: S.instance.t('set_haptics', 'Haptics'),
                  value: Sfx.instance.hapticsOn,
                  onChanged: (v) {
                    Sfx.instance.setHapticsOn(v);
                    setState(() {});
                  },
                ),
                RatelToggleRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm,
                  ),
                  leading: Sfx.instance.musicOn
                      ? const RatelActionAnim(
                          action: 'headphones',
                          fallbackPose: RatelPose.speak,
                          size: 34,
                        )
                      : const Icon(Icons.music_note, color: RatelColors.honey),
                  title: S.instance.t('set_music', 'Background music'),
                  subtitle: S.instance.t(
                    'set_music_sub',
                    'Calm ambient loop while you learn',
                  ),
                  value: Sfx.instance.musicOn,
                  onChanged: (v) {
                    Sfx.instance.setMusicOn(v);
                    setState(() {});
                  },
                ),
                RatelListRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.md,
                  ),
                  leading: const Icon(Icons.translate, color: RatelColors.teal),
                  title: S.instance.t('set_language', 'App language'),
                  subtitle: _localeLabel(S.instance.locale),
                  onTap: _pickLanguage,
                ),
                RatelToggleRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm,
                  ),
                  leading: const Icon(Icons.hearing_outlined),
                  title: S.instance.t('set_listening', 'Listening exercises'),
                  subtitle: S.instance.t(
                    'set_listen_sub',
                    'Type-what-you-hear questions',
                  ),
                  value: _listenOn,
                  onChanged: (v) async {
                    setState(() => _listenOn = v);
                    try {
                      final p = await SharedPreferences.getInstance();
                      await p.setBool('listen_on', v);
                    } catch (_) {}
                  },
                ),
                RatelToggleRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm,
                  ),
                  leading: const Icon(Icons.motion_photos_off_outlined),
                  title: S.instance.t('set_motion', 'Reduce motion'),
                  subtitle: S.instance.t(
                    'set_motion_sub',
                    'Minimize animations',
                  ),
                  value: reduceMotionNotifier.value,
                  onChanged: (v) {
                    setReduceMotion(v);
                    setState(() {});
                  },
                ),
                RatelToggleRow(
                  padding: const EdgeInsets.symmetric(
                    vertical: RatelSpacing.sm,
                  ),
                  leading: const Icon(Icons.sports_kabaddi_outlined),
                  title: S.instance.t('set_battle', 'Battle mode'),
                  subtitle: S.instance.t(
                    'set_battle_sub',
                    'Duel a rival as you answer',
                  ),
                  value: battleModeNotifier.value,
                  onChanged: (v) {
                    setBattleMode(v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: RatelSpacing.md),
                Wrap(
                  spacing: RatelSpacing.sm,
                  children: [
                    RatelChip(
                      label: S.instance.t('set_auto', 'Auto'),
                      icon: Icons.brightness_auto_outlined,
                      selected: themeModeNotifier.value == ThemeMode.system,
                      onTap: () {
                        setThemeMode(ThemeMode.system);
                        setState(() {});
                      },
                    ),
                    RatelChip(
                      label: S.instance.t('set_light', 'Light'),
                      icon: Icons.light_mode_outlined,
                      selected: themeModeNotifier.value == ThemeMode.light,
                      onTap: () {
                        setThemeMode(ThemeMode.light);
                        setState(() {});
                      },
                    ),
                    RatelChip(
                      label: S.instance.t('set_dark', 'Dark'),
                      icon: Icons.dark_mode_outlined,
                      selected: themeModeNotifier.value == ThemeMode.dark,
                      onTap: () {
                        setThemeMode(ThemeMode.dark);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: RatelSpacing.xs),
          ListTile(
            dense: true,
            leading: const Icon(Icons.schedule, color: RatelColors.teal),
            title: Text(S.instance.t('set_remind', 'Remind me at')),
            subtitle: Text(
              S.instance.t(
                'set_remind_sub',
                'Daily streak reminder, your local time',
              ),
            ),
            trailing: DropdownButton<int>(
              value: localHourFromUtc(
                appState.reminderHourUtc,
                DateTime.now().timeZoneOffset,
              ),
              underline: const SizedBox.shrink(),
              items: [
                for (int h = 0; h < 24; h++)
                  DropdownMenuItem(
                    value: h,
                    child: Text('${h.toString().padLeft(2, '0')}:30'),
                  ),
              ],
              onChanged: (h) {
                if (h == null) return;
                appState.setReminderHour(
                  utcHourFromLocal(h, DateTime.now().timeZoneOffset),
                );
                setState(() {});
              },
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: RatelSpacing.xs),
            FutureBuilder<String>(
              future: Push.instance.statusLabel(),
              builder: (context, snap) {
                final st = snap.data ?? '…';
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: RatelColors.honey,
                  ),
                  title: Text(
                    S.instance.t('set_push', 'Daily streak reminders'),
                  ),
                  subtitle: Text(
                    st == 'Off'
                        ? S.instance.t(
                            'push_off_hint',
                            'Off — enable in system settings if asked before',
                          )
                        : st,
                  ),
                  trailing: st == 'On'
                      ? const Icon(
                          Icons.check_circle,
                          color: RatelColors.teal,
                          size: 20,
                        )
                      : TextButton(
                          onPressed: () async {
                            await Push.instance.requestAgain();
                            if (context.mounted) {
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: Text(S.instance.t('btn_enable', 'Enable')),
                        ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
