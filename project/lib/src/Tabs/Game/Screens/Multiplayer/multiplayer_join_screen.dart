// This is the screen to join new games

import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinky_two/src/data/Models/game_session.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:blinky_two/src/data/Repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/Models/game.dart';
import '../../../../data/Models/game_question.dart';
import '../../../../data/Models/user.dart';
import '../../../../data/Repositories/clip_repository.dart';
import '../../../../data/Services/api_service.dart';
import 'multiplayer_final_score_screen.dart';

class JoinMultiplayer extends StatefulWidget {
  final User user;
  final List<Game> games;

  JoinMultiplayer({super.key, required this.user, required this.games});

  @override
  State<JoinMultiplayer> createState() => _JoinMultiplayer();
}

class _JoinMultiplayer extends State<JoinMultiplayer> {
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
  String value = 'Waiting for Start...';
  bool _waitingForPlaybackFinish = false;
  Map<int, VideoPlayerController> videoPlayerControllers = {};
  late GameSession gameSession;
  late int correctGameSessionID;
  int _getControl = 0;
  late int gameSessionId;
  List<GameSession> games = [];
  String ws_url = "wss://blinky.barpec12.pl/websocket";
  Future<WebSocket>? connection;
  bool _join = false;
  bool _loaded = false;
  late GameSession correctgameSession;
  List<Color> colorizeColors = [
    Colors.yellow,
    Colors.yellow[600]!,
    Colors.yellow[700]!,
    Colors.yellow[800]!,
  ];

  //
  UserRepository userRepository = UserRepository();
  List<User> userListe = [];

  //
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
    stompClient.send(
        destination: "/joinMultiplayerGameSession",
        body: '${gameSessionId}',
        headers: {});
  }

  @override
  void initState() {
    getGameSessions();
    super.initState();
    _join = false;
    _videoEnded = false;
    _isAnswered = false;
    _answerDisplayed = false;
    _isStarted = false;
    _answer = false;
    score = 0;
    index = 0;
    videoPlayerControllers = {};
  }

  GameRepository gameRepository = GameRepository();

  @override
  void dispose() {
    super.dispose();
    for (int i = 0; i < videoPlayerControllers.length; i++) {
      if (index > i) videoPlayerControllers[index]!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return _loaded
        ? (_join
            ? Scaffold(
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
                                    gameSession: gameSession))))
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0x00000000),
                  elevation: 0,
                  /*title: Center(child: Text(
                    'JOIN GAME',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),*/
                ),
                body: games.length == 0
                    ? Container(
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Icon(
                                FontAwesomeIcons.solidFaceSadTear,
                                size: 90,
                                color: Colors.purple,
                              ),
                              SizedBox(
                                height: screenHeight * 0.08,
                              ),
                              Text(
                                "There aren't any open games",
                                style: TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple),
                                textAlign: TextAlign.center,
                              ),
                            ])),
                      )
                    : Column(
                        children: <Widget>[
                          Container(
                            height: screenHeight * 0.1,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.05,
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.purple,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Text(
                                      'CREATOR',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                SizedBox(
                                  width: screenWidth * 0.05,
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 50,
                                      color: Colors.purple,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Text(
                                      'GAME',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.peopleGroup,
                                      size: 50,
                                      color: Colors.purple,
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Text(
                                      'PRESS TO JOIN',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: screenWidth * 0.05,
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: listOfGameSessions())
                        ],
                      )))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0x00000000),
              elevation: 0,
            ),
            body: Center(
                child: Container(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                    ))));
  }

  Widget listOfGameSessions() {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        var result = games[index];
        return Padding(
            padding: EdgeInsets.only(top: 15),
            child: oneGameSession(result, index));
      },
    );
  }

  Widget oneGameSession(GameSession gameSession, index) {
    User user = userListe[index];
    var picture = "https://blinky.barpec12.pl/user/get/image/${user!.userId!}";
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: screenHeight * 0.12,
        decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(picture),
                    ),
                    Container(
                      width: screenWidth * 0.14,
                      height: screenHeight * 0.02,
                      decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Center(
                          child: Text(
                        "Level ${user?.level}",
                        textAlign: TextAlign.center,
                      )),
                    )
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.005,
                ),
                Text(
                  '${user!.username}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Spacer(),
            Text(
              '${gameSession.game.title}',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                gameSessionId = gameSession.id;
                openConnection();
                _join = true;
              },
              child: Text('JOIN'),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
          ],
        ));
  }

  Future<void> getGameSessions() async {
    GameRepository gameRepository = GameRepository();
    List<GameSession> gameSessions = [];
    await gameRepository.openedMultiplayerSessions().then((value) {
      games = value;
      for (int i = 0; i < games.length; i++) {
        getFirstUsers(games[i].currentUsers.elementAt(0));
      }
      if (games.length == 0) {
        _loaded = true;
      }
      setState(() {});
    });
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
          gameSession.game.gameQuestions!.elementAt(index).question!,
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
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '$countdown',
              style: TextStyle(fontSize: 30),
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
                gameSession.game.gameQuestions!.elementAt(index);
            final result = await gameRepository.checkAnswer(
                gameSession,
                currentQuestion,
                currentQuestion.answers!.elementAt(answerNumber));
            _answer = result.correct;
            score = result.totalPoints;
            _waitingForOtherPlayersAnswer = true;
            setState(() {});
          }
        },
        child: Center(
            child: Text(
          gameSession.game.gameQuestions!
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
                      videoPlayerControllers[index]!.play();
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
    for (int i = 0; i < gameSession.game.gameQuestions!.length; i++) {
      clipRepository
          .getClipVideo(
              gameSession.game.gameQuestions!.elementAt(i).clip!.clipID!)
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

  Future<void> getFirstUsers(String username) async {
    UserRepository userRepository = new UserRepository();
    userRepository.getUser(username).then((value) => {
          userListe.add(value),
          if (userListe.length == games.length)
            {
              _loaded = true,
            },
          setState(() {})
        });
  }
}
