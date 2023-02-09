// This is the login screen where you can put in your username and password

import 'package:blinky_two/src/Tabs/Clips/Widgets/video_widget.dart';
import 'package:blinky_two/src/data/Repositories/clip_repository.dart';
import 'package:blinky_two/src/data/Repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../../../data/Models/clip.dart';
import '../../../data/Models/user.dart';
import '../../Main/Screens/main_screen.dart';
import 'register_screen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

bool isValid = false;
bool isValidTwo = false;
bool isLoggedIn = false;

class _Login extends State<Login> {
  bool _isWaitingForLogin = false;
  List<VideoWidget> widgets = [];
  VideoPlayerController? _videoPlayerController;
  late User user;

  final UserRepository userRepository = UserRepository();
  final usernameText = TextEditingController();
  final passwordText = TextEditingController();

  String username = "";
  String password = "";

  void clearText() {
    usernameText.clear();
    passwordText.clear();
  }

  void main(BuildContext context, VoidCallback onSuccess) async {
    userRepository.login(username, password).onError((error, stackTrace) {
      isValidTwo = false;
      return new User(username: '', email: '');
    }).then((value) async {
      if (!(value.username == null && value.email == null)) {
        setState(() {
          isValidTwo = false;
          _isWaitingForLogin = true;
          user = value;
        });

        int time = DateTime.now().millisecondsSinceEpoch;
        const int minimalSpeedInMbps = 5;
        const int fileSize = 8; //1MB = 8Mbit (disk vs internet size unit)
        await http
            .get(Uri.parse("https://proof.ovh.net/files/1Mb.dat"))
            .timeout(Duration(seconds: fileSize ~/ minimalSpeedInMbps))
            .catchError((err) {
          time = 0;
          return http.Response("TIMEOUT", 408);
        });
        if (time != 0) {
          int timePassed = DateTime.now().millisecondsSinceEpoch - time;
          int speed = (8000 / timePassed).round(); //speed in Mbs
          if (speed < minimalSpeedInMbps) ClipRepository.quality = "LOW";
          print("speed: $speed");
        } else
          ClipRepository.quality = "LOW";

        final returnedWidgets = await getClips(user);
        widgets = returnedWidgets;
        if (widgets.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          isLoggedIn = true;
          _isWaitingForLogin = false;
          onSuccess.call();
        }
      } else {
        setState(() {
          isValidTwo = true;
        });
      }
      clearText();
    });
  }

  Widget wrongUsernamePassword(double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "username or password is wrong",
          style: TextStyle(color: Colors.red),
        )
      ],
    );
  }

  Widget signUpButton(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () {
          main(context, () {
            if (!mounted) return;
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
        },
        child: Container(
          width: screenWidth * 0.83,
          height: screenHeight * 0.072,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: Center(
              child: Text(
            'Login',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white60),
            textAlign: TextAlign.center,
          )),
        ));
  }

  Widget inputField(String hint, TextEditingController controller) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.83,
      height: screenHeight * 0.085,
      child: TextField(
        onChanged: (newText) {
          hint == 'Username' ? username = newText : password = newText;
        },
        controller: controller,
        obscureText: hint == 'Password' ? true : false,
        key: hint == 'Username'
            ? Key('Sign_in_Username')
            : Key('Sign_in_Password'),
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: Colors.black, width: 0.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: Colors.black, width: 0.0),
            ),
            filled: true,
            hintStyle: TextStyle(color: Colors.white10),
            hintText: hint,
            fillColor: Colors.black12),
      ),
    );
  }

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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * 0.05,
            ),
            inputField('Username', usernameText),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            inputField('Password', passwordText),
            _isWaitingForLogin
                ? Container(
                    width: screenWidth * 0.83,
                    height: screenHeight * 0.072,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ))
                : signUpButton(context),
            isValidTwo
                ? wrongUsernamePassword(screenHeight, screenWidth)
                : const Text(""),
            Container(
              height: screenHeight * 0.45,
              child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Image.asset(
                    "assets/images/logo_transparent.png",
                    height: 400,
                  )),
            ),
            Expanded(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text(
                  'New Here?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Register()));
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900]),
                  ),
                ),
              ]),
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<VideoWidget>> getClips(User user) async {
    List<VideoWidget> videoWidgets = [];
    final clipRepository = ClipRepository();
    final clips = await clipRepository.getClips(5);
    if (mounted) {
      setState(() {

      });
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
