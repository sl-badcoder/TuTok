// This is a Model for a gameSession

import 'game.dart';

class GameSession {
  int id;
  Game game;
  int currentQuestion;
  Map<String, int> userScores;
  Set<String> currentUsers;
  String sessionStatus;
  int timeLeft;

  GameSession(this.id, this.game, this.currentQuestion, this.userScores,
      this.currentUsers, this.sessionStatus, this.timeLeft);

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      json['id'],
      Game.fromJson(json['game']),
      json['currentQuestion'],
      Map<String, int>.from(json['userScores']),
      Set<String>.from(json['currentUsers']),
      json['sessionStatus'],
      json['timeLeft'],
    );
  }

  Map<String, dynamic> toJson(GameSession gameSession) {
    return {
      "id": gameSession.id,
      "game": gameSession.game,
      "currentQuestion": gameSession.currentQuestion,
      "userScores": gameSession.userScores,
      "currentUsers": gameSession.currentUsers
    };
  }

  @override
  String toString() {
    return 'GameSession{id: $id, game: $game, currentQuestion: $currentQuestion,'
        ' userScores: $userScores, currentUsers: $currentUsers}';
  }
}
