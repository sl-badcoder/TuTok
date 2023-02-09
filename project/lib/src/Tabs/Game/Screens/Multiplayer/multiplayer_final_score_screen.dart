// This is the final score screen for singleplayer

import 'package:blinky_two/src/data/Models/game_session.dart';
import 'package:flutter/material.dart';

import '../../../../data/Models/game.dart';
import '../../../../data/Models/user.dart';

class MultiplayerGameFinalScoreScreen extends StatefulWidget {
  final List<Game> games;
  final User user;
  final int score;
  final Game game;
  final GameSession gameSession;

  const MultiplayerGameFinalScoreScreen(
      {Key? key,
      required this.games,
      required this.user,
      required this.score,
      required this.game,
      required this.gameSession})
      : super(key: key);

  @override
  State<MultiplayerGameFinalScoreScreen> createState() => _MultiplayerGameFinalScoreScreen();
}

class _MultiplayerGameFinalScoreScreen extends State<MultiplayerGameFinalScoreScreen> {
  bool _startScreen = false;
  bool _menuScreen = false;
  bool _tie = false;
  late Map<String, int> userScores;
  late MapEntry<String, int> firstUser;
  late MapEntry<String, int> secondUser;
  List<int> scores = [];
  List<String> users = [];
  @override
  void initState() {
    super.initState();
    userScores = widget.gameSession.userScores;
    
    userScores.forEach((key, value) {
      scores.add(value);
      String kex = key;
      var hello = kex.split("username='");
      var hello2 = hello[1].split("'");
      users.add( hello2[0]);
    });

    firstUser = new MapEntry(users.elementAt(0), scores.elementAt(0));
    secondUser = new MapEntry(users.elementAt(1), scores.elementAt(1));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrangeAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          firstUser.value == secondUser.value ?
          Center(
            child: Text(
              "TIE",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow),
              textAlign: TextAlign.center,
            ),
          ) :
           Center(
            child: Text(
              "THE WINNER IS: \n \n${firstUser.value > secondUser.value ? firstUser.key: secondUser.key}",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow),
              textAlign: TextAlign.center,
            ),
          ),
          //THE FINAL SCORE
          Center(
            child: Text(
              "YOUR SCORE: \n \n${widget.score} / ${widget.game.maxScore}",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow),
              textAlign: TextAlign.center,
            ),
          ),
          //RETRY AND MENU BUTTON
          Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  _menuScreen = true;
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(
                  "MENU",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
          )
        ],
      ),
    );
  }
}
