/// Design-phase stub dictionary (precursor to the phase-2 content model).
/// Pure data — no UI, no backend. Seeded with the words used in Stories/Video.
/// `lookupWord` is case-insensitive and returns null for unknown words.
const Map<String, Map<String, String>> kWordDefinitions =
    <String, Map<String, String>>{
  'into': <String, String>{
    'pos': 'preposition',
    'definition': 'Expressing movement to the inside of something.',
    'example': 'She walked into the café.',
  },
  'take': <String, String>{
    'pos': 'verb',
    'definition': 'To travel using a particular means of transport.',
    'example': "I'll take the train to work.",
  },
  'train': <String, String>{
    'pos': 'noun',
    'definition': 'A connected series of rail carriages that carries people.',
    'example': "I'll take the train to work.",
  },
  'café': <String, String>{
    'pos': 'noun',
    'definition': 'A small place that sells coffee and light meals.',
    'example': 'They met at a café.',
  },
  'coffee': <String, String>{
    'pos': 'noun',
    'definition': 'A hot drink made from roasted coffee beans.',
    'example': 'A coffee, please.',
  },
  'walked': <String, String>{
    'pos': 'verb',
    'definition': 'Past tense of walk — to move on foot.',
    'example': 'She walked into the café.',
  },
  'waiter': <String, String>{
    'pos': 'noun',
    'definition': 'A person who serves food and drink at a restaurant.',
    'example': 'The waiter took her order.',
  },
};

/// Case-insensitive lookup; null when the word isn't in the stub set.
Map<String, String>? lookupWord(String w) => kWordDefinitions[w.toLowerCase()];
