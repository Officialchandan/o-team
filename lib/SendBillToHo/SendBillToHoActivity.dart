import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SendBillToHo/model/SendBillToHoModel.dart';

class SendBillToHoActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SendBillToHoView();
  }
}

class SendBillToHoView extends State<SendBillToHoActivity> {
  TextEditingController _remarkController = TextEditingController();

  var TAG = "SendBillToHoView";
  String userID = "", IwId = "";

  List<SendBillToHoModel> duplicateItems = List<SendBillToHoModel>();
  List<SendBillToHoModel> items = List<SendBillToHoModel>();

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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(bottom: 80),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: Container(
                    color: IwId == ""
                        ? Colors.white
                        : IwId == items[index].iwId
                            ? Colors.pink
                            : Colors.white,
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
                                      "PGI No : " + items[index].pgiNo,
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
                    setState(() {
                      IwId = "";
                      IwId = items[index].iwId;
                    });
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: TextFormField(
                      controller: _remarkController,
                      // keyboardType: TextInputType.number,
                      keyboardType: TextInputType.text,
                      //textInputAction: TextInputAction.done,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                          hintText: "Enter Remark",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide())),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          shape: GlobalWidget.getButtonTheme(),
                          color: GlobalWidget.getBtncolor(),
                          textColor: GlobalWidget.getBtnTextColor(),
                          onPressed: () {
                            if (IwId != "") {
                              _SendBill();
                            } else {
                              GlobalWidget.showToast(context, "Please select any one bill...");
                            }
                          },
                          child: Text(
                            'Send',
                            style: GlobalWidget.textbtnstyle(),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> UpdateData() async {
    duplicateItems = new List();
    items = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="14143";
    var data = GlobalConstant.GetMapForCPID(COCO_ID);
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.BillToDC_List,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
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

  void _addBook(dynamic book) {
    setState(() {
      duplicateItems.add(new SendBillToHoModel(
          book['PGI'].toString(),
          book['InwDt'].toString(),
          book['InwBy'].toString(),
          book['PoId'].toString(),
          book['Supplier'].toString(),
          book['InvoiceDt'].toString(),
          book['InvoiceNo'].toString(),
          book['InvoiceAmt'].toString(),
          book['IWID'].toString()));
    });
  }

  Future<void> _SendBill() async {
    duplicateItems = new List();
    items = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="14143";
    var data = GlobalConstant.GetMapToSendBill(IwId, _remarkController.text.toString().trim());
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.BillToDC_Send,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          if (data1['status'] == 0) {
            GlobalWidget.showToast(context, "Sent Successfully...");
            _remarkController.text = "";
            UpdateData();
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
