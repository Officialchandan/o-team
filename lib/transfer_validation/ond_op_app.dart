import 'dart:collection';

import 'package:flutter/material.dart';

class OndOpApp {
  static final String ITEM_SETTINGS = "com.ondoor.ondoprationapp.ITEMSETTING";
  static String dbUser = "";
  static String dbPassword = "";
  static int srvId = 100;
  static String PID = "";
  static int cityId = 0;
  static String cityName = "NA";
  static String UserName;
  static int LEVEL;
  static String appVerFromDb;
  static int appUpdateFlag;
  static int gpsTrackingFlag;
  static String CocoName;
  static HashMap<String, PartyInfo> partyList = new HashMap();
  static PartyInfo selectedCoco;

  static int UserRole;
  static DataTable formTable;

//      static void ShowMsg(parent, String msg) {
//         AlertDialog.Builder bd = new AlertDialog.Builder(parent);
//         bd.setMessage(msg).setTitle("").setCancelable(false).setPositiveButton("Ok",
//                 new DialogInterface.OnClickListener() {
//                      void onClick(final DialogInterface dialog, final int id) {
//                         dialog.dismiss();
//                     }
//                 });
//         final AlertDialog alert = bd.create();
//         alert.show();
//     }
//      static void ShowMsgModel(parent, String msg) {
//         AlertDialog bd = new AlertDialog();
//         bd.setMessage(msg).setTitle("").setCancelable(false).setPositiveButton("Ok",
//                 new DialogInterface.OnClickListener() {
//                      void onClick(final DialogInterface dialog, final int id) {
//                         dialog.dismiss();
//                     }
//                 });
//         final AlertDialog alert = bd.create();
//         alert.setCancelable(false);
//         alert.show();
//     }

}

class PartyInfo {
  String pid;
  String pname;
  String cityId;
  String cityName;
  String cityLbl;

  PartyInfo(
      {String pid,
      String pname,
      String cityId,
      String cityName,
      String cityLbl}) {
    this.pid = pid;
    this.pname = pname;
    this.cityId = cityId;
    this.cityName = cityName;
    this.cityLbl = cityLbl;
  }

  String getPid() {
    return pid;
  }

  void setPid(String pid) {
    this.pid = pid;
  }

  String getPname() {
    return pname;
  }

  void setPname(String pname) {
    this.pname = pname;
  }

  String getCityId() {
    return cityId;
  }

  void setCityId(String cityId) {
    this.cityId = cityId;
  }

  String getCityName() {
    return cityName;
  }

  void setCityName(String cityName) {
    this.cityName = cityName;
  }

  String getCityLbl() {
    return cityLbl;
  }

  void setCityLbl(String cityLbl) {
    this.cityLbl = cityLbl;
  }
}
