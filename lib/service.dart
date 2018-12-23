import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo/Todo.dart';

//const request = "http://127.0.0.1:8080/api";
const request = "https://todo-renato.herokuapp.com/api";

class service {

  static Future<List<Todo>> getTodo(http.Client client) async {
    final response = await client.get(request);
    return compute(parseTodo, response.body);
  }

  static List<Todo> parseTodo(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Todo>((json) => Todo.fromJson(json)).toList();
  }

  static Future post(String texto) async {
    String url = request + "/${texto}";

    return await http.post(Uri.encodeFull(url),
        body: null,
        headers: {"Accept": "application/json"}).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
    });

  }

  static Future delete(String id) async{
    String url = request + "/${id}";

    return await http.delete(Uri.encodeFull(url),
        headers: {"Accept": "application/json"}).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
    });
  }

  static Future update(String id) async {
    String url = request + "/${id}";

    return  await http.put(Uri.encodeFull(url),
        headers: {"Accept": "application/json"}).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
    });

  }



}