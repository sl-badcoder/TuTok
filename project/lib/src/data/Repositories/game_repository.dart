// This is the repository for game with Endpoints /game/

import 'dart:convert';
import 'dart:io';

import 'package:blinky_two/src/data/Models/check_answer_result.dart';
import 'package:blinky_two/src/data/Models/game_question.dart';
import 'package:http/http.dart' as http;

import '../Models/game.dart';
import '../Models/game_session.dart';
import '../Models/user.dart';
import '../Services/api_service.dart';

class GameRepository {
  final APIService _apiService = APIService();

  Future<List<Game>> getGames() async {
    http.Response response = await _apiService.get("/game/list", {});
    Iterable responseJson = jsonDecode(response.body);
    List<Game> games =
        List<Game>.from(responseJson.map((e) => Game.fromJson(e)));
    return games;
  }

  Future<Game> getGame(int id) async {
    http.Response response = await _apiService.get("/game/$id", {});
    dynamic responseJson = jsonDecode(response.body);
    Game game = Game.fromJson(responseJson);
    return game;
  }

  Future<List<GameQuestion>> getGameQuestions(int id) async {
    http.Response response =
        await _apiService.get("/game/$id/gameQuestion", {});
    dynamic responseJson = jsonDecode(response.body);
    List<GameQuestion> gameQuestion =
        List<GameQuestion>.from(responseJson.map((e) => Game.fromJson(e)));
    return gameQuestion;
  }

  Future<CheckAnswerResult> checkAnswer(GameSession gameSession,
      GameQuestion gameQuestion, String? answer) async {
    http.Response response = await _apiService.get(
        "/gameSession/${gameSession.id}/${gameQuestion.questionID}/checkAnswer",
        {"answer": answer!});
    if (response.statusCode == HttpStatus.ok) {
      dynamic responseJson = jsonDecode(response.body);
      CheckAnswerResult checkAnswerResult =
      CheckAnswerResult.fromJson(responseJson);
      return checkAnswerResult;
    }
    return Future.error(
        "Could not get answer result! Error: ${response.statusCode} ${response.reasonPhrase}");
  }

  Future<GameSession> joinNewGameSession(int gameId) async {
    http.Response response = await _apiService
        .get("/gameSession/joinNewGameSession", {"gameId": "$gameId"});
    if (response.statusCode == HttpStatus.created) {
      dynamic responseJson = jsonDecode(response.body);
      return GameSession.fromJson(responseJson);
    }
    return Future.error(
        "Could not create session! Error: ${response.statusCode} ${response.reasonPhrase}");
  }

  Future<List<User>> getLeaderboard(int? n) async {
    http.Response response =
        await _apiService.get("/game/leaderboard", {"n": "$n"});
    Iterable responseJson = jsonDecode(response.body);
    List<User> users =
        List<User>.from(responseJson.map((e) => User.fromJson(e)));
    return users;
  }

  Future<List<GameSession>> openedMultiplayerSessions() async {
    http.Response response =
        await _apiService.get("/gameSession/openedMultiplayerSessions", {});
    Iterable responseJson = jsonDecode(response.body);
    List<GameSession> gameSessions = List<GameSession>.from(
        responseJson.map((e) => GameSession.fromJson(e)));
    return gameSessions;
  }
}
