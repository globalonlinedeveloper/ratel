import 'package:flutter/material.dart';
import '../widgets/mascot_anim.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../strings.dart';
import '../config.dart';
import '../widgets/ratel_mascot.dart';

/// One chat message in the coach conversation.
class ChatMsg {
  final String role; // 'user' or 'assistant'
  final String text;
  const ChatMsg(this.role, this.text);
}

/// Sends the conversation and returns the tutor's reply.
/// Injectable so widget tests run without network/Supabase.
typedef CoachSender = Future<String> Function(List<ChatMsg> history);

const String kCoachGreeting =
    "Hi, I'm Ratel! Let's practice English together - just chat with me. "
    'I will gently fix your mistakes as we go. Tell me about your day, '
    'or pick a topic below.';

/// AI conversation practice with the mascot persona. Backed by the
/// `tutor-chat` Edge Function (server-side key, daily rate limit).
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key, this.sender});
  final CoachSender? sender;

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final List<ChatMsg> _msgs = [const ChatMsg('assistant', kCoachGreeting)];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _waiting = false;
  int? _used, _cap;

  static const List<String> _starters = [
    'My day so far',
    'Food I like',
    'My family',
    'My favorite place',
  ];
  static const List<String> _starterKeys = [
    'chip_day', 'chip_food', 'chip_family', 'chip_place',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<String> _invokeSender(List<ChatMsg> history) async {
    if (!Config.hasSupabase) {
      return 'The coach needs an internet connection and a signed-in '
          'account. Please try again once you are online.';
    }
    final res = await Supabase.instance.client.functions.invoke(
      'tutor-chat',
      body: {
        'locale': S.instance.locale,
        'messages': [
          for (final m in history) {'role': m.role, 'content': m.text},
        ],
      },
    );
    final data = res.data;
    if (data is Map && data['reply'] is String) {
      final used = data['used'], cap = data['cap'];
      if (used is int && cap is int) {
        _used = used;
        _cap = cap;
      }
      return data['reply'] as String;
    }
    throw Exception('bad response');
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _waiting) return;
    _input.clear();
    setState(() {
      _msgs.add(
          ChatMsg('user', text.length > 600 ? text.substring(0, 600) : text));
      _waiting = true;
    });
    _toBottom();
    String reply;
    try {
      final sender = widget.sender ?? _invokeSender;
      reply = await sender(List.unmodifiable(_msgs));
    } catch (e) {
      reply = _errorText(e);
    }
    if (!mounted) return;
    setState(() {
      _msgs.add(ChatMsg('assistant', reply));
      _waiting = false;
    });
    _toBottom();
  }

  String _errorText(Object e) {
    int? status;
    try {
      status = (e as dynamic).status as int?;
    } catch (_) {}
    if (status == 429) {
      return "You've used all of today's coach messages - great work! "
          'Come back tomorrow, or go Pro for a much higher daily limit.';
    }
    return "Hmm, I couldn't reply just now. "
        'Check your connection and try again.';
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final int? left = (_used != null && _cap != null)
        ? (_cap! - _used!).clamp(0, _cap!)
        : null;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: context.surfaceC,
          child: Row(
            children: [
              _waiting
                  ? const RatelActionAnim(
                      action: 'listening',
                      fallbackPose: RatelPose.think,
                      size: 52)
                  : const RatelMascot(pose: RatelPose.idle, size: 52),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.instance.t('coach_title', 'Coach'),
                        style: TextStyle(
                            fontSize: 18, fontFamily: kDisplayFont, fontWeight: FontWeight.w700)),
                    Text(
                      left == null
                          ? S.instance.t('coach_sub',
                              'Real conversation practice with Ratel')
                          : S.instance
                              .t('coach_left', '{n} messages left today')
                              .replaceAll('{n}', '$left'),
                      style: const TextStyle(
                          color: RatelColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            itemCount: _msgs.length,
            itemBuilder: (context, i) =>
                _bubble(_msgs[i], i == _msgs.length - 1),
          ),
        ),
        if (_waiting)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 6),
            child: Row(
              children: [
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 8),
                Text(S.instance.t('coach_typing', 'Ratel is typing...'),
                    style: const TextStyle(
                        color: RatelColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        if (_msgs.length <= 1 && !_waiting) ...[
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final sc in kCoachScenarios)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _send(sc.prompt),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 132,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.tintC(RatelColors.teal),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: context.faintBorderC),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(sc.icon,
                                    size: 20, color: RatelColors.teal),
                                const SizedBox(height: 8),
                                Text(S.instance.t('coach_roleplay', 'Roleplay'),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: context.mutedC)),
                                Text(S.instance.t(sc.sKey, sc.title),
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < _starters.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      // chip label localizes; the sent message stays English
                      // (the Coach conversation IS the English practice).
                      label: Text(S.instance
                          .t(_starterKeys[i], _starters[i])),
                      onPressed: () =>
                          _send("Let's talk about: ${_starters[i]}"),
                    ),
                  ),
              ],
            ),
          ),
        ],
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText:
                          S.instance.t('coach_hint', 'Type in English...'),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _waiting ? null : () => _send(_input.text),
                  icon: const Icon(Icons.send),
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(ChatMsg m, bool last) {
    final bool user = m.role == 'user';
    final Widget bubble = Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: user ? RatelColors.honey : context.surfaceC,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(user ? 14 : 4),
            bottomRight: Radius.circular(user ? 4 : 14),
          ),
          border: user ? null : Border.all(color: context.borderC),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: user ? Colors.white : null,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ),
    );
    final bool coachTip =
        !user && last && !_waiting && m.text.contains('Better:');
    if (!coachTip) return bubble;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: RatelActionAnim(
              action: 'teacher', fallbackPose: RatelPose.point, size: 44),
        ),
        const SizedBox(width: 6),
        Expanded(child: bubble),
      ],
    );
  }
}

/// Conversation scenarios — practice REAL situations. Free (daily caps
/// unchanged); Duolingo gates roleplay behind its top tier.
class CoachScenario {
  const CoachScenario(this.title, this.icon, this.prompt, {this.sKey = ''});

  final String title;
  final IconData icon;
  final String prompt; // sent to the LLM — stays English by design
  final String sKey; // app_strings key for the card title
}

const List<CoachScenario> kCoachScenarios = [
  CoachScenario('Order at a café', Icons.local_cafe, sKey: 'scn_cafe',
      "Let's roleplay! You are a friendly waiter at a café and I am a "
      'customer ordering food. Please start the scene.'),
  CoachScenario('Job interview', Icons.work, sKey: 'scn_interview',
      "Let's roleplay! You are a kind interviewer and I am applying for a "
      'job. Ask me your first question.'),
  CoachScenario('Meet a new friend', Icons.emoji_people, sKey: 'scn_friend',
      "Let's roleplay! We just met at a park. You start a friendly "
      'conversation with me.'),
  CoachScenario('At the doctor', Icons.medical_services, sKey: 'scn_doctor',
      "Let's roleplay! You are a caring doctor and I am your patient. "
      'Ask me what is wrong.'),
];
