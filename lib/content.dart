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
