// This is the page where you can select your preferences

import 'package:blinky_two/src/Tabs/Main/Screens/main_screen.dart';
import 'package:blinky_two/src/data/Repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/Models/clip.dart';
import '../../../data/Models/user.dart';
import '../../../data/Repositories/clip_repository.dart';
import '../../Clips/Widgets/video_widget.dart';

class InterestsPage extends StatefulWidget {
  final User user;

  const InterestsPage({super.key, required this.user});

  @override
  State<InterestsPage> createState() => _InterestsPage();
}

class _InterestsPage extends State<InterestsPage> {
  VideoPlayerController? _videoPlayerController;
  List<VideoWidget> widgets = [];

  UserRepository userRepository = UserRepository();

  bool _isWaitingForHome = false;

  final List<bool> _selected1 = <bool>[false, false, false, false];
  final List<bool> _selected2 = <bool>[false, false, false, false];
  final List<bool> _selected3 = <bool>[false, false, false, false];
  final List<bool> _selected4 = <bool>[false, false, false, false];
  int _counter = 0;

  List<String> _result = [];

  List<String> topicsRowOne = ['Football', 'Sport', 'Cooking', 'Memes'];
  List<String> topicsRowTwo = ['Gaming', 'DIY', 'Dancing', 'Anime'];
  List<String> topicsRowThree = ['Travel', 'Beauty', 'Fashion', 'Movies'];
  List<String> topicsRowFour = ['Science', 'Music', 'Vlogs', 'Cars'];

  Widget topicRow(double screenHeight, double screenWidth, List<String> topics,
      List<bool> _selected) {
    return ToggleButtons(
          onPressed: (int index) {
            if (_selected[index]) {
              _counter--;
              debugPrint('$_counter');
              _result.remove(topics[index]);
            } else {
              _counter++;
              debugPrint('$_counter');
              _result.add(topics[index]);
            }
            setState(() {
              _selected[index] = !_selected[index];
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          selectedBorderColor: Colors.blue,
          selectedColor: Colors.white,
          fillColor: Colors.blue,
          color: Colors.white,
          constraints: BoxConstraints(
            minHeight: screenHeight / 15,
            minWidth: screenWidth / 4.5,
          ),
          isSelected: _selected,
          children: <Widget>[
            Text(topics.elementAt(0)),
            Text(topics.elementAt(1)),
            Text(topics.elementAt(2)),
            Text(topics.elementAt(3)),
          ],
        );
  }

  //TODO: IMPLEMENT LOADING CLIPS LOGIC

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color(0x00000000),
          elevation: 0,
          title: const Text(
            'TuTok',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        body: Container(
          color: Color(0x00000000),
          child: Column(mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Padding(
                padding: EdgeInsets.only(left: 30),
                child: const Text(
                  'Choose your interests',
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none),
                )),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            Padding(
              padding: EdgeInsets.only(left: 0),
              child: const Text(
                'Get better game recommendations',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    decoration: TextDecoration.none),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            topicRow(screenHeight, screenWidth, topicsRowOne, _selected1),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            topicRow(screenHeight, screenWidth, topicsRowTwo, _selected2),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            topicRow(screenHeight, screenWidth, topicsRowThree, _selected3),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            topicRow(screenHeight, screenWidth, topicsRowFour, _selected4),
            SizedBox(
              height: screenHeight * 0.1,
            ),
            _isWaitingForHome
                ? Container(
                    height: screenHeight * 0.075,
                    width: screenWidth * 0.5,
                    child: Center(child: const CircularProgressIndicator()))
                : GestureDetector(
                    child: Container(
                        height: screenHeight * 0.075,
                        width: screenWidth * 0.5,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            color:
                                (_counter > 0) ? Colors.blue : Colors.white24,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: (_counter > 0)
                                    ? Colors.white
                                    : Colors.white24,
                                decoration: TextDecoration.none),
                            textAlign: TextAlign.center,
                          ),
                        )),
                    onTap: () {
                      if (_counter > 0) {
                        setState(() {
                          _isWaitingForHome = true;
                        });
                        User user = widget.user;
                        user.likedClips = [];
                        main(context, () {
                          if (!mounted) return;
                          userRepository.setCategories(
                              widget.user!.userId!, _result);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(
                                widgets: widgets,
                                user: user,
                              ),
                            ),
                          );
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Message from TuTok'),
                            content:
                                const Text('Please select at least one topic'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Go Back'))
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ]),
        ));
  }

  void main(BuildContext context, VoidCallback onSuccess) async {
    final returnedWidgets = await getClips(widget.user);
    widgets = returnedWidgets;
    if (widgets.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      _isWaitingForHome = false;
      onSuccess.call();
    }
  }

  Future<List<VideoWidget>> getClips(User user) async {
    List<VideoWidget> videoWidgets = [];
    final clipRepository = ClipRepository();
    final clips = await clipRepository.getClips(5);
    print("Clips Länge: ${clips.length}");
    if (mounted) {
    }

    for (Clip clip in clips) {
      await clipRepository.getClipVideo(clip.clipID).then((value) async {
        _videoPlayerController = VideoPlayerController.network(value.toString())
          ..initialize().then((value) => {
                setState(() {}),
              })
          ..setLooping(true)
          ..setVolume(0.1);

        if (clip.clipID != 202) {
          videoWidgets.add(VideoWidget(
            videoPlayerController: _videoPlayerController!,
            clip: clip,
            user: user,
          ));
        }
      });
    }
    return videoWidgets;
  }
}
