import 'models.dart';

/// Sample Unit 1 content (English immersion, A1). Replaced by Supabase later.
const Unit unit1 = Unit(
  title: 'Unit 1',
  subtitle: 'Everyday basics',
  lessons: [
    Lesson(id: 'u1l1', title: 'Greetings', exercises: [
      Exercise.choice(
        prompt: 'Which word is a greeting?',
        options: ['Hello', 'Apple', 'Chair', 'River'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Choose the word that completes the sentence',
        sentence: '___ are you?',
        options: ['How', 'What', 'Who', 'When'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the morning greeting',
        options: ['morning', 'Good', 'night', 'away'],
        correctOrder: ['Good', 'morning'],
      ),
      Exercise.choice(
        prompt: 'Best reply to "How are you?"',
        options: ["I'm fine, thanks", 'A blue car', 'Yesterday', 'Seven'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'Nice to ___ you.',
        options: ['meet', 'eat', 'run', 'sleep'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u1l2', title: 'People', exercises: [
      Exercise.choice(
        prompt: 'Which word is a person?',
        options: ['Teacher', 'Table', 'Apple', 'Window'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'She ___ a doctor.',
        options: ['is', 'are', 'am', 'be'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['friend', 'He', 'my', 'is'],
        correctOrder: ['He', 'is', 'my', 'friend'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'They ___ students.',
        options: ['are', 'is', 'am', 'be'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u1l3', title: 'Family', exercises: [
      Exercise.choice(
        prompt: 'Which word is a family member?',
        options: ['Mother', 'Spoon', 'Cloud', 'Pencil'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'This is ___ brother.',
        options: ['my', 'I', 'me', 'mine'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['family', 'I', 'my', 'love'],
        correctOrder: ['I', 'love', 'my', 'family'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'My father ___ tall.',
        options: ['is', 'are', 'am', 'be'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u1l4', title: 'Food & drink', exercises: [
      Exercise.choice(
        prompt: 'Which one is a drink?',
        options: ['Water', 'Chair', 'Shoe', 'Road'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I ___ an apple.',
        options: ['eat', 'drink', 'sleep', 'run'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['like', 'I', 'tea', 'green'],
        correctOrder: ['I', 'like', 'green', 'tea'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'Do you ___ coffee?',
        options: ['like', 'likes', 'liking', 'liked'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u1l5', title: 'Daily routine', exercises: [
      Exercise.choice(
        prompt: 'Which is a morning action?',
        options: ['Wake up', 'Sunset', 'Midnight', 'Yesterday'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'She ___ up at seven.',
        options: ['gets', 'get', 'getting', 'got'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['work', 'I', 'to', 'go'],
        correctOrder: ['I', 'go', 'to', 'work'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'We ___ dinner at night.',
        options: ['have', 'has', 'having', 'had'],
        correctIndex: 0,
      ),
    ]),
  ],
);

/// Sample Unit 2 content (English immersion, A1→A2). Replaced by Supabase later.
const Unit unit2 = Unit(
  title: 'Unit 2',
  subtitle: 'Out and about',
  lessons: [
    Lesson(id: 'u2l1', title: 'Numbers', exercises: [
      Exercise.choice(
        prompt: 'Which word is a number?',
        options: ['Seven', 'Green', 'Loud', 'Soft'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I have ___ apples.',
        options: ['three', 'tree', 'free', 'threes'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['are', 'There', 'five', 'books'],
        correctOrder: ['There', 'are', 'five', 'books'],
      ),
      Exercise.choice(
        prompt: 'What comes after nine?',
        options: ['Ten', 'Eight', 'Twenty', 'Two'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'She is ___ years old.',
        options: ['ten', 'tens', 'tenth', 'tenning'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u2l2', title: 'Time & days', exercises: [
      Exercise.choice(
        prompt: 'Which is a day of the week?',
        options: ['Monday', 'January', 'Summer', 'Evening'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I wake up ___ seven o\'clock.',
        options: ['at', 'in', 'on', 'to'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['is', 'It', 'Monday', 'today'],
        correctOrder: ['It', 'is', 'Monday', 'today'],
      ),
      Exercise.choice(
        prompt: 'What day comes after Friday?',
        options: ['Saturday', 'Thursday', 'Tuesday', 'June'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'We have class ___ the morning.',
        options: ['in', 'at', 'on', 'by'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u2l3', title: 'Places in town', exercises: [
      Exercise.choice(
        prompt: 'Which is a place in town?',
        options: ['Hospital', 'Apple', 'Happy', 'Quickly'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I buy bread at the ___.',
        options: ['bakery', 'library', 'station', 'garden'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['the', 'to', 'go', 'I', 'park'],
        correctOrder: ['I', 'go', 'to', 'the', 'park'],
      ),
      Exercise.choice(
        prompt: 'Where do you borrow books?',
        options: ['Library', 'Bakery', 'Cinema', 'Market'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'The bank is ___ the school.',
        options: ['next to', 'next', 'beside of', 'near from'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u2l4', title: 'Shopping', exercises: [
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'How ___ is this shirt?',
        options: ['much', 'many', 'long', 'old'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I would like ___ apples, please.',
        options: ['some', 'much', 'a', 'any'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the question',
        options: ['it', 'does', 'How', 'cost', 'much'],
        correctOrder: ['How', 'much', 'does', 'it', 'cost'],
      ),
      Exercise.choice(
        prompt: 'Which word means money you get back?',
        options: ['Change', 'Chance', 'Charge', 'Choice'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'That will be ten ___.',
        options: ['dollars', 'dollar', 'dollares', 'dollor'],
        correctIndex: 0,
      ),
    ]),
    Lesson(id: 'u2l5', title: 'Weather', exercises: [
      Exercise.choice(
        prompt: 'Which word describes weather?',
        options: ['Sunny', 'Table', 'Happy', 'Quietly'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'It is ___ today, take an umbrella.',
        options: ['raining', 'sunny', 'dry', 'clear'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['is', 'It', 'hot', 'very', 'today'],
        correctOrder: ['It', 'is', 'very', 'hot', 'today'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'In winter it is often ___.',
        options: ['cold', 'warm', 'hot', 'dry'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'What do you wear when it rains?',
        options: ['Raincoat', 'Sunglasses', 'Sandals', 'Shorts'],
        correctIndex: 0,
      ),
    ]),
  ],
);

/// Sample Unit 3 content (English immersion, A2). Replaced by Supabase later.
const Unit unit3 = Unit(
  title: 'Unit 3',
  subtitle: 'Getting things done',
  lessons: [
    Lesson(id: 'u3l1', title: 'Directions', exercises: [
      Exercise.choice(
        prompt: 'Which word gives a direction?',
        options: ['Apple', 'Left', 'Happy', 'Slowly'],
        correctIndex: 1,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'Turn ___ at the corner.',
        options: ['red', 'right', 'ride', 'road'],
        correctIndex: 1,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['station', 'to', 'Go', 'the'],
        correctOrder: ['Go', 'to', 'the', 'station'],
      ),
      Exercise.choice(
        prompt: 'The opposite of "left" is ___.',
        options: ['up', 'near', 'right', 'here'],
        correctIndex: 2,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'The bank is ___ to the school.',
        options: ['far', 'next', 'behind', 'under'],
        correctIndex: 1,
      ),
    ]),
    Lesson(id: 'u3l2', title: 'Health & body', exercises: [
      Exercise.choice(
        prompt: 'Which is a part of the body?',
        options: ['Chair', 'Cloud', 'Arm', 'Spoon'],
        correctIndex: 2,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I have a ___, I need to rest.',
        options: ['headache', 'homework', 'window', 'holiday'],
        correctIndex: 0,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['well', 'I', 'feel', 'not', 'do'],
        correctOrder: ['I', 'do', 'not', 'feel', 'well'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'You should see a ___ when you are sick.',
        options: ['teacher', 'doctor', 'driver', 'waiter'],
        correctIndex: 1,
      ),
      Exercise.choice(
        prompt: 'What should you do when you are tired?',
        options: ['Shout', 'Jump', 'Run', 'Rest'],
        correctIndex: 3,
      ),
    ]),
    Lesson(id: 'u3l3', title: 'Work & jobs', exercises: [
      Exercise.choice(
        prompt: 'Which word is a job?',
        options: ['Yellow', 'Engineer', 'Quickly', 'Under'],
        correctIndex: 1,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'A ___ teaches students.',
        options: ['farmer', 'pilot', 'teacher', 'chef'],
        correctIndex: 2,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['office', 'works', 'an', 'She', 'in'],
        correctOrder: ['She', 'works', 'in', 'an', 'office'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'He ___ to work by bus.',
        options: ['goes', 'go', 'going', 'gone'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'Where does a chef work?',
        options: ['Garden', 'Kitchen', 'Airport', 'Library'],
        correctIndex: 1,
      ),
    ]),
    Lesson(id: 'u3l4', title: 'Free time', exercises: [
      Exercise.choice(
        prompt: 'Which is a hobby?',
        options: ['Monday', 'Yellow', 'Painting', 'Quickly'],
        correctIndex: 2,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'I like ___ football on weekends.',
        options: ['play', 'playing', 'played', 'plays'],
        correctIndex: 1,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['books', 'She', 'reading', 'loves'],
        correctOrder: ['She', 'loves', 'reading', 'books'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'They go ___ in the river in summer.',
        options: ['swimming', 'swim', 'swam', 'swims'],
        correctIndex: 0,
      ),
      Exercise.choice(
        prompt: 'What do you use to take photos?',
        options: ['Spoon', 'Camera', 'Pillow', 'Hammer'],
        correctIndex: 1,
      ),
    ]),
    Lesson(id: 'u3l5', title: 'Yesterday', exercises: [
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'Yesterday I ___ to the market.',
        options: ['go', 'went', 'goes', 'going'],
        correctIndex: 1,
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'She ___ a film last night.',
        options: ['watches', 'watched', 'watch', 'watching'],
        correctIndex: 1,
      ),
      Exercise.wordBank(
        prompt: 'Build the sentence',
        options: ['lunch', 'We', 'ate', 'together'],
        correctOrder: ['We', 'ate', 'lunch', 'together'],
      ),
      Exercise.choice(
        prompt: 'Complete the sentence',
        sentence: 'They ___ happy at the party.',
        options: ['was', 'were', 'are', 'is'],
        correctIndex: 1,
      ),
      Exercise.choice(
        prompt: 'What is the past tense of "see"?',
        options: ['seen', 'saw', 'sees', 'seeing'],
        correctIndex: 1,
      ),
    ]),
  ],
);

/// Sample Unit 4 content (English immersion, A2->B1). Replaced by Supabase later.
const Unit unit4 = Unit(
  title: 'Unit 4',
  subtitle: 'Plans & connections',
  lessons: [
    Lesson(id: 'u4l1', title: 'Future plans', exercises: [
      Exercise.choice(prompt: 'Which word talks about the future?', options: ['Yesterday', 'Tomorrow', 'Now', 'Ago'], correctIndex: 1),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'I ___ going to visit my friend.', options: ['is', 'am', 'are', 'be'], correctIndex: 1),
      Exercise.wordBank(prompt: 'Build the sentence', options: ['will', 'We', 'tomorrow', 'travel'], correctOrder: ['We', 'will', 'travel', 'tomorrow']),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'She is going to ___ a new job.', options: ['started', 'start', 'starts', 'starting'], correctIndex: 1),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'What are your plans for the ___?', options: ['ago', 'weekend', 'yesterday', 'last'], correctIndex: 1),
    ]),
    Lesson(id: 'u4l2', title: 'Comparisons', exercises: [
      Exercise.choice(prompt: 'Which word compares two things?', options: ['Big', 'Bigger', 'Run', 'Blue'], correctIndex: 1),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'An elephant is ___ than a cat.', options: ['big', 'bigger', 'biggest', 'bigly'], correctIndex: 1),
      Exercise.wordBank(prompt: 'Build the sentence', options: ['than', 'She', 'taller', 'is', 'me'], correctOrder: ['She', 'is', 'taller', 'than', 'me']),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'This book is ___ interesting than that one.', options: ['most', 'more', 'much', 'many'], correctIndex: 1),
      Exercise.choice(prompt: 'The opposite of "faster" is ___.', options: ['fastest', 'slow', 'slower', 'quick'], correctIndex: 2),
    ]),
    Lesson(id: 'u4l3', title: 'Feelings & opinions', exercises: [
      Exercise.choice(prompt: 'Which word is a feeling?', options: ['Table', 'Happy', 'Quickly', 'Green'], correctIndex: 1),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'I ___ that English is fun.', options: ['thinks', 'think', 'thinking', 'thought'], correctIndex: 1),
      Exercise.wordBank(prompt: 'Build the sentence', options: ['with', 'I', 'you', 'agree'], correctOrder: ['I', 'agree', 'with', 'you']),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'She feels ___ because she passed the test.', options: ['sadly', 'happy', 'quickly', 'table'], correctIndex: 1),
      Exercise.choice(prompt: 'What do you say to agree?', options: ['Go away', 'You are right', 'No way', 'Be quiet'], correctIndex: 1),
    ]),
    Lesson(id: 'u4l4', title: 'On the phone', exercises: [
      Exercise.choice(prompt: 'What do you say to answer a phone?', options: ['Goodbye', 'Hello', 'Sleep', 'Run'], correctIndex: 1),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'Can I ___ to Maria, please?', options: ['speaks', 'speak', 'spoke', 'speaking'], correctIndex: 1),
      Exercise.wordBank(prompt: 'Build the sentence', options: ['I', 'message', 'Can', 'leave', 'a'], correctOrder: ['Can', 'I', 'leave', 'a', 'message']),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'Sorry, she is not ___ right now.', options: ['apple', 'available', 'angry', 'asleep'], correctIndex: 1),
      Exercise.choice(prompt: 'How do you end a call politely?', options: ['Get lost', 'Talk soon, bye', 'Be quiet', 'Go away'], correctIndex: 1),
    ]),
    Lesson(id: 'u4l5', title: 'Travel', exercises: [
      Exercise.choice(prompt: 'Where do you catch a train?', options: ['Kitchen', 'Station', 'Garden', 'Bedroom'], correctIndex: 1),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'I would like a ___ ticket to London.', options: ['returns', 'return', 'returning', 'returned'], correctIndex: 1),
      Exercise.wordBank(prompt: 'Build the question', options: ['does', 'What', 'it', 'time', 'leave'], correctOrder: ['What', 'time', 'does', 'it', 'leave']),
      Exercise.choice(prompt: 'Complete the sentence', sentence: 'The train ___ at platform two.', options: ['arrive', 'arrives', 'arriving', 'arrived'], correctIndex: 1),
      Exercise.choice(prompt: 'What do you need to fly abroad?', options: ['Spoon', 'Passport', 'Pillow', 'Hammer'], correctIndex: 1),
    ]),
  ],
);

/// Built-in course (offline fallback + test baseline).
const List<Unit> builtInCourse = [unit1, unit2, unit3, unit4];

/// The active course: built-in by default, swapped to DB content at startup by
/// ContentStore. Everything reads it via `course`. Lessons unlock in order.
List<Unit> _activeCourse = builtInCourse;
List<Unit> get course => _activeCourse;
void setActiveCourse(List<Unit> units) => _activeCourse = units;

/// Resolve a content key ('lessonId:exerciseIndex') back to its [Exercise],
/// or null if it doesn't map to current content (e.g. content changed). Used
/// to rebuild a "practice your mistakes" session from logged attempt keys.
Exercise? exerciseForKey(String key) {
  final parts = key.split(':');
  if (parts.length < 2) return null;
  final lessonId = parts[0];
  final idx = int.tryParse(parts[1]);
  if (idx == null) return null;
  for (final unit in course) {
    for (final lesson in unit.lessons) {
      if (lesson.id == lessonId) {
        if (idx >= 0 && idx < lesson.exercises.length) {
          return lesson.exercises[idx];
        }
        return null;
      }
    }
  }
  return null;
}
