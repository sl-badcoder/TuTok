// This is the singleplayer menu screen here you can select which game you want to play

import 'package:blinky_two/src/Tabs/Game/Screens/SinglePlayer/singleplayer_start_screen.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:flutter/material.dart';

import '../../../../data/Models/game.dart';
import '../../../../data/Models/user.dart';

class GameMenuScreen extends StatefulWidget {
  final User user;
  final List<Game> games;

  const GameMenuScreen({Key? key, required this.user, required this.games})
      : super(key: key);

  @override
  State<GameMenuScreen> createState() => _GameMenuScreen();
}

class _GameMenuScreen extends State<GameMenuScreen>
    with SingleTickerProviderStateMixin {
  GameRepository gameRepository = GameRepository();
  List<Game> mygames = [];
  late AnimationController controller;
  late Animation colorAnimation;
  late Animation sizeAnimation;
  late List<GlobalKey> globals = [];
  late Size size = new Size(0, 0);
  late double xAxis = 0;
  late double yAxis = 0;
  late bool isStarted = false;

  late bool _isSelected;
  int selectedGame = 0;

  @override
  void initState() {
    super.initState();
    gameRepository.getGames().then((value) => {
          for (Game game in value)
            {
              mygames.add(game),
            }
        });
    _isSelected = false;
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    bool isStarted = false;
    // Defining both color and size animations
    colorAnimation =
        ColorTween(begin: Colors.orange[500], end: Colors.orange[800])
            .animate(controller);
    sizeAnimation = Tween<double>(begin: 80.0, end: 150.0).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
    for (int i = 0; i < widget.games.length; i++) {
      globals.add(new GlobalKey());
    }
  }

  Widget startGame() {
    return SizedBox(
        child: Center(
      child: ElevatedButton(
        child: const Text(
          "START GAME",
          style: TextStyle(fontSize: 18),
        ),
        onPressed: () {
          isStarted = true;
          setState(() {});
        },
      ),
    ));
  }

  void _getWidgetInfo() {
    final RenderBox renderBox = globals
        .elementAt(selectedGame)
        .currentContext
        ?.findRenderObject() as RenderBox;

    size = renderBox.size;
    print('Size: ${size.width}, ${size.height}');

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    print('Offset: ${offset.dx}, ${offset.dy}');
    print(
        'Position: ${(offset.dx + size.width) / 2}, ${(offset.dy + size.height) / 2}');
    xAxis = offset.dx;
    print(xAxis);
    yAxis = offset.dy;
  }

  Widget gameWidget(int i, Game game, double screenHeight, double screenWidth) {
    return Container(
      key: globals.elementAt(i),
      height: sizeAnimation.value,
      width: sizeAnimation.value,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black26,
          ),
          color: Colors.blue, //colorAnimation.value,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              if (sizeAnimation.isCompleted) {
                selectedGame = i;
                _getWidgetInfo();
                _isSelected = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameStartScreen(
                      user: widget.user,
                      game: widget.games.elementAt(selectedGame),
                      games: widget.games,
                      xAxis: xAxis,
                      yAxis: yAxis,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      size: size,
                    ),
                  ),
                );
              }
            });
          },
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                game.title!,
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height; //
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        title: Text(
          "SELECT THE GAME",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        //color: Colors.orangeAccent,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < widget.games.length; i++)
                        gameWidget(i, widget.games.elementAt(i), screenHeight,
                            screenWidth)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ); //
  }
}
