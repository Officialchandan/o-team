import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SacnBill/UpdatePgiNumber.dart';
import 'package:ondoprationapp/SearchModel/SearchModel.dart';
import 'package:ondoprationapp/transfer_validation/data_table.dart';
import 'package:ondoprationapp/transfer_validation/my_data_row.dart';
import 'package:ondoprationapp/transfer_validation/ond_op_app.dart';
import 'package:rxdart/rxdart.dart';

import '../transfer_validation/db_model/db_model.dart';
import 'ShowAndUploadBillDetail.dart';

class ScanBillActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReportView();
  }
}

class ReportView extends State<ScanBillActivity> {
  final subject = PublishSubject<String>();
  TextEditingController controller = TextEditingController();
  bool _isLoading = false;
  List<SearchModel> duplicateItems = [];
  List<ModelData> spinnerItems = [];

  List<SearchModel> items = [];
  var products;
  var listdata;

  var TAG = "ReprtDetailClass";

  @override
  void initState() {
    updateData();
    getSpinnerItem();

    subject.stream.listen(_textChanged);
    print("initState working-->");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateData() async {
    print("subject-->$subject");

    items = [];
    duplicateItems = [];
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="14143";
    var data = GlobalConstant.GetMapForBillScan(COCO_ID);

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Inw_ScanPending,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        Map<String, dynamic> data = await apiController.post(url: GlobalConstant.SignUp, input: map2());

        Dialogs.hideProgressDialog(context);
        var data1 = data;

        print("data1--->$data1");
        print("data--->$data");

        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var products = data1['ds']['tables'][0]['rowsList'];
            for (int i = 0; i < products.length; i++) {
              _addBook(products[i]['cols']);
            }
            items.addAll(duplicateItems);
            print("items-->$items");
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
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
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
      apiController.post(url: GlobalConstant.SignUp, input: map2()).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          Map<String, dynamic> data1 = data;
          print("MApp_GetScanDocType1--->$data1");
          print("MApp_GetScanDocType--->$data");
          if (data1['status'] == 0) {
            if (data1['ds']['tables'].length > 0) {
              var products = data1['ds']['tables'][0]['rowsList'];
              for (int i = 0; i < products.length; i++) {
                var str = products[i]['cols']["ScnType"];
                var parts = str.split(',');
                for (int i = 0; i < parts.length; i++) {
                  spinnerItems.add(ModelData(parts[i].toString(), false));
                  print("spinnerItems-->$spinnerItems");
                }

                /*  spinnerItems = [
                  products[i]['cols']["ScnType"].toString()
                ];*/
                // Utility.log(tAG, spinnerItems);
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

  Future _textChanged(String text) async {
    List<SearchModel> dummySearchList = [];
    dummySearchList.addAll(duplicateItems);
    if (text.isNotEmpty) {
      List<SearchModel> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.title.toLowerCase().contains(text.toLowerCase())) {
          dummyListData.add(item);
          print("dummylistData--$dummyListData");
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  void _addBook(dynamic book) {
    print("_addBook");

    setState(() {
      String name = book['DocDate'].toString() + " " + book['Supplier'].toString() + " " + book['DocNo'].toString() + " ";
      duplicateItems.add(SearchModel(name.trim(), "${book["ItName"]}", book));
      print("duplicateItems--$duplicateItems");
    });
  }

  //FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: GlobalWidget.getAppbar("Scan Bill"),
        // body: Container(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     // children: <Widget>[
        //     //   Container(
        //     //     height: 50.0,
        //     //     color: Colors.grey[300],
        //     //     child: Row(
        //     //       children: <Widget>[
        //     //         Expanded(
        //     //           child: new Container(
        //     //               width: MediaQuery.of(context).size.width,
        //     //               child: Row(
        //     //                 children: <Widget>[
        //     //                   Expanded(
        //     //                     flex: 1,
        //     //                     child: Container(
        //     //                       alignment: Alignment.center,
        //     //                       child:
        //     //                           Icon(Icons.search, color: Colors.black),
        //     //                     ),
        //     //                   ),
        //     //                   Expanded(
        //     //                     flex: 8,
        //     //                     child: Container(
        //     //                       padding: EdgeInsets.only(left: 20.0),
        //     //                       child: TextField(
        //     //                         controller: controller,
        //     //                         cursorColor: Colors.black,
        //     //                         decoration: InputDecoration(
        //     //                             hintText: GlobalConstant.SearchHint,
        //     //                             border: InputBorder.none),
        //     //                         onChanged: (value) {
        //     //                           print("Value--->$value");
        //     //                           subject.add(value);
        //     //                           print("AddValue--->$value");
        //     //                         },
        //     //                       ),
        //     //                     ),
        //     //                   ),
        //     //                   Expanded(
        //     //                     flex: 1,
        //     //                     child: Container(
        //     //                       alignment: Alignment.centerRight,
        //     //                       child: new IconButton(
        //     //                         icon: Image.asset(
        //     //                           "drawable/clean.png",
        //     //                           color: Colors.black,
        //     //                         ),
        //     //                         iconSize: 20.0,
        //     //                         onPressed: () {
        //     //                           controller.clear();
        //     //                           subject.add("");
        //     //                           // onSearchTextChanged('');
        //     //                         },
        //     //                       ),
        //     //                     ),
        //     //                   )
        //     //                 ],
        //     //               )),
        //     //         ),
        //     //       ],
        //     //     ),
        //     //   ),
        //       // _isLoading
        //       //     ? Center(
        //       //         child: CircularProgressIndicator(),
        //       //       )
        //       //     : Container(),
        //       // Expanded(
        //       //   child: items.length == 0 ? Container() : _buildChart(),
        //       // ),
        //
        //
        //     ],
        //   ),
        // ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            pgiScanButton(),
            okToSendButton(appHeight: appHeight),
          ],
        ),
      ),
    );
  }

  //Create a form
  Widget _buildChart() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: items[index].data["Typ"].toString() == "NewScan" ? Colors.white : colorPrimary,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(items[index].data["DocNo"].toString()),
                        ),
                        Expanded(
                          child: Text(
                            items[index].data["DocDate"].toString(),
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "PO. " + items[index].data["PoId"].toString(),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(
                            items[index].data["Supplier"].toString(),
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "InvNo. " + items[index].data["InvoiceNo"].toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(
                            "Inv Date : " + items[index].data["InvoiceDt"].toString(),
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                        )
                      ],
                    ),
                    Text(items[index].data["Typ"].toString(), style: TextStyle(color: Colors.red))
                  ],
                ),
              ),
              Divider(
                thickness: 2.0,
              )
            ],
          ),
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                  builder: (_) => ShowBillDetails(
                        data: items[index].data,
                      )),
            )
                .then((val) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ScanBillActivity()));
            });
          },
        );
      },
    );
  }

  pgiScanButton() {
    return MaterialButton(
      color: Color(0xFFd6d8d7),
      textColor: Colors.black,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UpdatePgiNumber()));
      },
      child: Text(
        'PGI SCAN',
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 16.0),
      ),
    );
  }

  okToSendButton({double appHeight}) {
    return MaterialButton(
      color: Color(0xFFd6d8d7),
      textColor: Colors.black,
      onPressed: () async {
        // await getSpinnerItem();
        await getPendingList();

        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black45,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
            return Container(
              height: appHeight,
              color: Colors.white,
              margin: EdgeInsets.only(
                top: 35,
                right: 16,
                left: 16,
                bottom: 15,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 0,
                    child: Column(
                      children: [
                        Text(
                          "Ok To Send Document List",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 7.0,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 13,
                    child: Column(
                      children: [
                        Container(
                          height: appHeight * 0.827,
                          color: Colors.grey.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        MaterialButton(
                          color: Colors.grey,
                          height: 30,
                          minWidth: 50,
                          child: Text("CLOSE"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Text(
        'OKTOSEND DOCUMENT',
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 16.0),
      ),
    );
  }

  // bool loadOkDocListFlag = false;

  Future<void> getPendingList() async {
    print("getPendingList-->>>");
    String pid = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    print("COCO_ID-->$pid");
    String dbPassword = await Utility.getStringPreference(GlobalConstant.USER_PASSWORD);
    String dbUser = await Utility.getStringPreference(GlobalConstant.USER_ID);

    DBRequestModel dbr = DBRequestModel();
    dbr.setDbUser(dbUser);
    dbr.setDbPassword(dbPassword);
    dbr.setSrvId(OndOpApp.srvId);
    dbr.setProcName("ScanInv_PendList");
    dbr.setTimeout(30);
    MyDataTable dt = MyDataTable("param");
    MyDataRow r1 = MyDataRow();
    r1.add("pname", "CocoPId");
    r1.add("value", pid);
    dt.addRow(r1);
    dbr.setParam(dt);
    Map<String, dynamic> json = dbr.toJson();

    if (await NetworkCheck.check()) {
      EasyLoading.show(status: 'loading...');

      ApiController apiController = ApiController.internal();

      apiController.post(url: GlobalConstant.SignUp, input: json).then((value) {
        try {
          EasyLoading.dismiss();
          Map<String, dynamic> data = value;
          print("responseData-->>${data.toString()}");
          if (data['status'] == 0) {
            print("Data Close");
          } else {
            if (data['msg'].toString() == "Login failed for user") {
              GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
            } else {
              GlobalWidget.showMyDialog(context, "Error", data['msg'].toString());
            }
          }
        } catch (exception) {
          GlobalWidget.showMyDialog(context, "Error", "" + exception.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }
}

class RetrieveModel {
  var data;

  RetrieveModel(this.data);
}
