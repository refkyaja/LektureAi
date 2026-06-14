class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  Map<String, dynamic> toJson() => {
    'q': question,
    'options': options,
    'answer': answerIndex,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    question: json['q'] as String,
    options: List<String>.from(json['options'] ?? []),
    answerIndex: json['answer'] as int,
  );
}

class Flashcard {
  final String term;
  final String definition;

  Flashcard({
    required this.term,
    required this.definition,
  });

  Map<String, dynamic> toJson() => {
    'term': term,
    'definition': definition,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    term: json['term'] as String,
    definition: json['definition'] as String,
  );
}

class StudyHistoryItem {
  final String id;
  final String kind; // 'quiz' or 'flash'
  final String noteId;
  final String noteTitle;
  final int createdAt;
  final List<QuizQuestion>? questions;
  final List<Flashcard>? cards;
  final int? scoreCorrect;
  final int? scoreTotal;

  StudyHistoryItem({
    required this.id,
    required this.kind,
    required this.noteId,
    required this.noteTitle,
    required this.createdAt,
    this.questions,
    this.cards,
    this.scoreCorrect,
    this.scoreTotal,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'noteId': noteId,
    'noteTitle': noteTitle,
    'createdAt': createdAt,
    'questions': questions?.map((q) => q.toJson()).toList(),
    'cards': cards?.map((c) => c.toJson()).toList(),
    'scoreCorrect': scoreCorrect,
    'scoreTotal': scoreTotal,
  };

  factory StudyHistoryItem.fromJson(Map<String, dynamic> json) => StudyHistoryItem(
    id: json['id'] as String,
    kind: json['kind'] as String,
    noteId: json['noteId'] as String,
    noteTitle: json['noteTitle'] as String,
    createdAt: json['createdAt'] as int,
    questions: json['questions'] != null
        ? List<QuizQuestion>.from((json['questions'] as List).map((x) => QuizQuestion.fromJson(Map<String, dynamic>.from(x))))
        : null,
    cards: json['cards'] != null
        ? List<Flashcard>.from((json['cards'] as List).map((x) => Flashcard.fromJson(Map<String, dynamic>.from(x))))
        : null,
    scoreCorrect: json['scoreCorrect'] as int?,
    scoreTotal: json['scoreTotal'] as int?,
  );

  StudyHistoryItem copyWithScore(int correct, int total) => StudyHistoryItem(
    id: id,
    kind: kind,
    noteId: noteId,
    noteTitle: noteTitle,
    createdAt: createdAt,
    questions: questions,
    cards: cards,
    scoreCorrect: correct,
    scoreTotal: total,
  );
}
