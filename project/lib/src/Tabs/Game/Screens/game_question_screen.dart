// This is the game_question screen for one question

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinky_two/src/Tabs/Game/Screens/SinglePlayer/singleplayer_final_score_screen.dart';
import 'package:blinky_two/src/data/Models/game.dart';
import 'package:blinky_two/src/data/Models/game_question.dart';
import 'package:blinky_two/src/data/Models/game_session.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/Models/user.dart';

class GameQuestionScreen extends StatefulWidget {
  final GameQuestion gameQuestion;
  final VideoPlayerController videoPlayerController;
  final User user;
  final Game game;
  final GameSession gameSession;
  final int numberOfQuestion;
  final bool isLast;
  final List<Game> games;
  final ValueChanged<int> update;

  const GameQuestionScreen(
      {Key? key,
      required this.user,
      required this.gameQuestion,
      required this.videoPlayerController,
      required this.game,
      required this.gameSession,
      required this.numberOfQuestion,
      required this.isLast,
      required this.games,
      required this.update})
      : super(key: key);

  @override
  State<GameQuestionScreen> createState() => _GameQuestionScreen();
}

class _GameQuestionScreen extends State<GameQuestionScreen> {
  bool _videoEnded = false;
  bool _isAnswered = false;
  bool _answerDisplayed = false;
  bool _isStarted = false;
  bool _answer = false;
  int score = 0;
  int time = 0;
  int index = 0;
  bool _ended = false;

  List<Color> colorizeColors = [
    Colors.yellow,
    Colors.yellow[600]!,
    Colors.yellow[700]!,
    Colors.yellow[800]!,
  ];

  GameRepository gameRepository = GameRepository();

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(checkVideo);
    _videoEnded = false;
    _isAnswered = false;
    _answerDisplayed = false;
    _isStarted = false;
    _answer = false;
    score = 0;
  }

  Widget endWidget() {
    return Container(
      color: _answer ? Colors.green[300] : Colors.red[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Center(
              child: _answer
                  ? Text(
                      "Your answer was Right",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      "Your answer was Wrong",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          SizedBox(
            child: Center(
                child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText('Your new Score is: ${score}',
                    textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                    colors: colorizeColors),
              ],
              onTap: () {
                print("I am executing");
              },
            )),
          ),
          widget.game.gameQuestions!.length <= index + 1
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, shape: StadiumBorder()),
                  onPressed: () {
                    _ended = true;
                    setState(() {});
                  },
                  child: Text("END GAME",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, shape: StadiumBorder()),
                  onPressed: () {
                    widget.update(widget.numberOfQuestion + 1);
                    _videoEnded = false;
                    _isStarted = false;
                    widget.videoPlayerController.dispose();
                    _isAnswered = false;
                    index++;
                  },
                  child: Text(
                    "NEXT QUESTION",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ))
        ],
      ),
    );
  }

  Widget timerCircular(double screenHeight, double screenWidth) {
    return Positioned(
      top: screenHeight / 3.3,
      child: Center(
        child: CircularCountDownTimer(
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textFormat: CountdownTextFormat.SS,
          autoStart: true,
          isReverse: true,
          isReverseAnimation: true,
          onComplete: () {
            _isAnswered = true;
            _answer = false;
            setState(() {});
          },
          onChange: (String timestamp) {
            debugPrint("Timestamp: $timestamp");
            time = int.parse(timestamp);
          },
          width: screenHeight / 10,
          height: screenHeight / 15,
          duration: 10,
          fillColor: Colors.orange,
          ringColor: Colors.white,
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }

  Widget questionWithAnswer(double screenHeight, double screenWidth) {
    return Column(
      children: [
        question(screenHeight, screenWidth),
        answers(screenHeight, screenWidth)
      ],
    );
  }

  Widget question(double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight / 2.5,
      width: screenWidth,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.black12,
      ),
      child: Center(
        child: Text(
          widget.gameQuestion.question!,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget answers(double screenHeight, double screenWidth) {
    return SizedBox(
      height: screenHeight / 2.5,
      width: screenWidth,
      child: Column(
        children: [
          Row(
            children: [
              selectAnswerWidget(screenHeight, screenWidth, 0),
              selectAnswerWidget(screenHeight, screenWidth, 1)
            ],
          ),
          Row(
            children: [
              selectAnswerWidget(screenHeight, screenWidth, 2),
              selectAnswerWidget(screenHeight, screenWidth, 3)
            ],
          ),
        ],
      ),
    );
  }

  Widget questionWidget(double screenHeight, double screenWidth) {
    return Container(
      color: Colors.orange[900],
      child: Stack(
        alignment: Alignment.center,
        children: [
          questionWithAnswer(screenHeight, screenWidth),
          timerCircular(screenHeight, screenWidth),
        ],
      ),
    );
  }

  Widget selectAnswerWidget(
      double screenHeight, double screenWidth, int answerNumber) {
    return SizedBox(
        child: Container(
      height: screenHeight / 5,
      width: screenWidth / 2,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        border: Border.all(color: Colors.black),
        color: Colors.orange,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        onPressed: () async {
          final result = await gameRepository.checkAnswer(
              widget.gameSession,
              widget.gameQuestion,
              widget.gameQuestion.answers!.elementAt(answerNumber));
          widget.gameSession.currentQuestion++;
          _answer = result.correct;
          score = result.totalPoints;
          _isAnswered = true;
          setState(() {});
        },
        child: Center(
            child: Text(
          widget.gameQuestion.answers!.elementAt(answerNumber),
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        )),
      ),
    ));
  }

  Widget videoWidget() {
    return Stack(
      children: [
        Center(
            child: AspectRatio(
          aspectRatio: widget.videoPlayerController.value.aspectRatio,
          child: VideoPlayer(widget.videoPlayerController),
        )),
        !_isStarted
            ? Align(
                alignment: FractionalOffset.bottomCenter,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: StadiumBorder()),
                    onPressed: () {
                      widget.videoPlayerController.play();
                      widget.videoPlayerController.addListener(checkVideo);
                      _isStarted = true;
                      setState(() {});
                    },
                    child: Text(
                      "PLAY",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
              )
            : Text("")
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return _videoEnded
        ? (_isAnswered
            ? (_ended
                ? GameFinalScoreScreen(
                    games: widget.games,
                    user: widget.user,
                    score: score,
                    game: widget.game)
                : endWidget())
            : questionWidget(screenHeight, screenWidth))
        : videoWidget();
  }

  void checkVideo() {
    if (widget.videoPlayerController.value.position ==
        widget.videoPlayerController.value.duration) {
      _videoEnded = true;
      print("ended");
      setState(() {});
    }
  }
}
