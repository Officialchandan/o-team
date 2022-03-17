import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/ReviewAudit/FillStoreReviewAuditClass.dart';

class StoreAuditHistoryActivity extends StatefulWidget {
  String Cocoid;

  StoreAuditHistoryActivity(this.Cocoid);

  @override
  State<StatefulWidget> createState() {
    return StoreAuditHistoryView();
  }
}

class StoreAuditHistoryView extends State<StoreAuditHistoryActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalWidget.getAppbar("Audit Review List"),
      body: Container(
        child: products == null ? new Container() : getWidget(),
      ),
    );
  }

  String userID;

  @override
  void initState() {
    super.initState();
    UpdateData();
  }

  getWidget() {
    return ListView.builder(
      itemCount: products.length,
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
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text(
                                  "Audit Id  ",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                new Text(
                                  products[index]["cols"]["AudId"],
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 4,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                "Manager",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              new Text(
                                products[index]["cols"]["Manager"].toString(),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: /*new Text(
                            "Audit Dt : " + products[index]["cols"]["UpdDt"],
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.end,
                          ),*/
                                new Container(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StoreReviewAudit(
                                                  products[index]["cols"])));
                                },
                                child: Icon(
                                  Icons.mode_edit,
                                  size: 25,
                                ),
                              ),
                            ))
                      ],
                    ),
                    new Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                "entryStartDt",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              new Text(
                                products[index]["cols"]["EntryStartDt"]
                                    .toString(),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                "Updated at ",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              new Text(
                                products[index]["cols"]["UpdDt"].toString(),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    new Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                "COCO",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              new Text(
                                products[index]["cols"]["Coco"].toString(),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                "Audit By ",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              new Text(
                                products[index]["cols"]["AudBy"].toString(),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
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
            //    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailEntryActivity(items[index].auditId,null)));
          },
        );
      },
    );
  }

  var products;

  Future<void> UpdateData() async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="14143";

    Map<String, dynamic> map() => {
          'pname': 'CocoPID',
          'value': widget.Cocoid,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = map1();
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Scr_History,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      apiController
          .postsNew(GlobalConstant.SignUp, json.encode(map2()))
          .then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          if (data1['status'] == 0) {
            if (data1['ds']['tables'].length > 0) {
              products = data1['ds']['tables'][0]['rowsList'];
              Utility.log("TAG", products);
              setState(() {});
              /*   Utility.log(TAG, data1);
              duplicateItems.clear();
              for (int i = 0; i < products.length; i++) {
                _addBook(products[i]['cols']);
              }
              items.clear();
              items.addAll(duplicateItems);
              Utility.log(TAG, items.length);*/
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
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }
}
