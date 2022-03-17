import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/transfer_validation/data_table.dart';
import 'package:ondoprationapp/transfer_validation/db_model/db_model.dart';
import 'package:ondoprationapp/transfer_validation/my_data_row.dart';
import 'package:ondoprationapp/transfer_validation/ond_op_app.dart';

import 'ShowAndUploadBillDetail.dart';

class UpdatePgiNumber extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PgiView();
  }
}

class PgiView extends State<UpdatePgiNumber> {
  final pONumberController = TextEditingController();
  String dropdownValue = "";
  List<ModelData> spinnerItems = [];
  String tAG = "TAG";

  @override
  void initState() {
    getSpinnerItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalWidget.getAppbar("Update PGI"),
      body: ListView(
        children: [
          SizedBox(
            height: 40,
          ),
          spinnerItems.length > 0 ? selectOption() : Container(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: pONumberField(),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: getItemLisButton(context),
          ),
        ],
      ),
    );
  }

  pONumberField() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      maxLength: 20,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: pONumberController,
      decoration: GlobalWidget.TextFeildDecoration("PGI Number"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter PGI number';
        }
        return null;
      },
    );
  }

  selectOption() {
    return Container(
      child: ListView.builder(
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                for (int i = 0; i < spinnerItems.length; i++) {
                  spinnerItems[i].val = false;
                }
                spinnerItems[index].val = true;
                setState(() {});
              },
              child: makeCard(context, index, spinnerItems[index].data),
            );
          },
          itemCount: spinnerItems.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true),
    );
  }

  Future<void> getSpinnerItem() async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.MApp_GetScanDocType,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': null,
        };

    ApiController apiController = ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          if (data1['status'] == 0) {
            if (data1['ds']['tables'].length > 0) {
              var products = data1['ds']['tables'][0]['rowsList'];
              for (int i = 0; i < products.length; i++) {
                var str = products[i]['cols']["ScnType"];
                var parts = str.split(',');
                for (int i = 0; i < parts.length; i++) {
                  spinnerItems.add(ModelData(parts[i].toString(), false));
                }

                /*  spinnerItems = [
                  products[i]['cols']["ScnType"].toString()
                ];*/
                Utility.log(tAG, spinnerItems);
                setState(() {});
              }
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
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  getItemLisButton(context) {
    return MaterialButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () async {
        bool flag = false;
        String scanType = "";
        for (int i = 0; i < spinnerItems.length; i++) {
          if (spinnerItems[i].val == true && spinnerItems[i].data != "SELECT") {
            flag = true;
            scanType = spinnerItems[i].data;
          }
        }
        if (flag == false) {
          GlobalWidget.GetToast(context, "Select Scan Document Type");
          return;
        } else if (pONumberController.text.toString().length < 4) {
          GlobalWidget.GetToast(context, "Enter valid PGI NO");
          return;
        } else {
          await submitPoItemData(context);
        }
      },
      child: Text(
        'SUBMIT',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  Future<void> submitPoItemData(context) async {
    String dbPassword = await Utility.getStringPreference(GlobalConstant.USER_PASSWORD);
    String dbUser = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    String pid = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    print("pid---->$pid");
    print("dbPassword---->$dbPassword");
    print("dbUser---->$dbUser");
    DBRequestModel dbr = DBRequestModel();
    dbr.setDbUser(dbUser);
    dbr.setDbPassword(dbPassword);
    dbr.setSrvId(OndOpApp.srvId);
    dbr.setProcName("mApp_SearchPGI");
    dbr.setTimeout(30);
    MyDataTable dt = MyDataTable("param");
    MyDataRow r1 = MyDataRow();
    r1.add("pname", "CocoId");
    r1.add("value", "$pid");
    dt.addRow(r1);
    MyDataRow r2 = MyDataRow();
    r2.add("pname", "DocNo");
    r2.add("value", pONumberController.text.trim());
    dt.addRow(r2);
    dbr.setParam(dt);
    Map<String, dynamic> searchPOI = dbr.toJson();
    print("setParam-$searchPOI");
    ApiController apiController = ApiController.internal();

    if (await NetworkCheck.check()) {
      EasyLoading.show(status: "Loading...");

      Map<String, dynamic> response = await apiController.post(url: GlobalConstant.SignUp, input: searchPOI);

      EasyLoading.dismiss();

      try {
        if (response['status'] == 0) {
          print("supplier--->");
          print(response["ds"]["tables"][0]["rowsList"][0]["cols"]["SPID"]);
          String pgiNo = pONumberController.text.trim();
          String scanType = "direct";
          String supplier = response["ds"]["tables"][0]["rowsList"][0]["cols"]["SPID"] == null
              ? "NA"
              : response["ds"]["tables"][0]["rowsList"][0]["cols"]["SPID"].toString().toString();
          String did = response["ds"]["tables"][0]["rowsList"][0]["cols"]["DID"].toString();

          Map<String, dynamic> data = {"pgiNo": pgiNo, "scanType": scanType, "supplier": supplier, "did": did};

          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShowBillDetails(
                        data: data,
                      )));

          Navigator.pop(context);
        } else {
          if (response['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(context, "Error", response['msg'].toString());
          }
        }
      } catch (e) {
        GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
      }
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  makeCard(BuildContext context, int index, String spinnerItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Icon(spinnerItems[index].val == false ? Icons.radio_button_unchecked : Icons.radio_button_checked),
            ),
            Expanded(
              flex: 8,
              child: Text(spinnerItem),
            )
          ],
        ),
        Divider(),
      ],
    );
  }
}

class ModelData {
  String data;

  ModelData(this.data, this.val);

  bool val;
}
