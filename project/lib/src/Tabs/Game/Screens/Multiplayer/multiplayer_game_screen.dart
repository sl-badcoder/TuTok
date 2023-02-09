// This is the screen for creating a new MultiplayerGame

import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinky_two/src/data/Models/game.dart';
import 'package:blinky_two/src/data/Models/game_question.dart';
import 'package:blinky_two/src/data/Models/game_session.dart';
import 'package:blinky_two/src/data/Repositories/clip_repository.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/Models/user.dart';
import '../../../../data/Services/api_service.dart';
import 'multiplayer_final_score_screen.dart';

class GameQuestionMultiplayerScreen extends StatefulWidget {
  final User user;
  final Game game;
  final List<Game> games;

  const GameQuestionMultiplayerScreen({
    Key? key,
    required this.user,
    required this.game,
    required this.games,
  }) : super(key: key);

  @override
  State<GameQuestionMultiplayerScreen> createState() =>
      _GameQuestionMultiplayerScreen();
}

class _GameQuestionMultiplayerScreen
    extends State<GameQuestionMultiplayerScreen> {
  bool _waitingForOtherPlayersAnswer = false;
  bool _videoEnded = false;
  bool _isAnswered = false;
  bool _answerDisplayed = false;
  bool _isStarted = false;
  bool _answer = false;
  int score = 0;
  int time = 0;
  int index = 0;
  bool _ended = false;
  bool _startTimer = false;
  int countdown = 4;
  bool _updateIndex = false;
  bool _waitingForPlaybackFinish = false;
  Map<int, VideoPlayerController> videoPlayerControllers = {};
  late GameSession gameSession;
  late int correctGameSessionID = 0;
  int _getControl = 0;
  String value = 'Waiting for Start...';
  String ws_url = "wss://blinky.barpec12.pl/websocket";
  Future<WebSocket>? connection;
  late GameSession correctgameSession;
  List<Color> colorizeColors = [
    Colors.yellow,
    Colors.yellow[600]!,
    Colors.yellow[700]!,
    Colors.yellow[800]!,
  ];

  late StompClient stompClient = StompClient(
      config: StompConfig(
          url: ws_url,
          onConnect: onConnectCallback,
          beforeConnect: () async {
            print('waiting to connect...');
            await Future.delayed(Duration(milliseconds: 200));
            print('connecting...');
          },
          onWebSocketError: (dynamic error) => print(error),
          onDebugMessage: (String msg) => print(msg),
          stompConnectHeaders: {
        "Authorization": "Basic ${APIService.credentials}"
      },
          webSocketConnectHeaders: {
        "Authorization": "Basic ${APIService.credentials}"
      }));

  openConnection() async {
    stompClient.activate();
  }

  /// Subscribes to the gameUpdate and joins a new MultiplayerGameSession
  void onConnectCallback(StompFrame connectFrame) {
    stompClient.subscribe(
        destination: "/user/queue/gameUpdate",
        callback: (connectFrame) async {
          //print(connectFrame.body);
          final body = jsonDecode(connectFrame.body!);
          gameSession = GameSession.fromJson(body);
          if (gameSession.sessionStatus == 'STARTING') {
            correctGameSessionID = gameSession.id;
            correctgameSession = gameSession;
            value = gameSession.timeLeft.toString();
            if (_getControl == 0) {
              videoPlayerControllers = await getControllers(gameSession);
              //print('VIDEOPLAYERCONTROLLERS');
              //print(videoPlayerControllers);
              _getControl++;
            }
          }
          //print("CORRECT GAME SESSION: $correctGameSessionID");
          if (correctGameSessionID == gameSession.id) {
            //print(gameSession);
            if (gameSession.sessionStatus == 'WAITING_FOR_PLAYBACK_FINISH') {
              _startTimer = true;
              _videoEnded = false;
              _updateIndex = false;
              _isAnswered = false;
              _answer = false;
              _waitingForOtherPlayersAnswer = false;
            }
            if (gameSession.sessionStatus == 'WAITING_FOR_ANSWERS') {
              videoPlayerControllers[index]!.removeListener(checkVideo);

              _videoEnded = true;
              countdown = gameSession.timeLeft - 1;
            }
            if (gameSession.sessionStatus == 'DISPLAYING_STATS') {
              _isAnswered = true;
              _isStarted = false;

              if (!_updateIndex) {
                print('UPDATE INDEX: $index');
                index++;
                _updateIndex = !_updateIndex;
              }
            }
            if (gameSession.sessionStatus == 'FINISHED') {
              _ended = true;
              stompClient.deactivate();
              index++; //
            }
            if (this.mounted) setState(() {});
          }
        });
    print(widget.game.id);
    stompClient.send(
        destination: "/joinNewMultiplayerGameSession",
        body: '{"gameId": ${widget.game.id}, "maxNumberOfPlayers": 2}',
        headers: {});
  }

  GameRepository gameRepository = GameRepository();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    for (int i = 0; i < videoPlayerControllers.length; i++) {
      if (index > i) videoPlayerControllers[index]!.dispose();
    }
  }

  @override
  void initState() {
    videoPlayerControllers = {};
    super.initState();
    openConnection();
    _videoEnded = false;
    _isAnswered = false;
    _answerDisplayed = false;
    _isStarted = false;
    _answer = false;
    score = 0;
    index = 0;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: !_startTimer
            ? startTimer()
            : !_videoEnded
                ? videoWidget()
                : (!_isAnswered
                    ? questionWidget(screenHeight, screenWidth)
                    : (!_ended
                        ? resultWidget()
                        : MultiplayerGameFinalScoreScreen(
                            games: widget.games,
                            user: widget.user,
                            score: score,
                            game: gameSession.game,
                            gameSession: gameSession))));
  }

  Widget resultWidget() {
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
        ],
      ),
    );
  }

  Widget questionWithAnswer(double screenHeight, double screenWidth) {
    return _waitingForOtherPlayersAnswer
        ? Center(
            child: Text(
              'Wait for Other Players answer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow),
            ),
          )
        : Column(
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
          widget.game.gameQuestions!.elementAt(index).question!,
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
        alignment: Alignment.topCenter,
        children: [
          questionWithAnswer(screenHeight, screenWidth),
          Padding(
            padding: EdgeInsets.only(top: 60),
            child: Text(
              '$countdown',
              style: TextStyle(fontSize: 45,
                fontWeight: FontWeight.bold
              ),
            ),
          )
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
          if (correctGameSessionID == gameSession.id) {
            GameQuestion currentQuestion =
                widget.game.gameQuestions!.elementAt(index);
            final result = await gameRepository.checkAnswer(
                gameSession,
                currentQuestion,
                currentQuestion.answers!.elementAt(answerNumber));
            _answer = result.correct;
            print('TOTAL POINTS: ${result.totalPoints} SCORE = $score');
            result.totalPoints > score ? _answer = true : _answer = false;
            score = result.totalPoints;
            _waitingForOtherPlayersAnswer = true;
            setState(() {});
          }
        },
        child: Center(
            child: Text(
          widget.game.gameQuestions!
              .elementAt(index)
              .answers!
              .elementAt(answerNumber),
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        )),
      ),
    ));
  }

  Widget videoWidget() {
    return /**_waitingForPlaybackFinish
        ? Center(
        child: Text(
        'WAITING FOR OTHER PLAYERS',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        )
        : **/
        Stack(
      children: [
        Center(
            child: AspectRatio(
          aspectRatio: videoPlayerControllers[index]!.value.aspectRatio,
          child: VideoPlayer(videoPlayerControllers[index]!),
        )),
        !_isStarted
            ? Align(
                alignment: FractionalOffset.bottomCenter,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: StadiumBorder()),
                    onPressed: () {
                      print(index);
                      videoPlayerControllers[index]!.play();
                      print(videoPlayerControllers[index]!.value.duration);
                      videoPlayerControllers[index]!.addListener(checkVideo);
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

  Widget startTimer() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        title: Text(
          "STARTING...",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, VideoPlayerController> getControllers(GameSession gameSession) {
    Map<int, VideoPlayerController> videoControllers = {};
    ClipRepository clipRepository = ClipRepository();
    for (int i = 0; i < widget.game.gameQuestions!.length; i++) {
      clipRepository
          .getClipVideo(widget.game.gameQuestions!.elementAt(i).clip!.clipID!)
          .then((value) {
        VideoPlayerController videoPlayerController =
            VideoPlayerController.network(value.toString())
              ..initialize().then((value) => {setState(() {})})
              ..setVolume(0.1)
              ..seekTo(Duration(seconds: 0));
        videoControllers.addEntries({i: videoPlayerController}.entries);
      });
    }
    print(videoControllers);
    return videoControllers;
  }

  void checkVideo() {
    if (videoPlayerControllers[index]!.value.position ==
        videoPlayerControllers[index]!.value.duration) {
      print('INDEX FOR PLAYER: $index');
      stompClient.send(
          destination: "/playbackFinished",
          body: '${correctGameSessionID}',
          headers: {});
      _waitingForPlaybackFinish = true;
      print("ended");
      setState(() {});
    }
  }
}
