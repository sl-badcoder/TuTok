// This is the screen to upload a new profile picture

import 'dart:io';
import 'dart:math';
import 'package:blinky_two/src/data/Repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../data/Models/user.dart';

class UploadProfilePic extends StatefulWidget {
  final User user;

  const UploadProfilePic({Key? key, required this.user}) : super(key: key);

  @override
  State<UploadProfilePic> createState() => _UploadProfilePicState();
}

class _UploadProfilePicState extends State<UploadProfilePic> {
  late String picture;
  final ImagePicker _picker = ImagePicker();
  bool _uploaded = false;
  UserRepository userRepository = UserRepository();
  int value = 0;

  Future<void> getProfilePic() async {
    picture =
        "https://blinky.barpec12.pl/user/get/image/${widget.user!.userId!}?v=${Random().nextInt(100)}";
    print('YYYYYYYYYYYYYYYYY');
    print(picture);
  }

  @override
  void initState() {
    // TODO: implement initState
    picture =
        "https://blinky.barpec12.pl/user/get/image/${widget.user!.userId!}";
    getProfilePic();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool uploadPressed = false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            child: CircleAvatar(
              radius: 75,
              backgroundImage: NetworkImage(picture),
            ),
            onLongPress: () {
              setState(() {});
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter test) =>
                            SizedBox(
                                height: screenHeight * 0.2,
                                child: uploadPressed
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            child: singleButton(
                                                'Take a picture',
                                                FontAwesomeIcons.cameraRetro,
                                                Colors.green),
                                            onTap: () async {
                                              XFile? file =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (file != null) {
                                                final bytes =
                                                    await file.readAsBytes();
                                                final img.Image image =
                                                    img.decodeImage(bytes)!;
                                                _uploaded = true;
                                                var pic = File(file.path);
                                                //TODO: Methode aus Backend
                                                await userRepository
                                                    .uploadPicture(pic, bytes,
                                                        widget.user.userId!);
                                                uploadPressed = false;
                                                await getProfilePic();

                                                setState(() {});
                                                test(() {});
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                          InkWell(
                                            child: singleButton(
                                                'Select an image from galery',
                                                FontAwesomeIcons.upload,
                                                Colors.blue),
                                            onTap: () async {
                                              XFile? file =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (file != null) {
                                                final bytes =
                                                    await file.readAsBytes();
                                                _uploaded = true;
                                                var pic = File(file.path);
                                                await userRepository
                                                    .uploadPicture(pic, bytes,
                                                        widget.user.userId!);
                                                uploadPressed = false;
                                                setState(() {});
                                                test(() {});
                                                await getProfilePic();
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (!(picture ==
                                              "https://blinky.barpec12.pl/get/image/830014299267432449"))
                                            InkWell(
                                              child: singleButton(
                                                  'Change your profile picture',
                                                  FontAwesomeIcons
                                                      .stackExchange,
                                                  Colors.blue),
                                              onTap: () {
                                                uploadPressed = true;
                                                test(() {});
                                                setState(() {});
                                              },
                                            ),
                                          if (!(picture ==
                                              "https://blinky.barpec12.pl/get/image/830014299267432449"))
                                            InkWell(
                                              child: singleButton(
                                                  'Delete your profile picture',
                                                  FontAwesomeIcons.deleteLeft,
                                                  Colors.red),
                                              onTap: () async {
                                                await userRepository
                                                    .deletePicture(
                                                        widget.user.userId!);
                                                test(() {});
                                                setState(() {});
                                                await getProfilePic();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          if (picture ==
                                              "https://blinky.barpec12.pl/get/image/830014299267432449")
                                            InkWell(
                                              child: singleButton(
                                                  'Upload a profile picture',
                                                  FontAwesomeIcons.upload,
                                                  Colors.blue),
                                              onTap: () {
                                                uploadPressed = true;
                                                test(() {});
                                                setState(() {});
                                              },
                                            ),
                                        ],
                                      )));
                  });
            }),
      ],
    );
  }

  Widget singleButton(title, icon, color) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight * 0.05,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
          border: Border.all(),
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(
            icon,
            size: 30,
          )
        ],
      ),
    );
  }
}
