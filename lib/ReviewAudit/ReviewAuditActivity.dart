import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/ReviewAudit/DetailEntryActivity.dart';
import 'package:ondoprationapp/ReviewAudit/model/ReviewAuditModel.dart';

class ReviewAuditActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReviewAuditView();
  }
}

class ReviewAuditView extends State<ReviewAuditActivity> {
  var TAG = "ReviewAuditView";
  String userID = "";

  List<ReviewAuditModel> duplicateItems = List<ReviewAuditModel>();
  List<ReviewAuditModel> items = List<ReviewAuditModel>();

  @override
  void initState() {
    super.initState();
    UpdateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalWidget.getAppbar("Audit Review List"),
      body: Container(
        child: getWidget(),
      ),
    );
  }

  getWidget() {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                padding: EdgeInsets.all(10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: new Text(
                            "Audit Id : " + items[index].auditId,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: new Text(
                            "Audit Dt : " + items[index].auditDt,
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: new Text(
                            "Audit By : " + items[index].auditBy,
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: new Text(
                            "Audit Type : " + items[index].auditType,
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 2.0,
              )
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DetailEntryActivity(items[index].auditId, null)));
          },
        );
      },
    );
  }

  Future<void> UpdateData() async {
    duplicateItems = new List();
    items = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="14143";
    var data = GlobalConstant.GetMapForRetrival(COCO_ID);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Scr_ReviewList,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var products = data1['ds']['tables'][0]['rowsList'];

            Utility.log(TAG, data1);
            duplicateItems.clear();
            for (int i = 0; i < products.length; i++) {
              _addBook(products[i]['cols']);
            }
            items.clear();
            items.addAll(duplicateItems);
            Utility.log(TAG, items.length);
            setState(() {});
          }
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error",
                "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(
                context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(
            context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  void _addBook(dynamic book) {
    setState(() {
      duplicateItems.add(new ReviewAuditModel(
          book['AudId'].toString(),
          book['AudDt'].toString(),
          book['AudBy'].toString(),
          book['AudType'].toString()));
    });
  }
}
