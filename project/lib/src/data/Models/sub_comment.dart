// This is the model for SubComment

class SubComment {
  int? subCommentID;
  int? mainCommentID;
  String? message;
  int? likes;
  String? userName;
  String? localDate;
  int? clipID;
  bool isLiked = false;
  int? userID;
  List<int>? likesFromUserSub;

  SubComment(
      {required this.mainCommentID,
      required this.message,
      required this.clipID,
      this.likes,
      this.userName,
      this.subCommentID,
      this.localDate,
      this.userID,
      this.likesFromUserSub});

  SubComment.empty();

  factory SubComment.fromJson(Map<String, dynamic> json) {
    return SubComment(
      mainCommentID:
          json['mainCommentID'] == null ? null : json['mainCommentID'],
      message: json['message'] == null ? null : json['message'],
      likes: json['likes'] == null ? null : json['likes'],
      userName: json['userName'] == null ? null : json['userName'],
      subCommentID: json['subCommentID'] == null ? null : json['subCommentID'],
      clipID: json['clipID'] == null ? null : json['clipID'],
      localDate: json['localDate'] == null ? null : json['localDate'],
      userID: json['userID'],
      likesFromUserSub: json['likesFromUserSub'] == null
          ? []
          : List<int>.from(json['likesFromUserSub']),
    );
  }

  Map<String, dynamic> toJson(SubComment mainComment) {
    return {
      "mainCommentID": mainComment.mainCommentID,
      "message": mainComment.message,
      "clipID": mainComment.clipID,
    };
  }

  @override
  String toString() {
    return 'SubComment{mainCommentID: $mainCommentID,'
        'message: $message,'
        'likes: $likes,'
        'userName: $userName,'
        'subCommentID $subCommentID,'
        'clipID $clipID,'
        'likesFromUserSub $likesFromUserSub,'
        'localDate $localDate}';
  }
}
