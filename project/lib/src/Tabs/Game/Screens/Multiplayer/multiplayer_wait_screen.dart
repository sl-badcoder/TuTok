//This is the screen to wait and create a new Game

import 'dart:collection';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinky_two/src/Tabs/Game/Screens/game_question_screen.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/Models/game.dart';
import '../../../../data/Models/game_question.dart';
import '../../../../data/Models/game_session.dart';
import '../../../../data/Models/user.dart';
import '../../../../data/Repositories/clip_repository.dart';
import 'multiplayer_game_screen.dart';

class WaitScreen extends StatefulWidget {
  //game
  //user
  final User user;
  late GameSession gameSession;
  final Game game;
  final List<Game> games;
  final double xAxis;
  final double yAxis;
  final double screenHeight;
  final double screenWidth;
  final Size size;

  WaitScreen(
      {Key? key,
      required this.user,
      required this.game,
      required this.games,
      required this.xAxis,
      required this.yAxis,
      required this.screenWidth,
      required this.screenHeight,
      required this.size})
      : super(key: key);

  @override
  State<WaitScreen> createState() => _WaitScreen();
}

class _WaitScreen extends State<WaitScreen>
    with SingleTickerProviderStateMixin {
  bool _startGame = false;
  int _count = 0;
  bool _isCreated = false;
  late List<GameQuestion> gameQuestions;
  late List<VideoPlayerController> videoControllers;
  final ClipRepository clipRepository = ClipRepository();
  final GameRepository gameRepository = GameRepository();
  SplayTreeMap<int, GameQuestionMultiplayerScreen> gameQuestionScreens =
      new SplayTreeMap();
  late GameQuestionScreen currentGameQuestionScreen;
  late AnimationController controller;
  late Animation colorAnimation;
  late Animation heightAnimation;
  late Animation widthAnimation;
  late Animation xPositionAnimation;
  late Animation yPositionAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    colorAnimation =
        ColorTween(begin: Colors.orange[800], end: Colors.orange[900])
            .animate(controller);
    heightAnimation =
        Tween<double>(begin: widget.size.height, end: widget.screenHeight)
            .animate(controller);
    widthAnimation =
        Tween<double>(begin: widget.size.width, end: widget.screenWidth)
            .animate(controller);
    xPositionAnimation =
        Tween<double>(begin: widget.xAxis, end: 0).animate(controller);
    yPositionAnimation =
        Tween<double>(begin: widget.yAxis, end: 0).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return createAnimation();
  }

  Widget createAnimation() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        title: Text(
          "CREATE SESSION",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned(
              left: xPositionAnimation.value,
              top: yPositionAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    color: Colors.blue, //colorAnimation.value,
                    borderRadius: colorAnimation.isCompleted
                        ? BorderRadius.all(Radius.zero)
                        : BorderRadius.all(Radius.circular(20))),
                height: heightAnimation.value,
                width: widthAnimation.value,
                child: heightAnimation.isCompleted
                    ? Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // TITLE OF THE GAME
                              // SHORT DESCRIPTION
                              //START BUTTON LEADS TO GAMEQUESTION
                              AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText('PRESS CREATE TO START',
                                      textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber)),
                                ],
                              ),
                              DelayedDisplay(
                                delay: Duration(seconds: 1),
                                fadeIn: true,
                                slidingBeginOffset: Offset(0, -0.1),
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GameQuestionMultiplayerScreen(
                                                    user: widget.user,
                                                    game: widget.game,
                                                    games: widget.games,
                                                  )));
                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(40, 40),
                                        backgroundColor: Colors.amberAccent),
                                    child: Text(
                                      "CREATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black),
                                    )),
                              )
                            ],
                          ),
                        ),
                      )
                    : Text(""),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
