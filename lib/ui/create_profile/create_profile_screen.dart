import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  /*
  final userIdController = TextEditingController(text: "2585980");
  final userPasswordController = TextEditingController(text: "rsq@614");
  final userPinController = TextEditingController(text: "123456");
  final userPinConController = TextEditingController(text: "123456");*/

  final userIdController = TextEditingController(text: "");
  final userPasswordController = TextEditingController(text: "");
  final userPinController = TextEditingController(text: "");
  final userPinConController = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
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
                GlobalWidget.getHeadText("Create New Profile"),
                GlobalWidget.SizeBox1(),
                GlobalWidget.SizeBox1(),
                userIdField(),
                GlobalWidget.SizeBox1(),
                userPasswordField(),
                GlobalWidget.SizeBox1(),
                userPinField(),
                GlobalWidget.SizeBox1(),
                userPinConfirmField(),
                GlobalWidget.SizeBox1(),
                getSubmitButton(),
              ])),
        ));
  }

  _focusListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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
      controller: userIdController,
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

  userPasswordField() {
    return TextFormField(
      controller: userPasswordController,
      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Enter Password",
        suffixIcon: IconButton(
          onPressed: () => _toggle(),
          icon: GlobalWidget.getIcon(_obscureText),
        ),
      ),

      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      obscureText: _obscureText,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password';
        }
        if (value.length < 3) {
          return 'Password length too short ';
        }
        return null;
      },
    );
  }

  userPinField() {
    return TextFormField(
      controller: userPinController,
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

  userPinConfirmField() {
    return TextFormField(
      controller: userPinConController,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,
      obscureText: _obscureText2,
      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Enter 6 Digit Pin",
        suffixIcon: IconButton(
          onPressed: () => _toggle2(),
          icon: GlobalWidget.getIcon(_obscureText2),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter pin';
        } else if (value != userPinController.text.toString()) {
          return 'Pin and confirm pin must be same';
        }
        return null;
      },
    );
  }

  getSubmitButton() {
    return MaterialButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          updateData();
        }
      },
      child: Text(
        'Submit',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  String TAG = "SignView";
  Future<void> updateData() async {
    var data = GlobalConstant.GetMap();
    print("datatval $data");
    Map<String, dynamic> map2() => {
          'dbPassword': userPasswordController.text.toString(),
          'dbUser': userIdController.text.toString(),
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.PROCName,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    print("datatval2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {} catch (e) {
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(context, "", GlobalConstant.interNetException(e.toString()));
      }
      apiController.postsNew(GlobalConstant.SIGNIN, json.encode(map2())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, "Response: " + data1.toString());
          if (data1['status'] == 0) {
            GlobalWidget.GetToast(context, "Profile Created successfully");
            Utility.setStringPreference(GlobalConstant.USER_ID, userIdController.text.toString());
            Utility.setStringPreference(GlobalConstant.USER_PIN, userPinController.text.toString());
            Utility.setStringPreference(GlobalConstant.USER_PASSWORD, userPasswordController.text.toString());
            Utility.setStringPreference(GlobalConstant.IS_LOGIN, "");
            Navigator.of(context).pop();
          } else {
            if (data1['msg'].toString().contains("Login failed for user")) {
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
}
