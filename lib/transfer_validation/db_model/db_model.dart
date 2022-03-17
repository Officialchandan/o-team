import 'dart:io';

import 'package:object_mapper/object_mapper.dart';

import '../data_table.dart';

class DBRequestModel {
  String dbUser;
  String dbPassword;
  int srvId;
  String procName;
  MyDataTable param;
  int timeout;
  String host;
  String os;
  String rid;
  String key = "123654789@12589741#abedf\$ond852341";

  String getHost() {
    host = "OperationApp";
    return host;
  }

  void setHost(String host) {
    this.host = host;
  }

  String getOs() {
    os = Platform.isAndroid ? "Android" : "ios";

    return os;
  }

  void setOs(String os) {
    this.os = os;
  }

  void setRid(String rid) {
    this.rid = rid;
  }

  String getRid() {
    return rid;
  }

  String getKey() {
    return key;
  }

  void setKey(String key) {
    this.key = key;
  }

  String getDbUser() {
    return dbUser;
  }

  void setDbUser(String dbUser) {
    this.dbUser = dbUser;
  }

  String getDbPassword() {
    return dbPassword;
  }

  void setDbPassword(String dbPassword) {
    this.dbPassword = dbPassword;
  }

  int getSrvId() {
    return srvId;
  }

  void setSrvId(int srvId) {
    this.srvId = srvId;
  }

  String getProcName() {
    return procName;
  }

  setProcName(String procName) {
    this.procName = procName;
  }

  MyDataTable getParam() {
    return param;
  }

  void setParam(MyDataTable param) {
    this.param = param;
  }

  int getTimeout() {
    return timeout;
  }

  void setTimeout(int timeout) {
    this.timeout = timeout;
  }

  // toJson() async {
  //   Mapper mapper = new Mapper();
  //   String field;
  //   String jsonInString = mapper("field", field, (v) => field = v);
  //
  //   return jsonInString;
  // }

  static DBRequestModel toObject(String json) {
    Mapper mapper = Mapper();
    DBRequestModel field;
    // DBRequestModel obj = mapper.readValue(json, DBRequestModel.class);
    DBRequestModel obj = mapper("field", field.toJson(), (v) => field = v);
    return obj;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "dbUser": getDbUser(),
      "dbPassword": getDbPassword(),
      "srvId": getSrvId(),
      "procName": getProcName(),
      "param": getParam().toJson(),
      "timeout": getTimeout(),
      "host": getHost(),
      "key": getKey(),
      "os": getOs(),
      "rid": getRid(),
    };

    return map;
  }

  static void main(List<String> args) {
    String json =
        "{\"dbUser\":\"2534813\",\"dbPassword\":\"abc@1234\",\"srvId\":100,\"procName\":\"lib_ItemSync\",\"param\":{\"rowsList\":[{\"cols\":{\"pname\":\"LastTs\",\"value\":1487579972123}}],\"header\":[],\"name\":\"param\"},\"timeout\":30}";
    DBRequestModel dbr = DBRequestModel.toObject(json);
  }
}
