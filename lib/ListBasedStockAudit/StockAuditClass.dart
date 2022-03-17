import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:collection/collection.dart';
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
import 'package:ondoprationapp/GlobalData/GlobalListHorizontal.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/GrpModel.dart';

class StockAuditActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StockView();
  }
}

class StockView extends State<StockAuditActivity> {
  List<RetriveModel> RefreshList_items = new List();
  int active = 1;
  int current_index = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: GlobalWidget.getAppbar("Stock Audit"),
        body: getListingOntheBasisOfCondition());
  }

  @override
  void initState() {
    super.initState();
    GetBadStockList();
    getSearchItems();
  }

  List<GrpModel> TimeList = new List();
  // List<DateModel> DateList = new List();
  List items = new List();
  List items_column_Heading = new List();
  List items_first_column = new List();
  String TAG = "StockAuditActivity";
  String InTransit = "";
  String Stock = "";
  bool getstock = false;
  String FirstHeadName = "";

  Future<void> GetBadStockList() async {
    RefreshList_items = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String EMPCODE =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));
    var data = GlobalConstant.GetMapForStockAudit(COCO_ID, EMPCODE);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String Item_Id =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': Item_Id,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.BadStock_GetList,
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
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var products = data1['ds']['tables'][0]['rowsList'];
            var header = data1['ds']['tables'][0]['header'];
            for (int i = 0; i < header.length; i++) {
              if (i == 2) {
              } else {
                items_column_Heading.add(header[i]);
              }
            }

            FirstHeadName = header[2]["name"].toString();
            var list = products;
            TimeList = new List();
            //  Utility.log(TAG + " vallength1 ", value.length);
            //timegroup
            var GrpMap =
                groupBy(list.toList(), (obj) => obj["cols"][header[0]["name"]]);

            //start group time
            GrpMap.forEach((key, value) {
              items_first_column = new List();
              items = new List();
              for (var t in value) {
                var data = t["cols"];
                items_first_column.add(data[header[2]["name"]].toString());
                items.add(data);
                // items.add(data[0]["cols"]);
              }

              TimeList.add(new GrpModel(key.toString(), items,
                  items_column_Heading, items_first_column));
            }); //end group time

            // SetAmountListIng();
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

  //if row Count 0 so 1st row
  List<Widget> _buildCells(int count, int rowcount, var items) {
    ;
    return List.generate(
      count,
      (index) => rowcount == 0
          ? new Column(
              children: [
                Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: GlobalWidget.getColumWidth(),
                    color: colorPrimary,
                    // margin: EdgeInsets.all(4.0),
                    child: Text(
                      items_column_Heading[index]["name"].toString() +
                          "\n" +
                          GlobalConstant.getamtCount(
                              items_column_Heading[index], items),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    )),
                Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: GlobalWidget.getColumWidth(),
                    color: Colors.white,
                    // margin: EdgeInsets.all(4.0),
                    child: Text(
                      GlobalWidget.getstringValue(items[rowcount]
                              [items_column_Heading[index]["name"].toString()]
                          .toString()),
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      maxLines: 1,
                    )),
              ],
            )
          : Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              width: GlobalWidget.getColumWidth(),
              color: rowcount == 0 ? colorPrimary : Colors.white,
              // margin: EdgeInsets.all(4.0),
              child: Text(
                GlobalWidget.getstringValue(items[rowcount]
                        [items_column_Heading[index]["name"].toString()]
                    .toString()),
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              )),
    );
  }

  List<Widget> _buildRows(int no_of_rows, var items) {
    return List.generate(
      no_of_rows,
      (index) {
        return Row(
            children: _buildCells(items_column_Heading.length, index, items));
      },
    );
  }

  static Widget getAllAmount(List<GrpModel> dateList, items_column_heading) {
    double amt = 0.0;

    try {
      for (var d1 in dateList) {
        var items = d1.items;
        for (var itemsobj in items) {
          try {
            amt = amt + double.parse(itemsobj[items_column_heading["name"]]);
          } catch (e) {}
        }
      }

      amt = GlobalConstant.ConvertDecimal(amt);
      return items_column_heading["type"] != "varchar"
          ? GlobalConstant.getContainer(amt, items_column_heading["name"])
          : new Container();
    } catch (e) {}

    return new Container();
  }

  getListIng() {
    return ListView.builder(
        itemCount: TimeList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index1) {
          return InkWell(
            onTap: () {},
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: GlobalConstant.buildCellsHeding(
                        TimeList[index1].items_first_column.length,
                        TimeList[index1].items_first_column,
                        FirstHeadName,
                        context),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildRows(
                            TimeList[index1].items_first_column.length,
                            TimeList[index1].items),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  var data1_upd;

  Future<void> SubmitItemDetail() async {
    if (SelectedListId == "") {
      GlobalWidget.GetToast(context, GlobalConstant.ItemError);
      return;
    }
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
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
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));
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
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          GlobalWidget.GetToast(context, "Stock Updated Successfully");
          updateReset();
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

  void SetListInItem(list) {
    RefreshList_Count = 0;
    SelectedListId = list[0]['cols']['Stbhid'];
    for (int i = 0; i < list.length; i++) {
      int type = 2;
      RefreshList_Count = RefreshList_Count + 1;
      RefreshList_items.add(new RetriveModel(list[i]['cols'], type));
    }

    setState(() {});
  }

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

  String SelectedListId = "";

  Future<void> _refresh() {
    GetBadStockList();
  }

  int RefreshList_Count = 0;
  getRowDataContainer(var data1) {
    return new Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Text(data1.data['ItName'].toString(),
              style: TextStyle(color: Colors.black, fontSize: 14.0)),
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                child: new Container(
                  alignment: Alignment.centerLeft,
                  child: new Text(
                    "ListId : " + data1.data['ItId'].toString(),
                    style: TextStyle(color: Colors.blue, fontSize: 12.0),
                  ),
                ),
              ),
              Expanded(
                child: new Container(
                  alignment: Alignment.centerLeft,
                  child: new Text(
                    data1.data['Status'].toString(),
                    style: TextStyle(color: colorPrimary, fontSize: 12.0),
                  ),
                ),
              ),
              Expanded(
                child: new Text(
                  data1.data['BadDt'].toString(),
                  style: TextStyle(color: Colors.blue, fontSize: 12.0),
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

  //Create the first column tableRow
  TableRow _buildSingleColumnOne(int index) {
    return TableRow(
        //First line style add background color
        children: [
          GlobalHorizontal.buildSideBox(
              index,
              index == -1
                  ? 'BadDt'
                  : RefreshList_items[index].data["BadDt"].toString(),
              index == -1),
        ]);
  }

  //Create a row of tableRow
  TableRow _buildSingleRow(int index) {
    //print(RefreshList_items[index].data.keys);

    return TableRow(children: [
      GlobalHorizontal.buildSideBox(
          index,
          index == -1
              ? 'Status                           ItId'
              : RefreshList_items[index].data["Status"].toString() +
                  "                           " +
                  RefreshList_items[index].data["ItId"].toString(),
          index == -1),
      GlobalHorizontal.buildSideBox(
          index,
          index == -1
              ? 'ItName'
              : RefreshList_items[index].data["ItName"].toString(),
          index == -1),
    ]);
  }

  List<TableRow> _buildTableColumnOne() {
    List<TableRow> returnList = new List();
    returnList.add(_buildSingleColumnOne(-1));
    for (int i = 0; i < RefreshList_items.length; i++) {
      returnList.add(_buildSingleColumnOne(i));
    }
    return returnList;
  }

  //Create tableRows
  List<TableRow> _buildTableRow() {
    List<TableRow> returnList = new List();
    returnList.add(_buildSingleRow(-1));
    for (int i = 0; i < RefreshList_items.length; i++) {
      returnList.add(_buildSingleRow(i));
    }
    return returnList;
  }

  getListingOntheBasisOfCondition() {
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
                                  GlobalConstant.OpenZoomImage(
                                      data1_upd, context);
                                },
                              ),
                        SizedBox(
                          height: 10.0,
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Lg Stock : " +
                                    data1_upd['ds']['tables'][0]['rowsList'][0]
                                        ['cols']['Stock'],
                                style: TextStyle(color: colorPrimary),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text(
                                  "In Transit : " +
                                      data1_upd['ds']['tables'][0]['rowsList']
                                          [0]['cols']['InTransit'],
                                  style: TextStyle(color: colorPrimary),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: Text("MRP : " +
                                  data1_upd['ds']['tables'][0]['rowsList'][0]
                                          ['cols']['Mrp']
                                      .toString()),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: Text(
                                  "ORP: " +
                                      data1_upd['ds']['tables'][0]['rowsList']
                                              [0]['cols']['Orp']
                                          .toString(),
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
                  SizedBox(
                    height: 10.0,
                  ),
                  RemarkFeild(),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              new Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GetViewBtn(),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: GetUpdateBtn(),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: GetResetBtn(),
                  ),
                ],
              ),
            ],
          ),
          key: _formKey,
        ),
        SizedBox(
          height: 20.0,
        ),
        getListIng()
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
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

  GetUpdateBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: Colors.grey,
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        Stock = data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['Stock']
            .toString();
        if (_formKey.currentState.validate()) {
          if (Stock.length > 0) {
            SubmitItemDetail();
          } else {
            GlobalWidget.GetToast(context,
                "Logical stock is not available for this item.select item again.");
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

  GetViewBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: Colors.grey,
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        GetBadStockList(); // Validate returns true if the form is valid, otherwise false.
      },
      child: Text(
        'View List',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetResetBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: Colors.grey,
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

  var result;
  final picker = ImagePicker();
  Future getImage() async {
    try {
      //  String qrResult = await BarcodeScanner.scan();

      String qrResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", false, ScanMode.DEFAULT);

      var itemDetail =
          await DatabaseHelper.db.getSingleItemDetailBarCode(qrResult, context);
      Utility.log("tag", itemDetail);
      itemDetail = json.decode(itemDetail);
      SelectedListId = itemDetail["ItId"].toString();
      GlobalWidget.getItemDetail(context, SelectedListId, getData);
      Item_name = itemDetail["ItId"].toString() +
          "  " +
          itemDetail["ItName"].toString();
      getstock = false;
      if (SelectedListId.length > 0) {
        GlobalWidget.getItemDetail(context, SelectedListId, getData);
      }

      setState(() {
        searchTextField.textField.controller.text = "";
      });
    } on PlatformException catch (ex) {
      SelectedListId = "";
      Item_name = "";
      getstock = false;
      setState(() {});
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

  // var Item_IdController = TextEditingController();
  var StockIdController = TextEditingController();
  var RemarkController = TextEditingController();

  GlobalKey<AutoCompleteTextFieldState<ModelSearchItem>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  static List<ModelSearchItem> SearchItems = new List<ModelSearchItem>();
  bool loading = true;

  void getSearchItems() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts1();

    if (l1.length < 0) {
      GlobalWidget.GetToast(context, "Please wait untill data is sync");
    } else {
      //SearchItems = loadSearchItems(l1);
      SearchItems = GlobalSearchItem.loadSearchItems(l1.toString());
      // print('SearchItems: ${SearchItems[0].name}');
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> onSelectItem(ModelSearchItem item) async {
    SelectedListId = item.id;

    Item_name = item.id + "  " + item.name;

    var itemDetail = await DatabaseHelper.db.getSingleItemDetail(item.id);
    Utility.log("tag", itemDetail);

    GlobalWidget.getItemDetail(context, SelectedListId, getData);
    setState(() {
      searchTextField.textField.controller.text = "";
    });
  }

  String Item_name = "";
  ItemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(
            key, SearchItems, searchTextField, onSelectItem);
  }
/*

  _toggle4()
  {
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
          GetItemDetail();
        });
      }
    });
  }
*/

  bool check_val = true;
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
