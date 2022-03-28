import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ondoprationapp/main.dart';

import 'Utility.dart';

class ApiController {
  var tag = 'ApiController';
  static ApiController _instance = new ApiController.internal();

  ApiController.internal();

  factory ApiController() {
    return _instance;
  }

  static ApiController getInstance() {
    if (_instance == null) {
      _instance = new ApiController.internal();
    }
    return _instance;
  }

  Future<http.Response> getsNew(String url) async {
    Utility.log(tag, "Api Call :\n $url ");
    Map data = {'apikey': '12345678901234567890'};

    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.get(
      Uri.parse(url),
      headers: {'request_type': 'application'},
    );
    debugPrint("response.statusCode--> ${response.statusCode}");
    Utility.log("Api Response", "${response.body}");
    return response;
  }

  Future<http.Response> postsNew(String url, var body) async {
    Utility.log(tag, "Api Call :\n $url ");
    Utility.log(tag, "Responsevaljson: " + body.toString());

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 ( compatible )',
        'Accept': '*/*',
      },
    ).timeout(Duration(seconds: 30000), onTimeout: () {
      Map<String, dynamic> map3() => {
            'pname': 'TimeOut',
            'value': true,
          };

      // time out after 30 second
      return json.decode(map3().toString());
    });
    debugPrint("${response.statusCode}");
    Utility.log(tag, "${response.body}");
    return response;
    //return null;
  }

  Future<Map<String, dynamic>> post({String url, Map input}) async {
    try {
      Response response = await dio.post(
        url,
        data: input,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 ( compatible )',
          'Accept': '*/*',
        }, maxRedirects: 3, followRedirects: true, receiveTimeout: 60000, sendTimeout: 30000),
      );

      return response.data;
    } catch (exception) {
      debugPrint("exception--->$exception");
      if (exception is DioError) {
        if (exception.type == DioErrorType.receiveTimeout ||
            exception.type == DioErrorType.connectTimeout ||
            exception.type == DioErrorType.sendTimeout) {
          Map<String, dynamic> map = {
            'pname': 'TimeOut',
            'value': true,
          };

          return map;
        }
      }

      Map<String, dynamic> map = {
        'pname': 'TimeOut',
        'value': true,
      };

      return map;

      // time out after 30 second
      // return json.decode(map3().toString());
    }
  }
}
