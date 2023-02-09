// This is the repository for User functions with endpoint /user

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../Models/user.dart';
import '../Services/api_service.dart';

class UserRepository {
  final APIService _apiService = APIService();

  Future<User> login(String username, String password) async {
    _apiService.setAuthData(username, password);
    http.Response response = await _apiService.get("/user/login", {});
    print("response body: + ${response.body}");
    dynamic responseJson = jsonDecode(response.body);
    User user = User.fromJson(responseJson);
    return user;
  }

  Future<User> isLoggedIn() async {
    http.Response response = await _apiService.get("/user/login", {});
    dynamic responseJson = jsonDecode(response.body);
    User user = User.fromJson(responseJson);
    return user;
  }

  Future<String> createUser(User user) async {
    http.Response response =
        await _apiService.post("/user/create", user.toJson(user));
    return response.body;
  }

  Future<http.Response> setCategories(
      int userID, List<String> categories) async {
    Map<String, String> headers = {
      "content-type": "application/json",
      "accept": "application/json"
    };
    try {
      for (int i = 0; i < categories.length; i++) {
        categories[i] = '"' + categories[i] + '"';
      }
      print(categories);
      Uri uri = Uri.parse("https://blinky.barpec12.pl/user/categories/$userID");
      http.Response response =
          await http.post(uri, headers: headers, body: categories.toString());
      print(response.body);
      return response;
    } catch (e) {
      print(e);
      return http.Response({"message": e}.toString(), 400);
    }
  }

  Future<List<User>> search(String usernamePart) async {
    http.Response response =
        await _apiService.get("/user/search", {"usernamePart": usernamePart});
    Iterable responseJson = jsonDecode(response.body);
    List<User> search =
        List<User>.from(responseJson.map((e) => User.fromJson(e)));
    return search;
  }

  Future<User> follow(int userID) async {
    http.Response response = await _apiService.post("/user/follow/$userID", {});
    dynamic responseJson = jsonDecode(response.body);
    User user = User.fromJson(responseJson);
    return user;
  }

  Future<User> unfollow(int userID) async {
    http.Response response =
        await _apiService.post("/user/unfollow/$userID", {});
    dynamic responseJson = jsonDecode(response.body);
    User user = User.fromJson(responseJson);
    return user;
  }

  Future<User> getUser(String username) async {
    http.Response response =
        await _apiService.get("/user/getUser", {"identification": username});
    dynamic responseJson = jsonDecode(response.body);
    User user = User.fromJson(responseJson);
    return user;
  }

  Future<double> getProgress(int userID) async {
    http.Response response =
        await _apiService.get("/user/$userID/progress", {});
    double responseJson = jsonDecode(response.body);
    return responseJson;
  }

  Future<void> uploadPicture(File file, List<int> bytes, int userID) async {
    String url = "https://blinky.barpec12.pl/user/upload/image/$userID";
    try {
      final uri = Uri.parse(url);
      var request = new http.MultipartRequest('POST', uri);
      final httpImage = http.MultipartFile.fromBytes("file", bytes,
          contentType: MediaType.parse("multipart/form-data"),
          filename: 'myImage.png');
      request.files.add(httpImage);

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("XXXXXXXXXXXXXXX");
      print(respStr);
    } catch (e) {
      print(http.Response({"message": e}.toString(), 400));
      print(e.toString());
    }
  }

  Future<void> deletePicture(int userID) async {
    http.Response response =
        await _apiService.post("/user/deleteImage/$userID", {});
    print(response.body);
  }
}
