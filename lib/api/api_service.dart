import 'package:dio/dio.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/model/response_model.dart';

import '../main.dart';

class ApiService {
  ApiService.internal();

  ApiService();

  Future<ResponseModel> getItems({Map input}) async {
    try {
      Response response = await dio.post(
        GlobalConstant.SIGNIN,
        data: input,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 ( compatible )',
          'Accept': '*/*',
        }),
      );

      return ResponseModel.fromJson(response.toString());
    } catch (exception) {
      print("exception--->$exception");

      return ResponseModel(msg: "$exception", data: "", dataTable: null, status: 100);
    }
  }

  Future<ResponseModel> postJson({Map input}) async {
    try {
      Response response = await dio.post(
        GlobalConstant.SIGNIN,
        data: input,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 ( compatible )',
          'Accept': '*/*',
        }),
      );

      return ResponseModel.fromJson(response.toString());
    } catch (exception) {
      print("exception--->$exception");

      return ResponseModel(msg: "$exception", data: "", dataTable: null, status: 100);
    }
  }

  Future postMultipart(Map<String, dynamic> input) async {
    try {
      Response response = await dio.post(
        GlobalConstant.SIGNIN,
        data: input,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 ( compatible )',
          'Accept': '*/*',
        }),
      );

      return ResponseModel.fromJson(response.toString());
    } catch (exception) {
      print("exception--->$exception");

      return ResponseModel(msg: "$exception", data: "", dataTable: null, status: 100);
    }
  }
}
