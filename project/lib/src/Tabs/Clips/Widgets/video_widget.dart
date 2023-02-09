// This is the Widget for the videos displayed

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/Models/clip.dart';
import '../../../data/Models/user.dart';
import '../../../data/Repositories/clip_repository.dart';
import '../Screens/comment_screen.dart';

class VideoWidget extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final Clip clip;
  final User user;

  const VideoWidget(
      {Key? key,
      required this.videoPlayerController,
      required this.clip,
      required this.user})
      : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidget();
}

class _VideoWidget extends State<VideoWidget> {
  ClipRepository clipRepository = ClipRepository();
  bool _isPlayed = true;
  bool _isTapped = false;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = false;
    if (widget.user.likedClips != null) {
      for (int i = 0; i < widget.user.likedClips!.length; i++) {
        if (widget.user.likedClips!.elementAt(i).clipID == widget.clip.clipID) {
          _isFavorite = true;
        }
      }
    } else {
      widget.user.likedClips = [];
    }
  }

  Widget video(double screenWidth, double screenHeight, Clip clip) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          clipRepository.toggleLike(clip.clipID).then((value) {
            _isFavorite = false;
            if (value > widget.clip.likes!) {
              if (!widget.user.likedClips!.contains(clip)) {
                widget.user.likedClips!.add(clip);
              }
            } else {
              for (int i = 0; i < widget.user.likedClips!.length; i++) {
                if (widget.user.likedClips!.elementAt(i).clipID ==
                    widget.clip.clipID) {
                  widget.user.likedClips!.removeAt(i);
                }
              }
            }
            for (int i = 0; i < widget.user.likedClips!.length; i++) {
              if (widget.user.likedClips!.elementAt(i).clipID ==
                  widget.clip.clipID) {
                _isFavorite = true;
              }
            }
            widget.clip.likes = value;

            setState(() {});
          });
        },
        onTap: () {
          _isPlayed
              ? widget.videoPlayerController.pause()
              : widget.videoPlayerController.play();
          _isPlayed = !_isPlayed;
          debugPrint(_isPlayed.toString());
          setState(() {});
        },
        child: Stack(
          children: [
            Center(
                child: AspectRatio(
              aspectRatio: widget.videoPlayerController.value.aspectRatio,
              child: VideoPlayer(widget.videoPlayerController),
            )),
            _isPlayed
                ? const Text('')
                : const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: Icon(
                        Icons.play_arrow,
                        size: 50.0,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget iconWithText(
      double screenWidth, double screenHeight, IconData? icon, String txt) {
    return Column(children: [
      InkWell(
        onTap: () {},
        child: Icon(
          icon,
          size: screenWidth / 12,
          color: Colors.white,
        ),
      ),
      SizedBox(height: screenHeight / 130),
      Text(
        txt,
        style: TextStyle(
          fontSize: screenWidth / 30,
          color: Colors.white,
        ),
      )
    ]);
  }

  Widget comment(double screenWidth, double screenHeight) {
    return Comment(
      user: widget.user,
      clipID: widget.clip.clipID,
    );
  }

  Widget like(double screenWidth, double screenHeight, Clip clip) {
    return Column(children: [
      InkWell(
        onTap: () => {
          clipRepository.toggleLike(clip.clipID).then((value) {
            _isFavorite = false;
            if (value > widget.clip.likes!) {
              if (!widget.user.likedClips!.contains(clip)) {
                widget.user.likedClips!.add(clip);
              }
            } else {
              for (int i = 0; i < widget.user.likedClips!.length; i++) {
                if (widget.user.likedClips!.elementAt(i).clipID ==
                    widget.clip.clipID) {
                  widget.user.likedClips!.removeAt(i);
                }
              }
            }
            for (int i = 0; i < widget.user.likedClips!.length; i++) {
              if (widget.user.likedClips!.elementAt(i).clipID ==
                  widget.clip.clipID) {
                _isFavorite = true;
              }
            }

            widget.clip.likes = value;
            setState(() {});
          }),
        },
        child: _isFavorite
            ? Icon(
                Icons.thumb_up_alt,
                size: screenWidth / 12,
                color: Colors.red,
              )
            : Icon(
                Icons.thumb_up_alt,
                size: screenWidth / 12,
                color: Colors.white,
              ),
      ),
      SizedBox(height: screenHeight / 120),
      Text(
        widget.clip.likes!.toString(),
        style: TextStyle(
          fontSize: screenWidth / 30,
          color: Colors.white,
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    //return
    return Stack(
      children: [
        video(screenWidth, screenHeight, widget.clip),
        Column(
          children: [
            SizedBox(
              height: screenHeight / 10,
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: screenWidth / 50,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.clip.title!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth / 6,
                    //links rechts
                    margin: EdgeInsets.only(top: screenWidth / 1.5),
                    //abstand zueinander
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: like(screenWidth, screenHeight, widget.clip),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: comment(screenWidth, screenHeight),
                        ),
                        /**iconWithText(screenWidth, screenHeight,
                            Icons.bookmark_add_outlined, 'Save'),
                            iconWithText(screenWidth, screenHeight,
                            Icons.reply_outlined, 'Share'),**/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _isTapped
            ? Comment(user: widget.user, clipID: widget.clip.clipID)
            : const Text(''),
      ],
    );
  }
}
