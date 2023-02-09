// This is the class for the Model Game

import 'game_question.dart';

class Game {
  int? id;
  String? title;
  List<GameQuestion>? gameQuestions;
  int? maxScore;

  Game(
      {required this.id,
      required this.title,
      required this.gameQuestions,
      required this.maxScore});

  Game.empty();

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        id: json['id'],
        title: json['title'],
        gameQuestions: List<GameQuestion>.from(
            json['gameQuestions'].map((e) => GameQuestion.fromJson(e))),
        maxScore: json['maxScore']);
  }

  Map<String, dynamic> toJson(Game game) {
    return {
      "id": game.id,
      "title": game.title,
      "gameQuestions": game.gameQuestions,
      "maxScore": game.maxScore
    };
  }

  @override
  String toString() {
    return 'Game{id: $id,'
        ' title: $title,'
        ' maxScore: $maxScore,'
        ' gameQuestions: $gameQuestions}';
  }
}
