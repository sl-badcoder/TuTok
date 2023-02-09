// This is the API_SERVICE where we defined our headers authentication and our
// get / post

import 'dart:convert';

import 'package:http/http.dart' as http;

class APIService {
  final String _baseUrl = "https://blinky.barpec12.pl";
  static Map<String, String> headers = {
    "content-type": "application/json",
    "accept": "application/json"
  };

  static late String credentials;

  void setAuthData(String username, String password) {
    credentials = base64Encode(utf8.encode('$username:$password'));
    headers = _getHeaders();
  }

  Map<String, String> _getHeaders() {
    return {
      "content-type": "application/json",
      "accept": "application/json",
      "authorization": "Basic $credentials",
    };
  }

  Future<http.Response> get(String url, Map<String, String> params) async {
    try {
      Uri uri = Uri.parse(_baseUrl + url).replace(queryParameters: params);
      // params /*String|Iterable<String>*/
      print(uri);
      http.Response response = await http.get(uri, headers: headers);
      return response;
    } catch (e) {
      return http.Response({"message": e}.toString(), 400);
    }
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    try {
      Uri uri = Uri.parse(_baseUrl + url);
      String bodyString = json.encode(body);
      http.Response response =
          await http.post(uri, headers: headers, body: bodyString);
      return response;
    } catch (e) {
      return http.Response({"message": e}.toString(), 400);
    }
  }

  Future<http.Response> put(String url, Map<String, dynamic> body) async {
    try {
      Uri uri = Uri.parse(_baseUrl + url);
      String bodyString = json.encode(body);
      http.Response response =
          await http.put(uri, headers: headers, body: bodyString);
      return response;
    } catch (e) {
      return http.Response({"message": e}.toString(), 400);
    }
  }

  Future<http.Response> delete(String url) async {
    try {
      Uri uri = Uri.parse(_baseUrl + url);
      http.Response response = await http.delete(uri, headers: headers);
      return response;
    } catch (e) {
      return http.Response({"message": e}.toString(), 400);
    }
  }
}
