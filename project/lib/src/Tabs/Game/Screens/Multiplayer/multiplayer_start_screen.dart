// This is the start screen of multiplayer here you can select wether you want
// join a game or create one

import 'package:blinky_two/src/Tabs/Game/Screens/Multiplayer/multiplayer_join_screen.dart';
import 'package:flutter/material.dart';

import '../../../../data/Models/game.dart';
import '../../../../data/Models/user.dart';
import 'multiplayer_select_screen.dart';

class MultiplayerMenu extends StatefulWidget {
  final User user;
  final List<Game> games;

  MultiplayerMenu({super.key, required this.user, required this.games});

  @override
  State<MultiplayerMenu> createState() => _MultiplayerMenu();
}

class _MultiplayerMenu extends State<MultiplayerMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createGame(),
            joinGame(),
          ],
        ),
      )),
    );
  }

  Widget createGame() {
    return Padding(
        padding: EdgeInsets.only(top: 1),
        child: GestureDetector(
          child: singleButton('Create Game', 'Create a new Game Session',
              Icons.add, Colors.black),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MultiPlayerSelectScreen(
                      user: widget.user,
                      games: widget.games!,
                    )));
          },
        ));
  }

  Widget joinGame() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: GestureDetector(
        child: singleButton(
            'Join Game', 'Join a Game Session', Icons.login, Colors.pink),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => JoinMultiplayer(
                    user: widget.user,
                    games: widget.games,
                  )));
        },
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
