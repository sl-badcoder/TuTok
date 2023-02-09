// This is the profile screen

import 'package:blinky_two/src/Tabs/Profile/Screens/upload_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../data/Models/user.dart';
import '../../../data/Repositories/user_repository.dart';

class Profile extends StatefulWidget {
  final User user;
  final int index;

  const Profile({Key? key, required this.user, required this.index})
      : super(key: key);

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  late String userName;
  late int follower;
  late int following;
  late int level;
  late String picture;
  late User user;
  late double progress = 0;
  int i = 0;
  UserRepository userRepository = new UserRepository();
  ImagePicker imagePicker = new ImagePicker();

  List<String> greymedals = [
    "assets/images/graumedal1.png",
    "assets/images/graumedal2.png",
    "assets/images/graumedal3.png",
    "assets/images/graumedal4.png",
    "assets/images/graumedal5.png",
    "assets/images/graumedal6.png",
  ];
  List<String> medals = [
    "assets/images/medal1.png",
    "assets/images/medal2.png",
    "assets/images/medal3.png",
    "assets/images/medal4.png",
    "assets/images/medal5.png",
    "assets/images/medal6.png",
  ];
  int value = 0;

  @override
  void initState() {
    // TODO: implement initState
    user = widget.user;
    picture = "https://blinky.barpec12.pl/user/get/image/${user!.userId!}";
    getCurrentValues(widget.user.username!, user.userId!);
    userName = user.username!;
    i = widget.index;
    follower = user.follower!.length;
    following = user.following!.length;
    level = user.level!;
    super.initState();
  }

  Widget medal(screenHeight, screenWidth, int index) {
    return Container(
      height: screenHeight * 0.1,
      width: screenWidth * 0.4,
      decoration: BoxDecoration(
        color: level >= (index + 1) * 10 ? Colors.purple : Colors.white54,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Container(
        child: Image.asset(
          level >= (index + 1) * 10
              ? "${medals.elementAt(index)}"
              : greymedals.elementAt(index),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    userName = widget.user.username!;
    follower = widget.user.follower!.length;
    following = widget.user.following!.length;
    level = widget.user.level!;
    picture = "https://blinky.barpec12.pl/user/get/image/${widget.user.userId!}";
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.1,
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CircularPercentIndicator(
                radius: 95,
                center: UploadProfilePic(user: user),
                lineWidth: 10,
                percent: progress,
                progressColor: Colors.purple,
                animation: true,
              ),
              Container(
                width: screenWidth * 0.2,
                height: screenHeight * 0.04,
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Center(
                    child: Text(
                  "Level $level",
                  textAlign: TextAlign.center,
                )),
              )
            ],
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          Container(
            width: 200,
            child: Center(
                child: Text(
              userName,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )),
          ),
          SizedBox(
            height: screenHeight * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  alignment: Alignment.center,
                  width: screenWidth / 3,
                  height: 30,
                  child: Text('$follower',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold))),
              Container(
                  alignment: Alignment.center,
                  width: screenWidth / 3,
                  height: 30,
                  child: Text('$following',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold)))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  alignment: Alignment.center,
                  width: screenWidth / 3,
                  height: 30,
                  child: const Text('Follower',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white54,
                          fontWeight: FontWeight.w300))),
              Container(
                  alignment: Alignment.center,
                  width: screenWidth / 3,
                  height: 30,
                  child: const Text('Following',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white54,
                          fontWeight: FontWeight.w300)))
            ],
          ),
          SizedBox(
            height: screenHeight * 0.03,
          ),
          Container(
            width: screenWidth * 0.9,
            child: Text(
              "Achievements",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            //color: Colors.lightGreenAccent,
            height: screenHeight * 0.035,
          ),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Wrap(
              runSpacing: screenHeight * 0.03,
              direction: Axis.horizontal,
              spacing: screenWidth * 0.1,
              children: [
                for (int i = 0; i < medals.length; i++)
                  medal(screenHeight, screenWidth, i)
              ],
            ),
          )),
        ],
      ),
    )));
  }

  Future<void> getCurrentValues(String username, int userID) async {
    UserRepository userRepository = new UserRepository();
    userRepository.getUser(username).then((value) => {
          user = value,
          setState(() {}),
        });
    userRepository.getProgress(userID).then((value) => {
          print(value),
          progress = value.toDouble(),
        });
  }
}
