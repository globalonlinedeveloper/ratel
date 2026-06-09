import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../content.dart';
import '../content_store.dart';

/// Admin-only content editor. Browses lessons (from the active course), lists a
/// lesson's exercises from the DB (with their ids), and edits an exercise's
/// fields straight into content_exercises (admin RLS). Edits go live on the
/// next content load.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Content admin')),
      body: ListView(
        children: [
          for (final unit in course) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(unit.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            for (final lesson in unit.lessons)
              ListTile(
                title: Text(lesson.title),
                subtitle: Text('${lesson.exercises.length} exercises'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AdminLessonScreen(
                        lessonId: lesson.id, title: lesson.title))),
              ),
          ],
        ],
      ),
    );
  }
}

class AdminLessonScreen extends StatefulWidget {
  const AdminLessonScreen(
      {super.key, required this.lessonId, required this.title});
  final String lessonId;
  final String title;

  @override
  State<AdminLessonScreen> createState() => _AdminLessonScreenState();
}

class _AdminLessonScreenState extends State<AdminLessonScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await Supabase.instance.client
        .from('content_exercises')
        .select(
            'id,sort_order,type,prompt,sentence,options,correct_index,correct_order')
        .eq('lesson_id', widget.lessonId)
        .order('sort_order');
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data ?? const [];
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = rows[i];
              return ListTile(
                leading: CircleAvatar(
                    radius: 14, child: Text('${(r['sort_order'] ?? 0)}')),
                title: Text((r['prompt'] ?? '').toString(),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text((r['type'] ?? '').toString()),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () async {
                  final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                          builder: (_) => AdminExerciseEdit(row: r)));
                  if (saved == true && mounted) {
                    setState(() => _future = _load());
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AdminExerciseEdit extends StatefulWidget {
  const AdminExerciseEdit({super.key, required this.row});
  final Map<String, dynamic> row;

  @override
  State<AdminExerciseEdit> createState() => _AdminExerciseEditState();
}

class _AdminExerciseEditState extends State<AdminExerciseEdit> {
  late final String _type = (widget.row['type'] ?? 'choice').toString();
  late final TextEditingController _prompt =
      TextEditingController(text: (widget.row['prompt'] ?? '').toString());
  late final TextEditingController _sentence =
      TextEditingController(text: (widget.row['sentence'] ?? '').toString());
  late final List<TextEditingController> _options = [
    for (final o in (widget.row['options'] as List? ?? const []))
      TextEditingController(text: o.toString())
  ];
  late final TextEditingController _order = TextEditingController(
      text: (widget.row['correct_order'] as List? ?? const [])
          .map((e) => e.toString())
          .join(' '));
  late int _correctIndex = (widget.row['correct_index'] as num?)?.toInt() ?? 0;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _prompt.dispose();
    _sentence.dispose();
    _order.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final opts = _options.map((c) => c.text).toList();
      final patch = <String, dynamic>{
        'prompt': _prompt.text.trim(),
        'sentence': _sentence.text.trim().isEmpty ? null : _sentence.text.trim(),
        'options': opts,
        'correct_index': _type == 'choice' ? _correctIndex : null,
        'correct_order': _type == 'wordBank'
            ? _order.text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList()
            : <String>[],
      };
      await Supabase.instance.client
          .from('content_exercises')
          .update(patch)
          .eq('id', widget.row['id']);
      await ContentStore.instance.load(); // refresh the active course
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Save failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit exercise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Prompt', _prompt),
          if (_type == 'choice') _field('Sentence (optional)', _sentence),
          const SizedBox(height: 8),
          Text(_type == 'choice' ? 'Options (tap to mark correct)' : 'Word tiles',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          for (int i = 0; i < _options.length; i++)
            Row(
              children: [
                if (_type == 'choice')
                  IconButton(
                    tooltip: 'Mark correct',
                    icon: Icon(
                        i == _correctIndex
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: i == _correctIndex
                            ? RatelColors.teal
                            : RatelColors.textMuted),
                    onPressed: () => setState(() => _correctIndex = i),
                  ),
                Expanded(child: _field('Option ${i + 1}', _options[i])),
              ],
            ),
          if (_type == 'wordBank') ...[
            const SizedBox(height: 8),
            _field('Correct order (space-separated)', _order),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: RatelColors.coral)),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );
}
