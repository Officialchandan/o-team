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

class ItemInfoActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ItemView();
  }
}

class ItemView extends State<ItemInfoActivity> {
  @override
  void initState() {
    super.initState();
    getSearchItems();
  }

  int price_active = 1;
  final _formKey = GlobalKey<FormState>();
  final CityClick = TextEditingController();
  String City_id = "";
  String Audit_Type_Val = "Rate";
  String Store_id = "";
  String Item_id = "";
  final priceController = TextEditingController();
  final mrpController = TextEditingController();
  final remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: GlobalWidget.getAppbar("Item Info"),
      //bottomNavigationBar: GetBottomButtons(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: GlobalWidget.getpadding(),
          children: [
            new Row(
              children: [
                Expanded(
                  flex: 8,
                  child: itemNameField(),
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
                          ? Container()
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
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Text("In Transit : " + data1_upd['ds']['tables'][0]['rowsList'][0]['cols']['InTransit'],
                                style: TextStyle(color: colorPrimary), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
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
            SizedBox(height: 20.0),
            StockIdFeild(),
            SizedBox(height: 20.0),
            RemarkFeild(),
            SizedBox(
              height: 10.0,
            ),
            new Row(
              children: [
                Expanded(
                  flex: 4,
                  child: getUpdateBtn(),
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
      ),
    );
  }

  // var Item_IdController = TextEditingController();
  var StockIdController = TextEditingController();
  var RemarkController = TextEditingController();

  String InTransit = "";
  String Stock = "";
  bool getstock = false;

  var data1_upd;
  getData(var data) {
    data1_upd = data;
    if (data1_upd['status'] == 0) {
      if (data1_upd['ds']['tables'][0]['rowsList'].length > 0) {
        setState(() {
          getstock = true;
        });
      }
    }
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

  getUpdateBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          if (Stock.length > 0) {
            // SubmitItemDetail();
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

  GetImagePickerBtn() {
    return new Container(
      height: 25.0,
      child: RaisedButton(
        color: Colors.green[600],
        onPressed: () async {
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

  var result;
  final picker = ImagePicker();

  Future getImage() async {
    try {
      // String qrResult = await BarcodeScanner.scan();
      String qrResult = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

      Utility.log("tag", qrResult);
      var itemDetail = await DatabaseHelper.db.getSingleItemDetailBarCode(qrResult, context);
      itemDetail = json.decode(itemDetail);
      SelectedListId = itemDetail["ItId"].toString();
      Item_name = itemDetail["ItId"].toString() + "  " + itemDetail["ItName"].toString();
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
    return new Container(
      child: TextFormField(
        keyboardType: TextInputType.text,
        maxLength: 250,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        controller: RemarkController,
        decoration: GlobalWidget.TextFeildDecoration1("Remark"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter remark';
          }
          return null;
        },
      ),
    );
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchItem>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  static List<ModelSearchItem> searchItems = [];
  bool loading = true;

  void getSearchItems() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts1();
    if (l1.length < 0) {
      GlobalWidget.showToast(context, "Please wait untill data is sync");
    } else {
      //SearchItems = loadSearchItems(l1);
      searchItems = GlobalSearchItem.loadSearchItems(l1.toString());
      // print('SearchItems: ${SearchItems[0].name}');
      setState(() {
        loading = false;
      });
    }
  }

  void onSelectItem(ModelSearchItem item) {
    SelectedListId = item.id;
    Item_name = item.id + "  " + item.name;
    GlobalWidget.getItemDetail(context, SelectedListId, getData);
    setState(() {
      searchTextField.textField.controller.text = "";
    });
  }

  String Item_name = "";
  itemNameField() {
    print("searchItems-$searchItems");
    print("searchTextField-$searchTextField");
    print("onSelectItem-$onSelectItem");
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(key, searchItems, searchTextField, onSelectItem);
  }

  String TAG = "ITEMINFO";

  void updateReset() {
    searchTextField.clear();
    SelectedListId = "";
    StockIdController.clear();
    RemarkController.clear();
    check_val = true;

    SelectedListId = "";
    Item_name = "";
    getstock = false;
  }

  String SelectedListId = "";

  bool check_val = true;

  Future<void> submitItemDetail() async {
    print("submitItemDetail");
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
}
