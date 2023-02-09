// This is the Screen for Leaderboard

import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/Models/user.dart';

class LeaderBoard extends StatefulWidget {
  final User user;

  const LeaderBoard({Key? key, required this.user}) : super(key: key);

  @override
  State<LeaderBoard> createState() => _LeaderBoard();
}

class _LeaderBoard extends State<LeaderBoard> {
  List<User> users = [];
  bool _loaded = false;

  @override
  initState() {
    super.initState();
    getLeaderBoard(50);
  }

  Widget listContainer(User user, int index) {
    var picture = "https://blinky.barpec12.pl/user/get/image/${user.userId!}";
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.05,
            ),
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
                    "Level ${user.level}",
                    textAlign: TextAlign.center,
                  )),
                )
              ],
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              '${user.username}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              '${index + 1}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: screenWidth * 0.1,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'TOP 50',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.yellow),
          ),
        ),
        body: _loaded
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.08,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              topThree(users.elementAt(1), 2, 60.0),
                              topThree(users.elementAt(2), 3, 60.0),
                            ],
                          ),
                        ],
                      ),
                      topThree(users.elementAt(0), 1, 80.0),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          if (index < 3) return SizedBox();
                          return Padding(
                              padding: EdgeInsets.only(top: 10),
                              child:
                                  listContainer(users.elementAt(index), index));
                        }),
                  ),
                ],
              )
            : Center(
                child: Container(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(color: Colors.yellow,))));
  }

  Widget topThree(user, index, radius) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    var picture = "https://blinky.barpec12.pl/user/get/image/${user!.userId!}";
    return Column(children: [
      Text(
        "$index",
        style: TextStyle(
            fontSize: index == 1 ? 30 : 25, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: screenHeight * 0.015,
      ),
      Icon(
        FontAwesomeIcons.crown,
        color: index == 1
            ? Colors.yellow
            : index == 2
                ? Colors.grey
                : Colors.brown,
        size: index == 1 ? 40 : 30,
      ),
      Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(picture),
          ),
          Container(
            width: screenWidth * 0.18,
            height: screenHeight * 0.03,
            decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Center(
                child: Text(
              "Level ${user.level}",
              textAlign: TextAlign.center,
            )),
          )
        ],
      ),
      SizedBox(
        height: screenHeight * 0.015,
      ),
      Text(
        '${user.username}',
        style: TextStyle(fontSize: 20),
      ),
    ]);
  }

  Future<List<User>> getLeaderBoard(int n) async {
    GameRepository gameRepository = new GameRepository();
    List<User> retUser = [];
    gameRepository.getLeaderboard(n).then((value) => {
          users = value,
          setState(() {}),
          retUser = value,
          _loaded = true,
        });

    return retUser;
  }
}
