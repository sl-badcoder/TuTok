// This is the start screen here you can either select singleplayer/multiplayer
// game or the leaderboard

import 'package:blinky_two/src/Tabs/Game/Screens/LeaderBoard/leaderboard_screen.dart';
import 'package:blinky_two/src/Tabs/Game/Screens/Multiplayer/multiplayer_start_screen.dart';
import 'package:blinky_two/src/Tabs/Game/Screens/SinglePlayer/singleplayer_menu_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../data/Models/game.dart';
import '../../../data/Models/user.dart';

class StartScreen extends StatefulWidget {
  final User user;
  final List<Game> games;

  const StartScreen({Key? key, required this.user, required this.games})
      : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Image.asset(
                "assets/images/logo_transparent.png",
                height: 250,
              )),
          Padding(
              padding: EdgeInsets.only(top: 1),
              child: GestureDetector(
                child: singleButton('Single Player', 'Play a game alone',
                    FontAwesomeIcons.userAstronaut, Colors.blue),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GameMenuScreen(
                          user: widget.user, games: widget.games)));
                },
              )),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: GestureDetector(
              child: singleButton(
                  'Multiple Player',
                  'Play a game with another person',
                  FontAwesomeIcons.userGroup,
                  Colors.red),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MultiplayerMenu(
                          user: widget.user,
                          games: widget.games,
                        )));
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: singleButton('Leaderboard', 'See the best players',
                    FontAwesomeIcons.rankingStar, Colors.green),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LeaderBoard(user: widget.user)));
                },
              ))
        ],
      ),
    );
  }

  Widget singleButton(title, description, icon, color) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight * 0.15,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
          border: Border.all(),
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      //color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(description),
              )
            ],
          ),
          Icon(
            icon,
            size: 70,
          )
        ],
      ),
    );
  }
}
