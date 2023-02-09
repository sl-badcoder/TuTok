// This is the main page for the changing between tabs

import 'package:blinky_two/src/Tabs/Clips/Screens/clip_screen.dart';
import 'package:blinky_two/src/Tabs/Clips/Widgets/video_widget.dart';
import 'package:blinky_two/src/Tabs/Profile/Screens/search_screen.dart';
import 'package:blinky_two/src/Tabs/Profile/Screens/profile_screen.dart';
import 'package:blinky_two/src/data/Repositories/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../data/Models/game.dart';
import '../../../data/Models/user.dart';
import '../../../data/Repositories/clip_repository.dart';
import '../../../data/Repositories/user_repository.dart';
import '../../Clips/Screens/add_screen.dart';
import '../../Game/Screens/start_screen.dart';
import '../../LogReg/Screens/login_screen.dart';

class Home extends StatefulWidget {
  final List<VideoWidget> widgets;
  final User user;

  const Home({Key? key, required this.widgets, required this.user})
      : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  ClipRepository clipRepository = ClipRepository();
  GameRepository gameRepository = GameRepository();
  VideoPlayerController? _videoPlayerController;
  PageController? _pageController;
  List<Game> games = [];
  late User user;
  int i = 0;
  bool changedMultipleTimes = false;
  int initialpage = 0;

  @override
  initState() {
    super.initState();
    user = widget.user;
    _pageController = PageController(initialPage: 0);
    gameRepository.getGames().then((value) => {
          for (Game game in value) {games.add(game)}
        });
    //widgets.add(video_widget(videoPlayerController: _videoPlayerController!, clip: e));
  }

  int _selectedIndex = 0;

  void pauseallwidgets() {
    for (int i = 0; i < widget.widgets.length; i++) {
      widget.widgets[i].videoPlayerController.pause();
    }
  }

  int getIndex() {
    int index = 0;
    for (int i = 0; i < widget.widgets.length; i++) {
      if (widget.widgets[i].videoPlayerController.value.isPlaying) {
        index = i;
      }
    }
    return index;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      getCurrentValues(user.username!);
    });
    if (_selectedIndex != 0) {
      if (!changedMultipleTimes) {
        _pageController = PageController(initialPage: initialpage);
        changedMultipleTimes = true;
      }
      pauseallwidgets();
    }
    if (_selectedIndex == 0) {
      changedMultipleTimes = false;
      print("INDEX: $index");
    }
  }

  void _update(int test) {
    setState(() {
      initialpage = test;
      print("update: $initialpage");
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        title: const Text(
          'TuTok',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        actions: <Widget>[
          _selectedIndex == 3
              ? IconButton(
                  onPressed: () async {
                    pauseallwidgets();
                    final ix = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Search(user: user)))
                        .then((value) {
                      setState(() {});
                    });
                    if (!mounted) return;
                    setState(() {
                      print("i: " + ix.toString());
                      i = 0;
                    });
                  },
                  icon: const Icon(Icons.add_reaction))
              : SizedBox(
                  height: 0,
                  width: 0,
                ),
          _selectedIndex == 3
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('no')),
                          ElevatedButton(
                              onPressed: () {
                                pauseallwidgets();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const Login()),
                                    (Route<dynamic> route) => false);
                              },
                              child: const Text('yes')),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout))
              : SizedBox(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
      body: _selectedIndex == 0
          ? Clips(
              widgets: widget.widgets,
              user: widget.user,
              pageController: _pageController!,
              index: initialpage,
              update: _update,
            )
          : _selectedIndex == 1
              ? StartScreen(
                  user: user,
                  games: games,
                )
              : _selectedIndex == 2
                  ? const Add()
                  : Profile(
                      user: user,
                      index: i,
                    ),
      bottomNavigationBar: SizedBox(
        height: screenHeight / 8,
        child: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: screenHeight / 25),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.gamepad,
                size: screenHeight / 25,
              ),
              label: 'Game',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.upload,
                size: screenHeight / 25,
              ),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.userLarge,
                size: screenHeight / 25,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<void> getCurrentValues(String username) async {
    UserRepository userRepository = new UserRepository();
    userRepository.getUser(username).then((value) => {
          user = value,
          setState(() {}),
        });
  }
}
