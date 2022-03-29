import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/PublishResult.dart';

class ListBasedStockAuditActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StockView();
  }
}

class StockView extends State<ListBasedStockAuditActivity> {
  List<RetriveModel> RefreshList_items = new List();
  List<RetriveModel> DisputeList_items = new List();
  List<RetriveModel> CloseList_items = new List();

  final subject = new PublishSubject<String>();
  bool _isLoading = false;
  List<RetriveModel> duplicateItems_Refresh = List<RetriveModel>();
  List<RetriveModel> duplicateItems_Despute = List<RetriveModel>();
  List<RetriveModel> duplicateItems_Close = List<RetriveModel>();

  int active = 1;
  int current_index = 0;
  bool TransitAndLgsStatus = false;

  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: new Scaffold(
          appBar: GlobalWidget.getAppbar("List Based Stock Audit"),
          bottomNavigationBar: new Container(
            color: Colors.grey[300],
            padding: EdgeInsets.only(top: 4.0),
            alignment: Alignment.center,
            height: 30.0,
            child: Column(
              children: [
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: new InkWell(
                        onTap: () {
                          setState(() {
                            active = 1;
                            GetRefreshList();
                            setState(() {});
                          });
                        },
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "  REFRESH",
                              style:
                                  active == 1 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                            ),
                            new Container(
                              padding: GlobalWidget.getpaddingNavBottom(),
                              decoration: active == 1 ? GlobalWidget.getDecoration(true) : GlobalWidget.getDecoration(false),
                              constraints: GlobalWidget.getBoxConstraint(),
                              child: new Text(
                                '(${RefreshList_Count.toString()})',
                                style: active == 1 ? GlobalWidget.getTextStyle(true) : GlobalWidget.getTextStyle(false),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: new InkWell(
                        onTap: () {
                          GetDisputeList();

                          setState(() {
                            //
                          });
                          active = 2;
                        },
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "DISPUTE",
                              style:
                                  active == 2 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                            ),
                            new Container(
                              padding: GlobalWidget.getpaddingNavBottom(),
                              decoration: active == 2 ? GlobalWidget.getDecoration(true) : GlobalWidget.getDecoration(false),
                              constraints: GlobalWidget.getBoxConstraint(),
                              child: new Text(
                                '(${DisputeList_Count.toString()})',
                                style: active == 2 ? GlobalWidget.getTextStyle(true) : GlobalWidget.getTextStyle(false),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: new InkWell(
                        onTap: () {
                          GetCloseList();
                          setState(() {
                            active = 3;
                            //getnotfound();
                          });
                        },
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "CLOSE",
                              style:
                                  active == 3 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                            ),
                            new Container(
                              padding: GlobalWidget.getpaddingNavBottom(),
                              decoration: active == 3 ? GlobalWidget.getDecoration(true) : GlobalWidget.getDecoration(false),
                              constraints: GlobalWidget.getBoxConstraint(),
                              child: new Text(
                                '(${CloseList_Count.toString()})',
                                style: active == 3 ? GlobalWidget.getTextStyle(true) : GlobalWidget.getTextStyle(false),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: getListingOntheData()),
    );
  }

  getListingOntheData() {
    return new ListView(
      padding: EdgeInsets.all(8.0),
      shrinkWrap: true,
      children: [
        new Form(
          child: new Column(
            children: [
              new Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: ItemNameFeild(),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    flex: 2,
                    child: GetImagePickerBtn(),
                  ),
                ],
              ),
              getstock == true
                  ? new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Item_name == ""
                            ? new Container()
                            : InkWell(
                                child: GlobalWidget.showItemName(Item_name),
                                onTap: () {
                                  GlobalConstant.OpenZoomImage(data1_upd, context);
                                },
                              ),
                        SizedBox(
                          height: 10.0,
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Lg Stock : " + data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['Stock'],
                                style: TextStyle(color: colorPrimary),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text("In Transit : " + data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['InTransit'],
                                  style: TextStyle(color: colorPrimary), textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: Text("MRP : " + data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['Mrp'].toString()),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: Text("ORP: " + data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['Orp'].toString(),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ],
                    )
                  : new Container(),
              new Column(
                children: [
                  StockIdFeild(),
                  RemarkFeild(),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              new Row(
                children: [
                  Expanded(
                    child: GetUpdateBtn(),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: GetResetBtn(),
                  ),
                ],
              ),
            ],
          ),
          key: _formKey,
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          color: Colors.grey[300],
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: new Container(
                  alignment: Alignment.center,
                  child: new Icon(Icons.search, color: Colors.black),
                ),
              ),
              Expanded(
                flex: 8,
                child: new Container(
                  padding: EdgeInsets.only(left: 20.0),
                  child: new TextField(
                    //focusNode: _focusNode,
                    //  autofocus: true,
                    controller: controller,
                    cursorColor: Colors.black,
                    decoration: new InputDecoration(hintText: GlobalConstant.SearchHint, border: InputBorder.none),
                    onChanged: (value) {
                      subject.add(value);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: new IconButton(
                    icon: Image.asset(
                      "drawable/clean.png",
                      color: Colors.black,
                    ),
                    iconSize: 20.0,
                    onPressed: () {
                      controller.clear();
                      subject.add("");
                      // onSearchTextChanged('');
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        getListingOntheBasisOfCondition(),
      ],
    );
  }

  @override
  void initState() {
    getSearchItems();
    GetRefreshList();
    GetDisputeList();
    GetCloseList();
    subject.stream.listen(_textChanged);
  }

  Future _textChanged(String text) async {
    List<RetriveModel> dummySearchList = List<RetriveModel>();
    switch (active) {
      case 1:
        dummySearchList.addAll(duplicateItems_Refresh);
        break;
      case 2:
        dummySearchList.addAll(duplicateItems_Despute);
        break;
      case 3:
        dummySearchList.addAll(duplicateItems_Close);
        break;
    }

    if (text.isNotEmpty) {
      List<RetriveModel> dummyListData = List<RetriveModel>();
      dummySearchList.forEach((item) {
        if (item.data['ItName'].toString().toLowerCase().contains(text.toLowerCase()) ||
            item.data['Itid'].toString().toLowerCase().contains(text.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        switch (active) {
          case 1:
            RefreshList_items.clear();
            RefreshList_items.addAll(dummyListData);
            break;
          case 2:
            DisputeList_items.clear();
            DisputeList_items.addAll(dummyListData);
            break;
          case 3:
            CloseList_items.clear();
            CloseList_items.addAll(dummyListData);
            break;
        }
      });
      return;
    } else {
      setState(() {
        switch (active) {
          case 1:
            RefreshList_items.clear();
            RefreshList_items.addAll(duplicateItems_Refresh);
            break;
          case 2:
            DisputeList_items.clear();
            DisputeList_items.addAll(duplicateItems_Despute);
            break;
          case 3:
            CloseList_items.clear();
            CloseList_items.addAll(duplicateItems_Close);
            break;
        }
      });
    }
  }

  var data1_upd;
  String TAG = "ListBasedStockAuditActivity";
  String InTransit = "";
  String Stock = "";
  bool getstock = false;
  Future<void> GetRefreshList() async {
    RefreshList_items = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    var data = GlobalConstant.GetMapForListBasedStockAudit(COCO_ID, "Fresh");
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String Item_Id = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': Item_Id,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.StkTkngBlk_GetList,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var list = data1['ds']['tables'][0]['rowsList'];
            SetListInItem(list);
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
      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {} catch (e) {
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  Future<void> GetDisputeList() async {
    DisputeList_items = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    var data = GlobalConstant.GetMapForListBasedStockAudit(COCO_ID, "ReView");

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String Item_Id = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': Item_Id,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.StkTkngBlk_GetList,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var list = data1['ds']['tables'][0]['rowsList'];
            SetListInItemDispute(list);
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
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  Future<void> SubmitItemDetail() async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map3() => {
          'pname': 'itid',
          'value': SelectedListId,
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'LgStock',
          'value': Stock,
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());

    Map<String, dynamic> map5() => {
          'pname': 'ActStock',
          'value': StockIdController.text.toString(),
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };

    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'Remark',
          'value': RemarkController.text.toString(),
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };

    a1.add(mapobj6());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = map1();

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.WhrCntr_save,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          GlobalWidget.showToast(context, "Stock Updated Successfully");
          updateReset();
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
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  Future<void> GetCloseList() async {
    CloseList_items = new List();
    var data = GlobalConstant.GetMapForListBasedStockAuditClose(SelectedListId);
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String Item_Id = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': Item_Id,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.StkTkngBlk_Close,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var list = data1['ds']['tables'][0]['rowsList'];
            SetListInItemClose(list);
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
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  void SetListInItem(list) {
    duplicateItems_Refresh = new List();
    RefreshList_Count = 0;
    SelectedListId = list[0]['cols']['Stbhid'];
    for (int i = 0; i < list.length; i++) {
      int type = 2;
      RefreshList_Count = RefreshList_Count + 1;
      duplicateItems_Refresh.add(new RetriveModel(list[i]['cols'], type));
    }
    RefreshList_items.addAll(duplicateItems_Refresh);
    setState(() {});
  }

  String SelectedListId = "";

  void SetListInItemDispute(list) {
    duplicateItems_Despute = new List();
    DisputeList_items = new List();
    DisputeList_Count = 0;
    for (int i = 0; i < list.length; i++) {
      int type = 2;

      DisputeList_Count = DisputeList_Count + 1;
      duplicateItems_Despute.add(new RetriveModel(list[i]['cols'], type));
    }
    DisputeList_items.addAll(duplicateItems_Despute);
    setState(() {});
  }

  void SetListInItemClose(list) {
    duplicateItems_Close = new List();
    CloseList_Count = 0;
    for (int i = 0; i < list.length; i++) {
      int type = 3;

      CloseList_Count = CloseList_Count + 1;

      duplicateItems_Close.add(new RetriveModel(list[i]['cols'], type));
    }
    CloseList_items.addAll(duplicateItems_Close);
    setState(() {});
  }

  Future<void> _refresh() {
    GetRefreshList();
  }

  int RefreshList_Count = 0;
  int DisputeList_Count = 0;
  int CloseList_Count = 0;

  void getCount() {
    DisputeList_Count = 0;
    CloseList_Count = 0;
    for (int i = 0; i < RefreshList_items.length; i++) {
      if (RefreshList_items[i].type == 1) {
        DisputeList_Count = DisputeList_Count + 1;
      }
      if (RefreshList_items[i].type == 2) {
        CloseList_Count = CloseList_Count + 1;
      }
      RefreshList_Count = RefreshList_Count + 1;
    }
  }

  getRowDataContainer(var data1) {
    return new Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Text(data1.data['ItName'].toString(), style: TextStyle(color: Colors.black, fontSize: 14.0)),
          new Row(
            children: [
              Expanded(
                child: new Container(
                  alignment: Alignment.centerLeft,
                  child: new Text(
                    "ListId : " + data1.data['Stbhid'].toString(),
                    style: TextStyle(color: Colors.blue, fontSize: 12.0),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: new Text(
                  "ItmId : " + data1.data['Itid'].toString(),
                  style: TextStyle(color: colorPrimary, fontSize: 12.0),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1.0,
          )
        ],
      ),
    );
  }

  getListingOntheBasisOfCondition() {
    if (active == 1) {
      return new ListView.builder(
          itemCount: RefreshList_items.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext ctxt, int index) {
            return new InkWell(
              onTap: () {},
              child: getRowDataContainer(RefreshList_items[index]),
            );
          });
    } else if (active == 2) {
      return new ListView.builder(
          itemCount: DisputeList_items.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext ctxt, int index) {
            return new InkWell(
              onTap: () {},
              child: getRowDataContainer(DisputeList_items[index]),
            );
          });
    } else {
      return new ListView.builder(
          itemCount: CloseList_items.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext ctxt, int index) {
            return new InkWell(
              onTap: () {},
              child: getRowDataContainer(CloseList_items[index]),
            );
          });
    }
  }

  final _formKey = GlobalKey<FormState>();

  GetUpdateBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        Stock = data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['Stock'].toString();
        if (_formKey.currentState.validate()) {
          if (Stock.length > 0) {
            SubmitItemDetail();
          } else {
            GlobalWidget.showToast(context, "Logical stock is not available for this item.select item again.");
          }
        }
        // Validate returns true if the form is valid, otherwise false.
      },
      child: Text(
        'UPDATE',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetImagePickerBtn() {
    return new Container(
      height: 25.0,
      child: RaisedButton(
        color: Colors.green[600],
        onPressed: () async {
          // Validate returns true if the form is valid, otherwise false.
          bool data = await GlobalPermission.checkPermissionsCamera(context);
          if (data == true) {
            getImage();
          }
        },
        child: Text(
          "Scan",
          style: TextStyle(color: Colors.white, fontSize: 10.0),
        ),
      ),
    );
  }

  GetResetBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.
        setState(() {
          updateReset();
        });
      },
      child: Text(
        'RESET',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  StockIdFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: StockIdController,
      decoration: GlobalWidget.TextFeildDecoration1("Actual Stock"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter Actual Stock';
        }
        return null;
      },
    );
  }

  final picker = ImagePicker();
  var result;
  Future getImage() async {
    try {
      //    String qrResult = await BarcodeScanner.scan();

      String qrResult = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

      Utility.log("tag", qrResult);
      var itemDetail = await DatabaseHelper.db.getSingleItemDetailBarCode(qrResult, context);
      itemDetail = json.decode(itemDetail);
      SelectedListId = itemDetail["ItId"].toString();
      GlobalWidget.getItemDetail(context, SelectedListId, getData);
      Item_name = itemDetail["ItId"].toString() + "  " + itemDetail["ItName"].toString();
      getstock = false;
      if (SelectedListId.length > 0) {
        GlobalWidget.getItemDetail(context, SelectedListId, getData);
      }

      setState(() {
        searchTextField.textField.controller.text = "";
      });
    } on PlatformException catch (ex) {
      result = "Unknown Error $ex";
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
      print("result of QR $result");
    }
  }

  RemarkFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      maxLines: 4,
      minLines: 1,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: RemarkController,
      decoration: GlobalWidget.TextFeildDecoration1("Remark"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter remark';
        }
        return null;
      },
    );
  }

  var StockIdController = TextEditingController();
  var RemarkController = TextEditingController();

  String Item_name = "";
  ItemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(key, SearchItems, searchTextField, onSelectItem);
  }
/*

  _toggle4() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>SearchItem()),).then((val)
    {
      FocusScope.of(context).requestFocus(new FocusNode());
      if(val!=null)
      {
        setState(()
        {
          var data=json.decode(val);
          String name="${data['name']}";
          String Id="${data['id']}";
          Item_IdController.text=name;
          //I=Id;
          SelectedListId=Id;
          GetItemDetail(Id);
        });
      }
    });
  }
*/
/*
  ItemNameFeild()
  {
   */ /* return GestureDetector(
      child: TextFormField(
        readOnly: true,
        onTap: () {
          _toggle4();
        },
        controller: Item_IdController,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        decoration: InputDecoration(
          contentPadding:GlobalWidget.getContentPadding(),
          hintText: "Select Item",
          suffixIcon: IconButton(
            padding: EdgeInsets.only(left: 20.0),
            onPressed: () => _toggle4(),
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Select';
          }
          return null;
        },
      ),
    );*/ /*

  }*/

  GlobalKey<AutoCompleteTextFieldState<ModelSearchItem>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;
  static List<ModelSearchItem> SearchItems = new List<ModelSearchItem>();
  bool loading = true;

  void getSearchItems() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts1();
    if (l1.length < 0) {
      GlobalWidget.showToast(context, "Please wait untill data is sync");
    } else {
      //SearchItems = loadSearchItems(l1);
      SearchItems = GlobalSearchItem.loadSearchItems(l1.toString());
      // print('SearchItems: ${SearchItems[0].name}');
      setState(() {
        loading = false;
      });
    }
  }

  void onSelectItem(ModelSearchItem item) {
    Utility.log("tag", item.name);
    SelectedListId = item.id;

    Item_name = item.id + "  " + item.name;

    GlobalWidget.getItemDetail(context, SelectedListId, getData);
    setState(() {
      searchTextField.textField.controller.text = "";
    });
  }

  bool check_val = true;

  void updateReset() {
    searchTextField.clear();
    StockIdController.clear();
    RemarkController.clear();
    check_val = true;

    SelectedListId = "";
    Item_name = "";
    getstock = false;
    setState(() {});
  }

  getData(var data) {
    data1_upd = data;
    if (data1_upd['status'] == 0) {
      if (data1_upd['ds']['tables'][0]['rowsList'].length > 0) {
        setState(() {
          getstock = true;
        });
      }
    } else {
      GlobalWidget.showMyDialog(context, "", data1_upd['msg']);
    }
  }
}

class RetriveModel {
  var data;

  RetriveModel(this.data, this.type);

  int type;
}
