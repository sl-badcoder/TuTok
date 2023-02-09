// This is a Model for User

import 'clip.dart';

class User {
  String? username;
  String? email;
  String? password;
  List<Clip>? likedClips;
  int? level;
  List<int>? follower;
  List<int>? following;
  int? userId;

  User(
      {required this.username,
      required this.email,
      this.password,
      this.likedClips,
      this.level,
      this.following,
      this.follower,
      this.userId});

  User.empty();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      likedClips: json['likedClips'] == null
          ? null
          : List<Clip>.from(json['likedClips'].map((e) => Clip.fromJson(e))),
      level: json['level'],
      follower:
          json['follower'] == null ? [] : List<int>.from(json['follower']),
      following:
          json['following'] == null ? [] : List<int>.from(json['following']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson(User user) {
    return {
      "username": user.username,
      "email": user.email,
      "password": user.password,
    };
  }

  @override
  String toString() {
    return 'User{username: $username,'
        ' email: $email}';
  }
}
