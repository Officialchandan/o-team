// To parse this JSON data, do
//
//     final responseModel = responseModelFromMap(jsonString);

import 'dart:convert';

class ResponseModel {
  ResponseModel({
    this.status,
    this.data,
    this.msg,
    this.dataTable,
  });

  int status;
  dynamic data;
  dynamic msg;
  DataTable dataTable;

  factory ResponseModel.fromJson(String str) => ResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResponseModel.fromMap(Map<String, dynamic> json) => ResponseModel(
    status: json["status"] == null ? 0 : json["status"],
    data: json["data"],
    msg: json["msg"],
    dataTable: json["ds"] == null ? null : DataTable.fromMap(json["ds"]),
  );

  Map<String, dynamic> toMap() => {
    "status": status == null ? null : status,
    "data": data,
    "msg": msg,
    "ds": dataTable == null ? null : dataTable.toMap(),
  };
}

class DataTable {
  DataTable({
    this.tables,
  });

  List<Table> tables;

  factory DataTable.fromJson(String str) => DataTable.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DataTable.fromMap(Map<String, dynamic> json) => DataTable(
    tables: json["tables"] == null ? [] : List<Table>.from(json["tables"].map((x) => Table.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "tables": tables == null ? [] : List<dynamic>.from(tables.map((x) => x.toMap())),
  };




}

class Table {
  Table({
    this.rowsList,
    this.header,
    this.name,
  });

  List<RowsList> rowsList;
  List<Header> header;
  String name;

  factory Table.fromJson(String str) => Table.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Table.fromMap(Map<String, dynamic> json) => Table(
    rowsList: json["rowsList"] == null ? [] : List<RowsList>.from(json["rowsList"].map((x) => RowsList.fromMap(x))),
    header: json["header"] == null ? [] : List<Header>.from(json["header"].map((x) => Header.fromMap(x))),
    name: json["name"] == null ? "" : json["name"],
  );

  Map<String, dynamic> toMap() => {
    "rowsList": rowsList == null ? null : List<dynamic>.from(rowsList.map((x) => x.toMap())),
    "header": header == null ? null : List<dynamic>.from(header.map((x) => x.toMap())),
    "name": name == null ? null : name,
  };
}

class Header {
  Header({
    this.name,
    this.type,
  });

  String name;
  String type;

  factory Header.fromJson(String str) => Header.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Header.fromMap(Map<String, dynamic> json) => Header(
    name: json["name"] == null ? "" : json["name"],
    type: json["type"] == null ? "" : json["type"],
  );

  Map<String, dynamic> toMap() => {
    "name": name == null ? null : name,
    "type": type == null ? null : type,
  };
}

class RowsList {
  RowsList({
    this.cols,
  });

  Map<String, String> cols;

  factory RowsList.fromJson(String str) => RowsList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RowsList.fromMap(Map<String, dynamic> json) => RowsList(
    cols: json["cols"] == null ? {} : Map.from(json["cols"]).map((k, v) => MapEntry<String, String>(k, v == null ? "" : v)),
  );

  Map<String, dynamic> toMap() => {
    "cols": cols == null ? {} : Map.from(cols).map((k, v) => MapEntry<String, dynamic>(k, v == null ? "" : v)),
  };
}
