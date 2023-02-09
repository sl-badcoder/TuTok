// This is a Model for GameQuestion

import 'clip.dart';

class GameQuestion {
  int? questionID;
  String? question;
  Clip? clip;
  List<String>? answers;
  String? correctAnswer;

  GameQuestion({
    required this.questionID,
    required this.question,
    required this.clip,
    required this.answers,
    this.correctAnswer,
  });

  GameQuestion.empty();

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    return GameQuestion(
      questionID: json['questionID'],
      question: json['question'],
      clip: json['clip'] == null ? null : Clip.fromJson(json['clip']),
      answers: List<String>.from(json['answers']),
    );
  }

  Map<String, dynamic> toJson(GameQuestion gameQuestion) {
    return {
      "questionID": gameQuestion.questionID,
      "question": gameQuestion.question,
      "clip": gameQuestion.clip,
      "answers": gameQuestion.answers,
      "correctAnswer": gameQuestion.correctAnswer,
    };
  }

  @override
  String toString() {
    return 'GameQuestion{questionID: $questionID,'
        ' question: $question,'
        ' clip: $clip,'
        ' answers: $answers'
        '}';
  }
}
