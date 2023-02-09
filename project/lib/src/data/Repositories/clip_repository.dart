// This is the repository with the functions at /clip endpoint

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../Models/clip.dart';
import '../Models/main_comment.dart';
import '../Models/sub_comment.dart';
import '../Services/api_service.dart';

class ClipRepository {
  final APIService _apiService = APIService();
  static String quality = "DEFAULT";

  Map<String, String> headers = {
    "content-type": "multipart/form-data",
    "accept": "application/json"
  };

  Future<List<Clip>> getClips(int amount) async {
    http.Response response =
        await _apiService.get("/clip/", {"amount": "$amount"});
    Iterable responseJson = jsonDecode(response.body);
    List<Clip> clips =
        List<Clip>.from(responseJson.map((e) => Clip.fromJson(e)));
    return clips;
  }

  Future<Clip> getClip(int id) async {
    http.Response response = await _apiService.get("/clip/$id", {});
    dynamic responseJson = jsonDecode(response.body);
    Clip clip = Clip.fromJson(responseJson);
    return clip;
  }

  Future<Uri> getClipVideo(int? clipId) async {
    http.Response response =
        await _apiService.get("/clip/$clipId/video/$quality", {});
    String responseJson = jsonDecode(response.body);
    return Uri.parse(responseJson);
  }

  Future<String> createMainComment(MainComment mainComment) async {
    http.Response response = await _apiService.post(
        "/comment/createMainComment", mainComment.toJson(mainComment));
    return response.body;
  }

  Future<String> createSubComment(SubComment subComment) async {
    http.Response response = await _apiService.post(
        "/comment/createSubComment", subComment.toJson(subComment));
    return response.body;
  }

  Future<List<MainComment>> listMainComments(int? clipId) async {
    http.Response response =
        await _apiService.get("/comment/$clipId/listMainComments", {});
    Iterable responseJson = jsonDecode(response.body);
    List<MainComment> mainComments = List<MainComment>.from(
        responseJson.map((e) => MainComment.fromJson(e)));
    return mainComments;
  }

  Future<List<SubComment>> listSubComments(int? clipId, int mainId) async {
    http.Response response =
        await _apiService.get("/comment/$clipId/$mainId/listSubComments", {});
    Iterable responseJson = jsonDecode(response.body);
    List<SubComment> subComments =
        List<SubComment>.from(responseJson.map((e) => SubComment.fromJson(e)));
    return subComments;
  }

  Future<int> toggleMainCommentLike(int? clipId, int mainId) async {
    http.Response response =
        await _apiService.post("/comment/$clipId/$mainId/toggleLike", {});
    int responseJson = jsonDecode(response.body);
    return responseJson;
  }

  Future<int> toggleSubCommentLike(int? clipId, int mainId, int subId) async {
    http.Response response = await _apiService
        .post("/comment/$clipId/$mainId/$subId/toggleSubLike", {});
    int responseJson = jsonDecode(response.body);
    return responseJson;
  }

  Future<int> toggleLike(int? clipId) async {
    http.Response response =
        await _apiService.post("/clip/$clipId/toggleLike", {});
    int responseJson = jsonDecode(response.body);
    return responseJson;
  }

  Future<void> uploadClip(List<int> bytes, String name) async {
    String url =
        "https://blinky.barpec12.pl/clip/create?name=$name&clipType=MAIN_CLIP";

    try {
      final uri = Uri.parse(url);
      var request = new http.MultipartRequest('POST', uri);
      request.headers.addAll(_getHeaders());
      final httpImage = http.MultipartFile.fromBytes("file", bytes,
          contentType: MediaType.parse("multipart/form-data"),
          filename: '$name.mp4');
      request.files.add(httpImage);

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print(respStr);
    } catch (e) {
      print(http.Response({"message": e}.toString(), 400));
      print(e.toString());
    }
  }

  Map<String, String> _getHeaders() {
    return {
      "content-type": "multipart/form-data",
      "accept": "application/json",
      "authorization": "Basic ${APIService.credentials}",
    };
  }
}
