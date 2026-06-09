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

/// The full course, in order. Lessons unlock sequentially across all units.
const List<Unit> course = [unit1, unit2];
