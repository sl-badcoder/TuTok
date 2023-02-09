// This is the screen to follow/unfollow users

import 'package:flutter/material.dart';

import '../../../data/Models/user.dart';
import '../../../data/Repositories/user_repository.dart';

class Search extends StatefulWidget {
  final User user;

  const Search({Key? key, required this.user}) : super(key: key);

  @override
  State<Search> createState() => _Search();
}

class _Search extends State<Search> {
  final _controller = TextEditingController();
  UserRepository userRepository = new UserRepository();

  late List<User> users = [];
  late String follow = "";

  @override
  void initState() {
    _controller.addListener(search);
    super.initState();
  }

  Widget namefollow(User user) {
    var picture = "http://blinky.barpec12.pl/user/get/image/${user.userId!}";
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (widget.user.following!.contains(user.userId)) {
      follow = "unfollow";
    } else {
      follow = "follow";
    }
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
            GestureDetector(
              child: Container(
                height: screenHeight * 0.05,
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                    child: Text(
                  follow,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                )),
              ),
              onTap: () {
                if (widget.user.following!.contains(user.userId)) {
                  setState(() {
                    follow = "unfollow";
                  });
                  userRepository.unfollow(user.userId!);
                  getCurrentValues(widget.user.username!);
                  //widget.user.following!.remove(user.userId!);
                } else {
                  setState(() {
                    follow = "follow";
                  });
                  userRepository.follow(user.userId!);
                  getCurrentValues(widget.user.username!);
                  //widget.user.following!.add(user.userId!);
                }
              },
            ),
            SizedBox(
              width: screenWidth * 0.1,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Container(
            width: 500,
            height: 70,
            decoration: BoxDecoration(
                //color: Colors.grey,
                //borderRadius: BorderRadius.circular(20)
                ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_sharp),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _controller.clear,
                  ),
                  hintText: 'Search...',
                  hintStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: Padding(
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var result = users[index];
            return namefollow(result);
          },
        ),
        padding: EdgeInsets.only(top: 15),
      ),
    );
  }

  Future<void> search() async {
    UserRepository userRepository = new UserRepository();
    await userRepository.search(_controller.value.text).then((value) => {
          users = value,
        });
    setState(() {});
  }

  Future<void> getCurrentValues(String username) async {
    UserRepository userRepository = new UserRepository();
    userRepository.getUser(username).then((value) => {
          widget.user.username = value.username,
          widget.user.email = value.email,
          widget.user.level = value.level,
          widget.user.following = value.following,
          widget.user.follower = value.follower,
          setState(() {}),
        });
  }
}
