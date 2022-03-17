import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SentBillHistory/model/SentBillHistoryModel.dart';

class SentBillHistoryActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SentBillHistoryView();
  }
}

class SentBillHistoryView extends State<SentBillHistoryActivity> {
  var TAG = "SentBillHistoryView";
  String userID = "";

  List<SentBillHistoryModel> duplicateItems = List<SentBillHistoryModel>();
  List<SentBillHistoryModel> items = List<SentBillHistoryModel>();

  @override
  void initState() {
    super.initState();
    UpdateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalWidget.getAppbar("Send Bills"),
      body: getWidget(),
    );
  }

  getWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child: Container(
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
                                "IWID : " + items[index].iwId,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "InwDt : " + items[index].inwDt,
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
                                "InwBy : " + items[index].inwBy,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "PoId : " + items[index].poId,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        new Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "Supplier : " + items[index].supplier,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "Invoice Dt : " + items[index].invoiceDt,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        new Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "InvoiceNo : " + items[index].invoiceNo,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "InvoiceAmt : " + items[index].invoiceAmt,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        new Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "SendBy : " + items[index].sendBy,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: new Text(
                                "SendDt : " + items[index].sendDt,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: new Text(
                                "DCSendRMK : " + items[index].sendRmk,
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2.0,
                  )
                ],
              ),
            ),
            onTap: () {
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Future<void> UpdateData() async {
    duplicateItems = new List();
    items = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    var data = GlobalConstant.GetMapForCPID(COCO_ID);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.BillToDC_History,
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
            Utility.log(TAG, data1);
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
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  void _addBook(dynamic book) {
    setState(() {
      duplicateItems.add(new SentBillHistoryModel(
          book['InvoiceNo'].toString(),
          book['IWID'].toString(),
          book['InwBy'].toString(),
          book['PGI'].toString(),
          book['InvoiceDt'].toString(),
          book['InwDt'].toString(),
          book['Supplier'].toString(),
          book['SendBy'].toString(),
          book['PoId'].toString(),
          book['InvoiceAmt'].toString(),
          book['SendDt'].toString(),
          book['DCRcvRmk'].toString() == null ||
                  book['DCRcvRmk'].toString().isEmpty
              ? ""
              : book['DCSendRmk'].toString()));
    });
  }
}
