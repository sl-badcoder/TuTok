// This is the class for Clip Screen

import 'package:blinky_two/src/data/Repositories/clip_repository.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/Models/clip.dart';
import '../../../data/Models/user.dart';
import '../Widgets/video_widget.dart';

class Clips extends StatefulWidget {
  final List<VideoWidget> widgets;
  final User user;
  final PageController pageController;
  final int index;
  final ValueChanged<int> update;

  const Clips(
      {Key? key,
      required this.widgets,
      required this.user,
      required this.pageController,
      required this.index,
      required this.update})
      : super(key: key);

  @override
  State<Clips> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<Clips> {
  late PageController _pageController;
  List<VideoWidget> widgets = [];
  bool _scrolledThree = true;
  VideoPlayerController? _videoPlayerController;
  bool _loading = false;
  int initialpage = 0;

  @override
  initState() {
    _pageController = widget.pageController;
    initialpage = widget.index;
    widgets = widget.widgets;
    if (widgets.isNotEmpty) {
      widgets[_pageController.initialPage].videoPlayerController.play();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: (int index) async {
          widget.update(index % widgets.length);
          initialpage = index;
          print('${(index % widgets.length)}');
          if (index > 0 && (index % widgets.length)!= 0) {
            print('I PAUSE');
            widgets[index % widgets.length- 1].videoPlayerController.pause();
            widgets[index % widgets.length- 1].videoPlayerController.seekTo(
                widgets[index % widgets.length- 1].videoPlayerController.value.position -
                    widgets[index % widgets.length- 1].videoPlayerController.value.position);
          }
          if((index % widgets.length)== 0){
            widgets[widgets.length- 1].videoPlayerController.pause();
            widgets[widgets.length- 1].videoPlayerController.seekTo(
                widgets[widgets.length- 1].videoPlayerController.value.position -
                    widgets[widgets.length- 1].videoPlayerController.value.position);
          }
          widgets[index % widgets.length].videoPlayerController.play();
          if ((index % widgets.length)+ 1 < widgets.length) {
            widgets[index % widgets.length+ 1].videoPlayerController.pause();
            widgets[index % widgets.length+ 1].videoPlayerController.seekTo(
                widgets[index % widgets.length+ 1].videoPlayerController.value.position -
                    widgets[index % widgets.length + 1].videoPlayerController.value.position);
          };
          if ((index == 2)) {
            final returnedWidgets = await getClips(widget.user);
            widgets = widgets..addAll(returnedWidgets);
            setState(() {});
          }
        },
        itemBuilder: (context, index) {
          return SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Center(
              child: Stack(
                children: [
                  widgets[index % widgets.length],
                  _loading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          height: 0,
                          width: 0,
                        )
                ],
              ),
            ),
          );
        });
  }

  int i = 0;

  void _threePageListener() {
    if (i < 3) {
      i++;
    } else if (i == 3) {
      i = 0;
      setState(() {
        _scrolledThree = true;
      });
    }
  }

  Future<List<VideoWidget>> getClips(User user) async {
    List<VideoWidget> videoWidgets = [];
    final clipRepository = ClipRepository();
    final clips = await clipRepository.getClips(2);
    for (Clip clip in clips) {
      await clipRepository.getClipVideo(clip.clipID).then((value) async {
        _videoPlayerController = VideoPlayerController.network(value.toString())
          ..initialize().then((value) => {
                setState(() {}),
              })
          ..setLooping(true)
          ..setVolume(0.1);
        videoWidgets.add(VideoWidget(
          videoPlayerController: _videoPlayerController!,
          clip: clip,
          user: user,
        ));
      });
    }
    return videoWidgets;
  }
}
