// This is the Screen for Comments

import 'package:blinky_two/src/data/Models/main_comment.dart';
import 'package:blinky_two/src/data/Models/sub_comment.dart';
import 'package:blinky_two/src/data/Repositories/clip_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../data/Models/user.dart';

class Comment extends StatefulWidget {
  final User user;
  final int? clipID;

  Comment({Key? key, required this.user, this.clipID}) : super(key: key);

  @override
  _Comment createState() => _Comment();
}

class _Comment extends State<Comment> {
  final TextEditingController newMessage = TextEditingController();
  final ClipRepository clipRepository = ClipRepository();
  FocusNode focusNode = FocusNode();

  List<MainComment> comments = [];

  bool isMainComment = true;
  int idVomMain = -1;
  late String picture;

  @override
  void initState() {
    getComment();
    picture = "http://blinky.barpec12.pl/user/get/image/${widget.user.userId!}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(key: Key("Comment"), children: [
      InkWell(
        onTap: () {
          setState(() {});
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) =>
                      SizedBox(
                          height: screenHeight * 0.6,
                          child: Column(
                            children: [
                              Expanded(
                                  child: Container(
                                height: (screenHeight * 0.6) * 0.8,
                                child: ListView.builder(
                                    itemCount: comments.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                          child: Column(children: [
                                        Container(
                                            child: Container(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 5,
                                                                    right: 10),
                                                            child: CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      "http://blinky.barpec12.pl/user/get/image/${comments[index].userID}"),
                                                              radius: 18,
                                                            )),
                                                        Container(
                                                            width: screenWidth *
                                                                0.85,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  comments[
                                                                          index]
                                                                      .userName!,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                                SizedBox(
                                                                  height: 7,
                                                                ),
                                                                Text(
                                                                  comments[
                                                                          index]
                                                                      .message!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                5),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                            comments[index]
                                                                                .localDate!,
                                                                            style:
                                                                                TextStyle(fontSize: 13)),
                                                                        Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 20),
                                                                            child: InkWell(
                                                                                onTap: () {
                                                                                  isMainComment = false;
                                                                                  idVomMain = comments[index].mainCommentID!;
                                                                                  showKeyboard();
                                                                                },
                                                                                child: Container(
                                                                                  child: Text('answer', style: TextStyle(fontSize: 13)),
                                                                                ))),
                                                                        SizedBox(
                                                                          width:
                                                                              screenWidth * 0.28,
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            clipRepository.toggleMainCommentLike(widget.clipID, comments[index].mainCommentID!).then((value) {
                                                                              if (comments[index].likesFromUserMain!.contains(widget.user.userId)) {
                                                                                comments[index].likesFromUserMain!.remove(widget.user.userId);
                                                                              } else {
                                                                                comments[index].likesFromUserMain!.add(widget.user.userId!);
                                                                              }
                                                                              comments[index].likes = value;
                                                                              setState(() {});
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.favorite,
                                                                            color: comments[index].likesFromUserMain!.contains(widget.user.userId)
                                                                                ? Colors.red
                                                                                : Colors.white,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              1,
                                                                        ),
                                                                        Text(
                                                                          NumberFormat.compact()
                                                                              .format(comments[index].likes!),
                                                                          style:
                                                                              TextStyle(fontSize: 13),
                                                                        ),
                                                                      ],
                                                                    )),
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (comments[index]
                                                                            .mehrAnzeigen)
                                                                          comments[index].mehrAnzeigen =
                                                                              false;
                                                                        else {
                                                                          comments[index].mehrAnzeigen =
                                                                              true;
                                                                        }
                                                                        ;
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      child: comments[index].subComments!.length ==
                                                                              0
                                                                          ? SizedBox(
                                                                              height: 0,
                                                                              width: 0,
                                                                            )
                                                                          : comments[index].mehrAnzeigen
                                                                              ? Text(
                                                                                  'show less',
                                                                                  style: TextStyle(fontSize: 12),
                                                                                )
                                                                              : Text(
                                                                                  'show more',
                                                                                  style: TextStyle(fontSize: 12),
                                                                                ),
                                                                    )),
                                                              ],
                                                            )),
                                                      ],
                                                    )))),
                                        for (int i = 0;
                                            i <
                                                comments[index]
                                                    .subComments!
                                                    .length;
                                            i++)
                                          !comments[index].mehrAnzeigen
                                              ? const SizedBox(
                                                  height: 0,
                                                  width: 0,
                                                )
                                              : Container(
                                                  child: Container(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5,
                                                                  left: 50),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10),
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            "http://blinky.barpec12.pl/user/get/image/${comments[index].subComments![i].userID}"),
                                                                    radius: 13,
                                                                  )),
                                                              Container(
                                                                  width:
                                                                      screenWidth *
                                                                          0.75,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        comments[index]
                                                                            .subComments![i]
                                                                            .userName!,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            1,
                                                                      ),
                                                                      Text(
                                                                        comments[index]
                                                                            .subComments![i]
                                                                            .message!,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                              comments[index].subComments![i].localDate!,
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(fontSize: 12)),
                                                                          SizedBox(
                                                                            width:
                                                                                screenWidth * 0.37,
                                                                          ),
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              clipRepository.toggleSubCommentLike(widget.clipID, comments[index].mainCommentID!, comments[index].subComments![i].subCommentID!).then((value) {
                                                                                if (comments[index].subComments![i].likesFromUserSub!.contains(widget.user.userId)) {
                                                                                  comments[index].subComments![i].likesFromUserSub!.remove(widget.user.userId);
                                                                                } else {
                                                                                  comments[index].subComments![i].likesFromUserSub!.add(widget.user.userId!);
                                                                                }
                                                                                comments[index].subComments![i].likes = value;
                                                                                setState(() {});
                                                                              });
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.favorite,
                                                                              color: comments[index].subComments![i].likesFromUserSub!.contains(widget.user.userId) ? Colors.red : Colors.white,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                1,
                                                                          ),
                                                                          Text(
                                                                            NumberFormat.compact().format(comments[index].subComments![i].likes),
                                                                            style:
                                                                                TextStyle(fontSize: 13),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  )),
                                                            ],
                                                          ))))
                                      ]));
                                    }),
                              )),
                              SingleChildScrollView(
                                  child: AnimatedPadding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: Container(
                                          height: (screenHeight * 0.6) * 0.2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(picture),
                                                radius: 20,
                                              ),
                                              Container(
                                                width: screenWidth * 0.75,
                                                child: TextField(
                                                  key: Key("CommentsBox"),
                                                  focusNode: focusNode,
                                                  decoration: InputDecoration(
                                                    hintText: "Comment...",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                    ),
                                                  ),
                                                  controller: newMessage,
                                                ),
                                              ),
                                              IconButton(
                                                key: Key("Eingeben"),
                                                onPressed: () async {
                                                  if (newMessage
                                                      .value.text.isNotEmpty) {
                                                    print(
                                                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                                                    print(
                                                        newMessage.value.text);
                                                    if (isMainComment) {
                                                      MainComment newComment =
                                                          MainComment(
                                                        clipID: widget.clipID,
                                                        message: newMessage
                                                            .value.text,
                                                      );
                                                      await clipRepository
                                                          .createMainComment(
                                                              newComment);
                                                      await clipRepository
                                                          .listMainComments(
                                                              widget.clipID)
                                                          .then((value) {
                                                        comments = value;
                                                      });
                                                      newMessage.clear();
                                                      setState(() {});
                                                    } else {
                                                      SubComment newComment =
                                                          SubComment(
                                                              mainCommentID:
                                                                  idVomMain,
                                                              message:
                                                                  newMessage
                                                                      .value
                                                                      .text,
                                                              clipID: widget
                                                                  .clipID);
                                                      await clipRepository
                                                          .createSubComment(
                                                              newComment);
                                                      await clipRepository
                                                          .listMainComments(
                                                              widget.clipID)
                                                          .then((value) {
                                                        comments = value;
                                                      });
                                                      newMessage.clear();
                                                      idVomMain = -1;
                                                      isMainComment = true;
                                                      setState(() {});
                                                    }
                                                    ;
                                                    dismissKeyboard();
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.send_rounded,
                                                  size: 30,
                                                ),
                                              )
                                            ],
                                          )))),
                            ],
                          )),
                );
              });
        },
        child: FaIcon(
          FontAwesomeIcons.commentDots,
          size: screenWidth / 12,
          color: Colors.white,
        ),
      ),
      SizedBox(height: screenHeight / 130),
      Text(
        'Comment',
        style: TextStyle(
          fontSize: screenWidth / 30,
          color: Colors.white,
        ),
      )
    ]);
  }

  void getComment() async {
    await clipRepository.listMainComments(widget.clipID).then((value) {
      comments = value;
    });
  }

  void showKeyboard() {
    focusNode.requestFocus();
  }

  void dismissKeyboard() {
    focusNode.unfocus();
  }
}
