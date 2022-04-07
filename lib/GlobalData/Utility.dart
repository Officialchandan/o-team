import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  DialogClickInterface interface;

  static int getDeviceType() {
    if (Platform.isIOS) {
      print('is a IOS');
      return 2;
    } else {
      print('is a Andriod');
      return 1;
    }
  }

  static String validateFirstName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "First Name Required";
    } else if (value.toLowerCase() == "null") {
      return "Frist name not be null";
    } else if (!regExp.hasMatch(value)) {
      return "First must be only Alphabatical";
    }
    return null;
  }

  static String validateLastName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Last name Required";
    } else if (!regExp.hasMatch(value)) {
      return "Last Name must be Alphabatical";
    }
    return null;
  }

  static String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Please Enter Email";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  static log(var tag, var message) {
    dev.log('\n\n*****************\n$tag\n$message\n*****************\n\n');
  }

  static Future<String> getStringPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  static Future<bool> setStringPreference(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<bool> setStringListPreference(String key, List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, value);
  }

  static Future<List<String>> getStringListPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  static Future<int> getIntgerPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static Future<bool> setIntegerPreference(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(key, value);
  }

  static Future<bool> getBoolPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> setBoolPreference(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(key, value);
  }

  static Map<String, dynamic> getColumnMap(String name, dynamic value) {
    Map<String, dynamic> cols = <String, dynamic>{"pname": name, "value": value};

    Map<String, dynamic> data = HashMap<String, dynamic>();
    data["cols"] = cols;
    return data;
  }

//  static appBar(String title) {
//    return AppBar(
//      backgroundColor: appBarColor,
//      leading: IconButton(
//        onPressed: () {},
//        iconSize: 25,
//        icon: Image(
//          image: AssetImage(Images.menu),
//          width: 25,
//        ),
//      ),
//      elevation: 1,
//      centerTitle: true,
//      title: Text(
//        title,
//        style: TextStyle(
//            color: colorBlack,
//            fontSize: 25,
//            fontWeight: FontWeight.bold,
//            fontFamily: Fonts.kfont),
//      ),
//      actions: <Widget>[
//        IconButton(
//          onPressed: () {},
//          iconSize: 25,
//          icon: Image(
//            image: AssetImage(Images.searchImage),
//            width: 20,
//          ),
//        ),
//        SizedBox(
//          width: 15,
//        )
//      ],
//    );
//  }
}

abstract class DialogClickInterface {
  void onOkClick();
}

abstract class LoginRegisterListener {
  void onLoginClick();
  void onRegisterClick();
}
