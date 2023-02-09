// This is the page to register a new account

import 'package:blinky_two/src/data/Repositories/user_repository.dart';
import 'package:flutter/material.dart';

import '../../../data/Models/user.dart';
import 'interests_page_screen.dart';
import 'login_screen.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _Register();
}

bool isinvalidinput = false;

class _Register extends State<Register> {
  late User user;

  bool validatePassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{9,16}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validateUserName(String value) {
    return value.length >= 3;
  }

  bool validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  final UserRepository userRepository = UserRepository();
  final usernameText = TextEditingController();
  final passwordText = TextEditingController();
  final emailText = TextEditingController();

  String userName = '';
  String password = '';
  String email = '';

  void clearText() {
    passwordText.clear();
    usernameText.clear();
    emailText.clear();
  }

  void main() async {
    user = User(username: userName, email: email, password: password);
    userRepository.createUser(user).then((value) => {
          debugPrint(value),
          userRepository.login(userName, password).then((value) {
            if (!(value.username == null && value.email == null)) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InterestsPage(
                    user: value,
                  ),
                ),
              );
            }
            clearText();
          }),
        });
  }

  Widget signUpButton() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () => {
              if (validatePassword(passwordText.text) &&
                  validateUserName(usernameText.text) &&
                  validateEmail(emailText.text))
                {main()}
              else
                {
                  setState(() {
                    isinvalidinput = true;
                  }),
                  clearText(),
                }
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
            'Register',
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
          hint == 'User Name'
              ? userName = newText
              : hint == 'Password'
                  ? password = newText
                  : email = newText;
        },
        controller: controller,
        obscureText: hint == 'Password' ? true : false,
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

  Widget notvalidinput(double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "Your input is not valid",
          style: TextStyle(color: Colors.red),
        )
      ],
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              inputField('User Name', usernameText),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              inputField('Password', passwordText),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              inputField('Email', emailText),
              signUpButton(),
              isinvalidinput
                  ? notvalidinput(screenHeight, screenWidth)
                  : const Text(""),
              Container(
                height: screenHeight * 0.38,
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
                    'Already have an Account?',
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
                              builder: (context) => const Login()));
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900]),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ));
  }
}
