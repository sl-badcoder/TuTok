// This is the singleplayer screen to start one game

import 'dart:collection';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinky_two/src/Tabs/Game/Screens/game_question_screen.dart';
import 'package:blinky_two/src/data/Models/game_session.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/Models/game.dart';
import '../../../../data/Models/game_question.dart';
import '../../../../data/Models/user.dart';
import '../../../../data/Repositories/clip_repository.dart';

class GameStartScreen extends StatefulWidget {
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

  GameStartScreen(
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
  State<GameStartScreen> createState() => _GameStartScreen();
}

class _GameStartScreen extends State<GameStartScreen>
    with SingleTickerProviderStateMixin {
  late List<GameQuestion> gameQuestions;
  late List<VideoPlayerController> videoControllers;
  final ClipRepository clipRepository = ClipRepository();
  final GameRepository gameRepository = GameRepository();
  SplayTreeMap<int, GameQuestionScreen> gameQuestionScreens =
      new SplayTreeMap();
  late GameQuestionScreen currentGameQuestionScreen;
  late AnimationController controller;
  late Animation colorAnimation;
  late Animation heightAnimation;
  late Animation widthAnimation;
  late Animation xPositionAnimation;
  late Animation yPositionAnimation;

  int _count = 0;
  bool _startGame = false;
  bool _isvisible = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    gameRepository.joinNewGameSession(widget.game.id!).then((value) => {
          widget.gameSession = value,
          _isLoaded = true,
          videoControllers = getControllers(),
          setState(() {})
        });

    _count = 0;
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    // Defining both color and size animations
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

  void _update(int test) {
    setState(() {
      _count = _count + 1;
      print("update: $_count");
    });
  }

  @override
  Widget build(BuildContext context) {
    return _startGame
        ? Scaffold(
            body: gameQuestionScreens[_count]!,
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0x00000000),
              elevation: 0,
              title: Text(
                "PLAY",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // TITLE OF THE GAME
                                    Text(
                                      "GAME: " + widget.game.title!,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    // SHORT DESCRIPTION
                                    AnimatedTextKit(
                                      animatedTexts: [
                                        TyperAnimatedText(
                                            'PRESS START TO PLAY THE GAME.',
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber)),
                                      ],
                                      onTap: () {
                                        print("I am executing");
                                      },
                                    ),
                                    //START BUTTON LEADS TO GAMEQUESTION
                                    DelayedDisplay(
                                      delay: Duration(seconds: 1),
                                      fadeIn: true,
                                      slidingBeginOffset: Offset(0, -0.1),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _startGame = _isLoaded;
                                            setState(() {});
                                          },
                                          style: ElevatedButton.styleFrom(
                                              minimumSize: Size(40, 40),
                                              backgroundColor:
                                                  Colors.amberAccent),
                                          child: Text(
                                            "START",
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

  List<VideoPlayerController> getControllers() {
    List<VideoPlayerController> videoControllers = [];
    for (int i = 0; i < widget.game.gameQuestions!.length; i++) {
      clipRepository
          .getClipVideo(widget.game.gameQuestions!.elementAt(i).clip!.clipID!)
          .then((value) {
        VideoPlayerController videoPlayerController =
            VideoPlayerController.network(value.toString())
              ..initialize().then((value) => {setState(() {})})
              ..setVolume(0.1);
        gameQuestionScreens[i] = GameQuestionScreen(
          user: widget.user,
          gameQuestion: widget.game.gameQuestions!.elementAt(i),
          videoPlayerController: videoPlayerController,
          game: widget.game,
          numberOfQuestion: i,
          isLast: false,
          games: widget.games,
          gameSession: widget.gameSession,
          update: _update,
        );
      });
    }
    return videoControllers;
  }
}
