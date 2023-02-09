// This is the Screen for uploading Videos

import 'dart:io';

import 'package:blinky_two/src/data/Repositories/clip_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _Add();
}

class _Add extends State<Add> {
  final ImagePicker _picker = ImagePicker();
  bool _uploaded = false;
  final myController = TextEditingController();
  bool emptyText = true;

  String selectval = "-- Please select a category --";
  VideoPlayerController? _controller;
  ClipRepository clipRepository = ClipRepository();
  late XFile? file;

  @override
  Widget build(BuildContext context) {
    return _uploaded ? specifyVideo() : chooseOptions(context);
  }

  void select(ImageSource source) async {
    file = await _picker.pickVideo(source: source);
    if (file != null) {
      _uploaded = true;
      File myFile = File(file!.path);
      _controller = VideoPlayerController.file(myFile)
        ..initialize().then((_) {
          setState(() {});
        });
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
    _controller?.dispose();
  }

  Widget specifyVideo() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
        child: Column(
      children: [
        SizedBox(
          height: screenHeight * 0.12,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            controller: myController,
            onChanged: (text) {
              if (text.isNotEmpty)
                emptyText = false;
              else
                emptyText = true;
              print('CCCCCCCCCCCCCCCCCC');
              print(text);
              print(emptyText);
              setState(() {});
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelText: 'Title',
              hintText: 'Enter your title...',
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.025,
        ),
        SizedBox(
            width: screenWidth * 0.9,
            height: screenHeight * 0.5,
            child:
                //Card(child: Text('Was geht ab')),
                AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: SizedBox(
            height: screenHeight * 0.035,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.03,
        ),
        GestureDetector(
          child: Container(
              height: screenHeight * 0.075,
              width: screenWidth * 0.5,
              decoration: BoxDecoration(
                  border: Border.all(),
                  color: !emptyText ? Colors.blue : Colors.white24,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Center(
                child: Text(
                  "Upload",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: !emptyText ? Colors.white : Colors.white24,
                      decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
              )),
          onTap: () async {
            if (myController.text.isNotEmpty) {
              final bytes = await file!.readAsBytes();
              clipRepository.uploadClip(bytes, myController.text);
            }
            _uploaded = false;
            myController.clear();
            setState(() {});
          },
        ),
      ],
    ));
  }

  Widget chooseOptions(BuildContext context) {
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
                child: singleButton('Camera', 'Film Videos and upload them',
                    FontAwesomeIcons.camera, Colors.orange),
                onTap: () {
                  select(ImageSource.camera);

                  ;
                },
              )),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: GestureDetector(
              child: singleButton('Gallery', 'Upload Videos from your Gallery',
                  FontAwesomeIcons.image, Colors.deepPurple),
              onTap: () {
                select(ImageSource.gallery);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              height: screenHeight * 0.15,
              width: screenWidth * 0.9,
            ),
          )
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
