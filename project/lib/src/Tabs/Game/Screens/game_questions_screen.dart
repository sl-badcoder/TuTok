// This is the screen to show all questions behind each other

import 'package:flutter/material.dart';
import 'game_question_screen.dart';

class GameQuestionsScreen extends StatefulWidget {
  final List<GameQuestionScreen> questions;
  final int index;

  const GameQuestionsScreen(
      {Key? key,
      required this.questions,
      required this.index})
      : super(key: key);

  @override
  State<GameQuestionsScreen> createState() => _GameQuestionsScreen();
}

class _GameQuestionsScreen extends State<GameQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.questions.elementAt(widget.index);
  }
}
