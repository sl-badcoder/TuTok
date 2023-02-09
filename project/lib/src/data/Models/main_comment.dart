// This is a Model for a MainComment

import 'sub_comment.dart';

class MainComment {
  List<SubComment>? subComments;
  int? clipID;
  int? mainCommentID;
  String? message;
  int? likes;
  String? userName;
  int? userID;
  String? localDate;
  bool mehrAnzeigen = false;
  List<int>? likesFromUserMain;

  MainComment(
      {this.mainCommentID,
      required this.message,
      this.likes,
      this.userName,
      this.clipID,
      this.subComments,
      this.localDate,
      this.userID,
      this.likesFromUserMain});

  MainComment.empty();

  factory MainComment.fromJson(Map<String, dynamic> json) {
    return MainComment(
        mainCommentID:
            json['mainCommentID'] == null ? null : json['mainCommentID'],
        message: json['message'] == null ? null : json['message'],
        likes: json['likes'] == null ? null : json['likes'],
        userName: json['userName'] == null ? null : json['userName'],
        subComments: List<SubComment>.from(
            json['subComments'].map((e) => SubComment.fromJson(e))),
        clipID: json['clipID'] == null ? null : json['clipID'],
        localDate: json['localDate'] == null ? null : json['localDate'],
        likesFromUserMain: json['likesFromUserMain'] == null
            ? []
            : List<int>.from(json['likesFromUserMain']),
        userID: json['userID']);
  }

  Map<String, dynamic> toJson(MainComment mainComment) {
    return {
      "message": mainComment.message,
      "clipID": mainComment.clipID,
    };
  }

  @override
  String toString() {
    return 'MainComment{mainCommentID: $mainCommentID,'
        'message: $message,'
        'likes: $likes,'
        'userName: $userName,'
        'subComments: $subComments,'
        'clipID $clipID,'
        'likesFromUserMain $likesFromUserMain,'
        'localDate $localDate}';
  }
}
