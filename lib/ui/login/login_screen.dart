import 'dart:convert';
import 'dart:developer';

import "package:collection/collection.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/DashBoard/DashBoard.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/SearchStore.dart';
import 'package:ondoprationapp/ui/create_profile/create_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /*
  final userIdController = TextEditingController(text: "2585980");
  final userPinController = TextEditingController(text: "123456");*/
  final edtUserId = TextEditingController(text: "");
  final edtPin = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _obscureText1 = true;
  final TAG = "LoginScreen";
  // Toggles the password show status
  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
        body: new Center(
          child: Form(
              key: _formKey,
              child: ListView(shrinkWrap: true, padding: GlobalWidget.getpadding(), children: <Widget>[
                GlobalWidget.getMainHeadText("Ondoor Ops Team"),
                GlobalWidget.SizeBox1(),
                GlobalWidget.SizeBox1(),
                GlobalWidget.getHeadImage(context),
                GlobalWidget.getHeadText("Login Form"),
                GlobalWidget.SizeBox1(),
                userIdField(),
                GlobalWidget.SizeBox1(),
                userPinField(),
                GlobalWidget.SizeBox1(),
                getSubmitButton(),
                GlobalWidget.SizeBox1(),
                getSignUpButton(),
              ])),
        ));
  }

  _focusListener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  userIdField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: edtUserId,
      decoration: GlobalWidget.TextFeildDecoration("Enter User ID"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter user id';
        }
        if (value.length < 5) {
          return 'UserId length is too short';
        }
        return null;
      },
    );
  }

  userPinField() {
    return TextFormField(
      controller: edtPin,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      obscureText: _obscureText1,
      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Enter 6 Digit Pin",
        suffixIcon: IconButton(
          onPressed: () => _toggle1(),
          icon: GlobalWidget.getIcon(_obscureText1),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter pin';
        }
        if (value.length < 6) {
          return 'Please enter 6 digit pin';
        }
        return null;
      },
    );
  }

  getSubmitButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.
        if (_formKey.currentState.validate()) {
          getSharedData();
        }
      },
      child: Text(
        'Submit',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  getSignUpButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.
        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProfileScreen()));
      },
      child: Text(
        'Create New Profile',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  Future<void> updateData() async {
    var data = GlobalConstant.GetMapLogin();
    debugPrint("updateData $data");

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': edtUserId.text.toString(),
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.PROCName_Login,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    debugPrint("data val2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController.postsNew(GlobalConstant.SIGNIN, json.encode(map2())).then((value) {
        try {
          log("value---->${value.toString()}");
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          if (data1['status'] == 0) {
            GlobalWidget.GetToast(context, "Successfully Login");
            List a1 = new List();
            var menudata = data1['ds']['tables'][2]['rowsList'];
            for (int i = 0; i < menudata.length; i++) {
              var mapdata = getMap(menudata[i]['cols']);
              a1.add(json.encode(mapdata));
            }
            var Empname = data1['ds']['tables'][0]['rowsList'][0]['cols']['Empname'].toString();
            var Role = data1['ds']['tables'][0]['rowsList'][0]['cols']['Role'].toString();
            var AppUpd = data1['ds']['tables'][0]['rowsList'][0]['cols']['AppUpd'].toString();
            var Appversion = data1['ds']['tables'][0]['rowsList'][0]['cols']['Appversion'].toString();
            var ListVal = data1['ds']['tables'][1]['rowsList'];

            var GrpMap = groupBy(ListVal, (obj) => obj["cols"]['CityId']);

            Utility.log(TAG + "cityid", GrpMap.keys);
            String cityIds = GrpMap.keys.toString();
            Utility.log(TAG, a1.toString());
            Utility.setStringPreference(GlobalConstant.Empname, Empname);
            Utility.setStringPreference(GlobalConstant.AllCityIds, cityIds.substring(1, cityIds.length - 1));
            Utility.setStringPreference(GlobalConstant.Role, Role);
            Utility.setStringPreference(GlobalConstant.AppUpd, AppUpd);
            Utility.setStringPreference(GlobalConstant.Appversion, Appversion);
            Utility.setStringPreference(GlobalConstant.Menu_Data, a1.toString());

            Navigator.of(context)
                .push(
              new MaterialPageRoute(builder: (_) => new SearchStore()),
            )
                .then((val) {
              FocusScope.of(context).requestFocus(new FocusNode());
              if (val != null) {
                setState(() {
                  var data = val;

                  String name = "${data['Pname']}";
                  String Id = "${data['PID']}";

                  Utility.setStringPreference(GlobalConstant.COCO_CITY_ID, data['CityId'].toString());
                  Utility.setStringPreference(GlobalConstant.COCO_CITY, data['CityLbl'].toString());
                  Utility.setStringPreference(GlobalConstant.COCO_CITY_CODE, data['CityName'].toString());
                  Utility.setStringPreference(GlobalConstant.COCO_ADDRESS, data['Address'].toString());

                  Utility.setStringPreference(GlobalConstant.IS_LOGIN, "1");
                  Utility.setStringPreference(GlobalConstant.LAST_TS, "0");
                  Utility.setStringPreference(GlobalConstant.COCO_ID, Id.toString());
                  Utility.setStringPreference(GlobalConstant.COCO_NAME, name.toString());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
                    ModalRoute.withName('/'),
                  );
                });
              }
            });
          } else {
            if (data1['msg'].toString() == "Login failed for user") {
              GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
            } else {
              GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
            }
          }
        } catch (e) {
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  Future<void> getSharedData() async {
    String userPin = (await Utility.getStringPreference(GlobalConstant.USER_PIN));
    String userId = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    if (userPin == edtPin.text.toString() && userId == edtUserId.text.toString()) {
      updateData();
    } else {
      GlobalWidget.showMyDialog(context, GlobalWidget.GetAppName, "Invalid pin or Profile not exist.");
    }
  }

  getMap(var products) {
    Map<String, dynamic> map() => {
          'FName': products['FName'].toString(),
          'FID': products['FID'].toString(),
        };
    return map();
  }
}
