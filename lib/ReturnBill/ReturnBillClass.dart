import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

class ReturnBillData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReturnView();
  }
}

class ReturnView extends State<ReturnBillData> {
  var form_key = GlobalKey<FormState>();
  String TAG = "ReturnView";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
        body: new Container(
          padding: EdgeInsets.all(10.0),
          child: new Form(
              key: form_key,
              child: new ListView(
                children: [
                  new Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 30.0),
                    child: Text(
                      "Return Bill Exception",
                      style: TextStyle(fontSize: 18.0, color: colorPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  BillNumberFeild(),
                  SizedBox(
                    height: 20.0,
                  ),
                  RemarkFeild(),
                  SizedBox(
                    height: 20.0,
                  ),
                  GetSubmitButton()
                ],
              )),
        ));
  }

  GetSubmitButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.
        if (form_key.currentState.validate()) {
          UpdateData();
        }
      },
      child: Text(
        'Save',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  final BillNumberController = TextEditingController();

  final RemarkController = TextEditingController();
  BillNumberFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: BillNumberController,
      decoration: GlobalWidget.TextFeildDecoration("Enter Bill Number"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter bill number';
        }
        return null;
      },
    );
  }

  RemarkFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: RemarkController,
      decoration: GlobalWidget.TextFeildDecoration("Enter Remark"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter remark';
        }
        return null;
      },
    );
  }

  Future<void> UpdateData() async {
    List a1 = new List();
    Map<String, dynamic> map() => {
          'pname': 'ReqTy',
          'value': 2,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'DocNo',
          'value': BillNumberController.text.toString(),
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };
    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'Remark',
          'value': RemarkController.text.toString(),
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'pname': 'Empcode',
          'value': "",
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map_submit() => {
          'dbPassword': userPass,
          'dbUser': USER_ID.toString(),
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.CntrExcp_Save,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': map_final(),
        };

    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController.postsNew(GlobalConstant.SignUp, json.encode(map_submit())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, data1);
          if (data1['status'] == 0) {
            GlobalWidget.showToast(context, "Saved successfully");

            Navigator.of(context).pop();
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
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }
}
