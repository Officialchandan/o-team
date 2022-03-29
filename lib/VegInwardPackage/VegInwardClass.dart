import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

import 'AddNewVegGrc.dart';

class VegInwardActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VegInwardView();
  }
}

class VegInwardView extends State<VegInwardActivity> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddNewVegGrc()));
        },
      ),
      appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
      body: durationIntItems.length > 0 ? getFirstForm() : new Container(),
      // body:getFirstForm(),
    );
  }

  int bill_type = 1;
  String bill_type_str = "Sign IN";

  getFirstForm() {
    return new ListView(
      padding: EdgeInsets.all(10.0),
      children: [
        SizedBox(
          height: 20,
        ),
        new Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    bill_type = 1;
                    bill_type_str = "Sign In";
                  });
                },
                child: new Row(
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      color: bill_type == 1 ? colorPrimary : Colors.grey,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text("Chalan",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: bill_type == 1 ? colorPrimary : Colors.grey,
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: new InkWell(
                child: new Row(
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      color: bill_type == 2 ? colorPrimary : Colors.grey,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text("Bill",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: bill_type == 2 ? colorPrimary : Colors.grey,
                        )),
                  ],
                ),
                onTap: () {
                  setState(() {
                    bill_type = 2;
                    bill_type_str = "Sign Out";
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        BillChalanNoFeild(),
        getDateFeild(),
        SizedBox(
          height: 20,
        ),
        DivInfoFeild(),
        TotalItemFeild(),
        getDurationInt(),
        SizedBox(
          height: 20,
        ),
        new Row(
          children: [
            Expanded(
              child: GetPostItemBtn(),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: GetCancelItemBtn(),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: GetSaveItemBtn(),
            ),
          ],
        ),
      ],
    );
  }

  List<String> durationIntItems = new List();

  String durationInt = "0";
  getDurationInt() {
    return new Theme(
        data: GlobalConstant.getSpinnerTheme(context),
        child: DropdownButton<String>(
          value: durationInt,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: GlobalConstant.getTextStyle(),
          underline: GlobalConstant.getUnderline(),
          onChanged: (String data) {
            setState(() {
              durationInt = data;
            });
          },
          items: durationIntItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
  }

  var DateController = TextEditingController();
  final dateFormat = DateFormat("yyyy-MM-dd");
  DateTime selectedDateTime = DateTime.now();
  String _frdate = "";
  var BillChalanNoController = TextEditingController();

  BillChalanNoFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      maxLength: 25,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: BillChalanNoController,
      decoration: GlobalWidget.TextFeildDecoration1("Bill/Chalan No"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter BillChalanNo';
        }
        return null;
      },
    );
  }

  var TotalItemController = TextEditingController();
  TotalItemFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      maxLength: 5,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: TotalItemController,
      decoration: GlobalWidget.TextFeildDecoration1("Total Item"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter Total Item';
        }
        return null;
      },
    );
  }

  var DivInfoController = TextEditingController();
  DivInfoFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      maxLength: 250,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: DivInfoController,
      decoration: GlobalWidget.TextFeildDecoration1("DIv Info"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter Div Info';
        }
        return null;
      },
    );
  }

  getDateFeild() {
    return DateTimeField(
      controller: DateController,
      onShowPicker: (context, currentValue) async {
        return showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: selectedDateTime.subtract(new Duration(days: 365 * 20)),
          lastDate: selectedDateTime,
          builder: (BuildContext context, Widget child) {
            return Theme(
              data: ThemeData.light(),
              child: child,
            );
          },
        );
      },
      decoration: InputDecoration(labelText: 'Date'),
      format: dateFormat,
      onChanged: (val) {
        _frdate = dateFormat.format(val);

        // Utility.setStringPreference(GlobalConstant.FROM_DATE_Report, _frdate);
      },
    );
  }

  @override
  void initState() {
    getValueData();
  }

  GetPostItemBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UpdatePgiNumber()));
      },
      child: Text(
        'Post Item',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetCancelItemBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UpdatePgiNumber()));
      },
      child: Text(
        'Cancel',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetSaveItemBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UpdatePgiNumber()));
      },
      child: Text(
        'Save',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  String TAG = "IndentDetailActivity";
  void getValueData() async {
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    String COCO_CITY = (await Utility.getStringPreference(GlobalConstant.COCO_CITY_ID));
    Utility.log("tag", COCO_CITY);

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.PInw_Combo,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': null,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, "Response: " + data1.toString());
          if (data1['status'] == 0) {
            if (data1['ds']['tables'].length > 0) {
              var list = data1['ds']['tables'][0]['rowsList'];
              for (int i = 0; i < list.length; i++) {
                String cityId = list[i]['cols']["CityId"];
                if (cityId != COCO_CITY) continue;
                durationIntItems.add(list[i]['cols']["PartyName"].toString());
                durationInt = durationIntItems[0].toString();
              }

              setState(() {});
              //  SetListInItem(list);
            }
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
