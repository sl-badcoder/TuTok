// This is the final score screen for singleplayer

import 'package:flutter/material.dart';
import '../../../../data/Models/game.dart';
import '../../../../data/Models/user.dart';

class GameFinalScoreScreen extends StatefulWidget {
  final List<Game> games;
  final User user;
  final int score;
  final Game game;

  const GameFinalScoreScreen(
      {Key? key,
      required this.games,
      required this.user,
      required this.score,
      required this.game})
      : super(key: key);

  @override
  State<GameFinalScoreScreen> createState() => _GameFinalScoreScreen();
}

class _GameFinalScoreScreen extends State<GameFinalScoreScreen> {
  bool _startScreen = false;
  bool _menuScreen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrangeAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //THE FINAL SCORE
          Center(
            child: Text(
              "FINAL SCORE: \n \n${widget.score} / ${widget.game.maxScore}",
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
