import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
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
          color: RatelColors.surface,
          child: Row(
            children: [
              const RatelMascot(pose: RatelPose.speak, size: 46),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Coach',
                        style: TextStyle(
                            fontSize: 18, fontFamily: kDisplayFont, fontWeight: FontWeight.w700)),
                    Text(
                      left == null
                          ? 'Real conversation practice with Ratel'
                          : '$left messages left today',
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
            itemBuilder: (context, i) => _bubble(_msgs[i]),
          ),
        ),
        if (_waiting)
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 6),
            child: Row(
              children: [
                SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Ratel is typing...',
                    style: TextStyle(
                        color: RatelColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        if (_msgs.length <= 1 && !_waiting)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final s in _starters)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(s),
                      onPressed: () => _send("Let's talk about: $s"),
                    ),
                  ),
              ],
            ),
          ),
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
                      hintText: 'Type in English...',
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

  Widget _bubble(ChatMsg m) {
    final bool user = m.role == 'user';
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: user ? RatelColors.honey : RatelColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(user ? 14 : 4),
            bottomRight: Radius.circular(user ? 4 : 14),
          ),
          border: user ? null : Border.all(color: const Color(0xFFEAEAEA)),
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
  }
}
