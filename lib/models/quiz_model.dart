import 'package:cloud_firestore/cloud_firestore.dart';
import 'model_utils.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestion.fromMap(Map<String, dynamic> m) => QuizQuestion(
        id: (m['id'] ?? '').toString(),
        text: (m['text'] ?? '').toString(),
        options: strList(m['options']),
        correctIndex: (m['correctIndex'] as num?)?.toInt() ?? 0,
        explanation: (m['explanation'] ?? '').toString(),
      );
}

class QuizModel {
  const QuizModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.passingScore,
    required this.questions,
  });
  final String id;
  final String chapterId;
  final String title;
  final int passingScore;
  final List<QuizQuestion> questions;

  factory QuizModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return QuizModel(
      id: doc.id,
      chapterId: (d['chapterId'] as String?) ?? '',
      title: (d['title'] as String?) ?? 'Kuis',
      passingScore: (d['passingScore'] as num?)?.toInt() ?? 60,
      questions: mapList(d['questions']).map(QuizQuestion.fromMap).toList(),
    );
  }
}

class QuizResultModel {
  const QuizResultModel({
    required this.id,
    required this.chapterId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completedAt,
  });
  final String id;
  final String chapterId;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime completedAt;

  factory QuizResultModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return QuizResultModel(
      id: doc.id,
      chapterId: (d['chapterId'] as String?) ?? '',
      score: (d['score'] as num?)?.toInt() ?? 0,
      correctAnswers: (d['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (d['totalQuestions'] as num?)?.toInt() ?? 0,
      completedAt: tsToDate(d['completedAt']) ?? DateTime.now(),
    );
  }
}
