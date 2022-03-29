import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:toast/toast.dart';

import 'ApiController.dart';
import 'AppColor.dart';
import 'NetworkCheck.dart';

class GlobalWidget {
  static var GetAppName = "O-Team";

  static getAppbar(String getAppName) {
    return AppBar(
      title: Text(getAppName),
      backgroundColor: colorPrimary,
    );
  }

  static Future<void> getItemDetail(BuildContext context, String selectedListId, Function getData) async {
    var data1;
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    var dataval = GlobalConstant.GetMapForListBasedStockItemDetail(COCO_ID, selectedListId);

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_getItemInfo,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': dataval,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      //Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        //Dialogs.hideProgressDialog(context);
        data1 = json.decode(data.body);
        return getData(data1);
      } catch (e) {
        //Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      //GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  static getAppbarRefrsh(String getAppName, Function() ReturnValue) {
    return AppBar(
      title: Text(getAppName),
      backgroundColor: colorPrimary,
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                ReturnValue();
              },
              child: Icon(
                Icons.refresh,
                size: 26.0,
              ),
            )),
      ],
    );
  }

  static showToast(BuildContext context, String msg) {
    Toast.show(msg, context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  static getHeadImage(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      height: 100.0,
      width: 100.0,
      child: new DecoratedBox(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("drawable/logo_small.png"),
          ),
        ),
      ),
    );
  }

  static getpaddingNavBottom() {
    return EdgeInsets.all(2);
  }

  static getpadding() {
    return EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0);
  }

  static getHeadText(String s) {
    return new Container(
      alignment: Alignment.center,
      child: Text(
        s,
        style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  static getMainHeadText(String s) {
    return new Container(
      alignment: Alignment.center,
      child: Text(
        s,
        style: TextStyle(fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Future<void> showMyDialog(BuildContext context, String title, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$title"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("" + msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMyDialogWithReturn(BuildContext context, String title, String msg, Function() alertReturn) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("" + msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              width: 20.0,
            ),
            FlatButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.of(context).pop();
                alertReturn();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMyDialogWithReturnNew(BuildContext context, String title, String msg, Function() alertReturn) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("" + msg),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: 20.0,
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                alertReturn();
              },
            ),
          ],
        );
      },
    );
  }

  static TextFeildDecoration(String s) {
    return new InputDecoration(
      hintText: s,
      fillColor: Colors.white,

      /* enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.red)),
      filled: true,
     */
      contentPadding: GlobalWidget.getContentPadding(),
    );
  }

  static TextFeildDecoration1(String s) {
    return new InputDecoration(
      hintText: s,
      fillColor: Colors.white,

      /* enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.red)),
      filled: true,
     */
    );
  }

  static fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static fieldFocusChangeOnlyUnfouc(BuildContext context, FocusNode currentFocus) {
    currentFocus.unfocus();
  }

  static TextFeildDecoration2(String s, String label) {
    return new InputDecoration(
      hintText: s,
      labelText: label,
      fillColor: Colors.white,

      /* enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.red)),
      filled: true,
     */
    );
  }

  static SizeBox1() {
    return SizedBox(height: 10.0);
  }

  static getButtonTheme() {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0), side: BorderSide(color: colorPrimary));
  }

  static getButtonThemeDisabeled() {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0), side: BorderSide(color: Colors.grey));
  }

  static getBtnTextColor() {
    return Colors.white;
  }

  static getBtncolor() {
    return colorPrimary;
  }

  static getDisableColor() {
    return disableColor;
  }

  static textbtnstyle() {
    return TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.0);
  }

  static textbtnstyle1() {
    return TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.0);
  }

  static getIcon(bool _obscureText) {
    return Icon(_obscureText ? Icons.visibility : Icons.visibility_off);
  }

  static getContentPadding() {
    return null;
  }

  static CreateDashContain(BuildContext context, String s) {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Container(
          color: colorPrimary,
          /* decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  //colors: [colorPrimary, colorPrimary]
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),*/
          child: new Center(
            child: new Text(
              s.toUpperCase(),
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }

  static getTextStyle(bool val) {
    return new TextStyle(
      color: val == true ? colorPrimary : Colors.black,
      fontSize: 14,
    );
  }

  static getTextStyle1(bool val) {
    return new TextStyle(
      color: val == true ? Colors.white : Colors.black,
      fontSize: 14,
    );
  }

  static getTextStyleBottomText(bool val) {
    return new TextStyle(
      color: val == true ? colorPrimary : Colors.black,
      fontSize: 14,
    );
  }

  static getSize() {
    return 30.0;
  }

  static getcolor(bool val) {
    if (val == true) {
      return colorPrimary;
      return new Color(0xFFFF0000);
    } else {
      return Colors.grey;
      return new Color(0xFF008000);
    }
  }

  static getHeadButtonShape(MaterialColor green) {
    return BoxDecoration(color: green, borderRadius: BorderRadius.all(Radius.circular(10.0)));
  }

  static getMargin() {
    return EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8);
  }

  static getDecoration(bool value) {
    return new BoxDecoration(
      borderRadius: BorderRadius.circular(0),
    );
  }

  static getDecorationcircle(bool value) {
    return new BoxDecoration(
      borderRadius: BorderRadius.circular(5),
    );
  }

  static getBoxConstraint() {
    return BoxConstraints(
      minWidth: 50,
      minHeight: 20,
    );
  }

  static getRowInsideDevide() {
    return SizedBox(
      height: 4.0,
    );
  }

  static String getDatafromJson(pendingDataList, String s) {
    String Product_Data = pendingDataList;
    var datval = json.decode(Product_Data);
    return datval[s];
  }

  static String getstringValue(String string) {
    try {
      if (string.toLowerCase() != "null") {
        return string;
      } else {
        return "-";
      }
    } catch (e) {}
    return "-";
  }

  static String getstringValue1(String string) {
    try {
      if (string.toLowerCase() != "null") {
        return string;
      } else {
        return "";
      }
    } catch (e) {}
    return "";
  }

  static getColumWidth() {
    return 150.0;
  }

  static getCharacterlen(String car) {
    return 200.0;
  }

  static getNoRecords(BuildContext context, String value) {
    print("Value- $value");
    return new Container(
      height: MediaQuery.of(context).size.height,
      child: new Center(
        child: value == GlobalConstant.Loading
            ? new CircularProgressIndicator()
            : Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colorPrimary),
              ),
      ),
    );
  }

  static showItemName(String Item_name) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          Item_name,
          style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
        ));
  }
}
