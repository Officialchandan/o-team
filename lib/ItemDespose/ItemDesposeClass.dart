import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
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
import 'package:toast/toast.dart';

class ItemDesposeActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ItemDesposeView();
  }
}

class ItemDesposeView extends State<ItemDesposeActivity> {
  List<RetriveModel> RefreshList_items = new List();
  int active = 1;
  int current_index = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: GlobalWidget.getAppbar("Dispose Item"),
        body: getListingOntheBasisOfCondition());
  }

  @override
  void initState() {
    getSearchItems();
  }

  String TAG = "ItemDisposeActivity";

  Future<void> showYesNo(BuildContext context, String title, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("" + msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _asyncFileUpload();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showOTPDialoge(BuildContext context, String otpId) async {
    var otpController = new TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("OTP"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Please Enter OTP"),
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(hintText: "Enter OTP."),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              width: 40,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                //  if(otpController.text.toString())
                if (otpController.text.isNotEmpty ||
                    otpController.text != null) {
                  Navigator.of(context).pop();
                  verifyOTP(otpId, otpController.text.trim());
                } else {
                  GlobalWidget.GetToast(context, "Please enter otp");
                }
              },
            ),
          ],
        );
      },
    );
  }

  String userID;

  Future<void> SendOtp() async {
    List a1 = new List();

    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String COCO_Name =
        (await Utility.getStringPreference(GlobalConstant.COCO_NAME));
    String USER_NAME =
        (await Utility.getStringPreference(GlobalConstant.Empname));

    // COCO_ID="14143";
    String message = "OTP to dispose Item: " +
        Item_name +
        " from COCO: " +
        COCO_Name +
        " through Executive " +
        USER_NAME;
    Map<String, dynamic> map() => {
          'pname': 'pid',
          'value': COCO_ID,
        };
    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    Map<String, dynamic> map01() => {
          'pname': 'Msg',
          'value': message,
        };

    var dmap01 = map01();
    Map<String, dynamic> mapobj01() => {
          'cols': dmap01,
        };

    a1.add(mapobj());
    a1.add(mapobj01());

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
          'procName': GlobalConstant.CntrDmgExp_SendOTP,
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
            var products = data1['ds']['tables'][0]['rowsList'][0]['cols'];
            showOTPDialoge(context, products['OtpId']);
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

  _asyncFileUpload() async {
    Dialogs.showProgressDialog(context);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'charset': 'UTF-8',
    };

    Utility.log(TAG, userPass);
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    var request = http.MultipartRequest(
        "POST", Uri.parse(GlobalConstant.BASE_URL + "data/saveDisposeItem"));
    request.headers.addAll(requestHeaders);
    //add text fields
    request.fields["ItId"] = "${SelectedListId}";
    request.fields["dPId"] = "${COCO_ID}";
    request.fields["Remark"] = "${RemarkController.text.toString()}";
    request.fields["userId"] = "${USER_ID}";
    request.fields["key"] = "${GlobalConstant.key}";
    request.fields["psw"] = "${userPass}";
    request.fields["Qty"] = "${QuantityController.text.toString()}";
    request.fields["Remark"] = "${RemarkController.text.toString()}";

    Utility.log(TAG, request.toString());

    if ("${_image.toString()}" != "null") {
      var gumastaupload =
          await http.MultipartFile.fromPath("fileUpload", _image.path);
      request.files.add(gumastaupload);
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    //GlobalFile.Showsnackbar(_globalKey, "Document Uploaded");

    var data1 = json.decode(responseString);

    Utility.log("upload Response --> ", data1);
    Dialogs.hideProgressDialog(context);
    if (data1['status'] == 0) {
      GlobalWidget.showMyDialog(
          context, "Error", "Item Disposed Successfully. ");
      updateReset();
    } else {
      if (data1['msg'].toString() == "Login failed for user") {
        GlobalWidget.showMyDialog(context, "Error",
            "Invalid id or password.Please enter correct id psw or contact HR/IT");
      } else {
        GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
        //GlobalWidget.showMyDialog(context, "Error", "Item Disposed Successfully. ");
        updateReset();
      }
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
    QuantityController.clear();
    RemarkController.clear();
    check_val = true;
    Item_name = "";
    SelectedListId = "";
    path = "";
    _image = null;
    setState(() {});
  }

  String SelectedListId = "";

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

  getListingOntheBasisOfCondition() {
    return getAboveView();
  }

  final _formKey = GlobalKey<FormState>();

  GetUpdateBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        Utility.log(TAG, "clicked");
        if (_formKey.currentState.validate()) {
          Utility.log(TAG, _image);
          if (_image == null) {
            GlobalWidget.GetToast(context, "Take a picture of dispose item.");
          } else if (Item_name.isEmpty) {
            GlobalWidget.GetToast(context, "Select item to dispose.");
            //showYesNo(context,"Confirm","Are you sure ?");
          } else {
            SendOtp();
          }
        }
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

  var _image;
  String path = "";

  Future LoadImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      path = image.path;
    });
  }

  _toggle3() async {
    Utility.log(TAG, "clicked");
    bool data = await GlobalPermission.checkPermissionsCamera(context);
    if (data == true) {
      LoadImageFromGallery();
    }
  }

  GetCameraBtn() {
    return RaisedButton(
      // shape: GlobalWidget.getButtonTheme(),
      color: Colors.green,
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        print("click");
        _toggle3();
        // Validate returns true if the form is valid, otherwise false.
        setState(() {});
      },
      child: new Row(
        children: [
          Expanded(flex: 2, child: new Icon(Icons.camera)),
          Expanded(
            flex: 1,
            child: new Container(),
          ),
          Expanded(
              flex: 7,
              child: Text(
                'Camera',
                style: GlobalWidget.textbtnstyle(),
              )),
        ],
      ),
    );
  }

  StockIdFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        //textInputAction: TextInputAction.done,
        maxLength: 10,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        controller: QuantityController,
        decoration: GlobalWidget.TextFeildDecoration1("Quantity"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter quantity';
          }
          return null;
        },
      ),
    );
  }

  var result;
  final picker = ImagePicker();

  var data1;
  getData(var data) {
    data1 = data;
  }

  Future getImage() async {
    try {
      // String qrResult = await BarcodeScanner.scan();
      String qrResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", false, ScanMode.DEFAULT);

      var itemDetail =
          await DatabaseHelper.db.getSingleItemDetailBarCode(qrResult, context);
      itemDetail = json.decode(itemDetail);
      SelectedListId = itemDetail["ItId"].toString();
      GlobalWidget.getItemDetail(context, SelectedListId, getData);
      Item_name = itemDetail["ItId"].toString() +
          "  " +
          itemDetail["ItName"].toString();
      setState(() {
        searchTextField.textField.controller.text = "";
      });
    } on PlatformException catch (ex) {
      SelectedListId = "";
      Item_name = "";
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
      minLines: 1,
      maxLines: 5,
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
  var QuantityController = TextEditingController();
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

  void onSelectItem(ModelSearchItem item) {
    Utility.log("tag", item.name);
    SelectedListId = item.id.toString();
    Item_name = item.id.toString() + "  " + item.name.toString();
    setState(() {
      searchTextField.textField.controller.text = "";
    });
    GlobalWidget.getItemDetail(context, SelectedListId, getData);
  }

  ItemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(
            key, SearchItems, searchTextField, onSelectItem);
  }

/*
  ItemNameFeild() {
    return GestureDetector(
      child: TextFormField(
        readOnly: true,
        onTap: ()
        {
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
            //onPressed: () => _toggle4(),
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
    );
  }

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
  }*/

  bool check_val = true;
  String Item_name = "";

  getAboveView() {
    return new Container(
        color: const Color(0xFFE8E8E8),
        padding: EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
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
              Item_name == ""
                  ? new Container()
                  : InkWell(
                      child: GlobalWidget.showItemName(Item_name),
                      onTap: () {
                        GlobalConstant.OpenZoomImage(data1, context);
                      },
                    ),
              SizedBox(
                height: 10.0,
              ),
              StockIdFeild(),
              SizedBox(
                height: 30.0,
              ),
              RemarkFeild(),
              SizedBox(
                height: 30.0,
              ),
              new Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GetCameraBtn(),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: path != ""
                        ? new Container(
                            height: 100,
                            width: 100,
                            child: new Image.file(
                              File(path),
                            ),
                          )
                        : new Container(),
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              new Row(
                children: [
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
            ])));
  }

  Future<void> verifyOTP(String otpId, String otp) async {
    List a1 = new List();

    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    // COCO_ID="14143";
    Map<String, dynamic> map() => {
          'pname': 'DpId',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    a1.add(mapobj());

    Map<String, dynamic> map01() => {
          'pname': 'OtID',
          'value': otpId,
        };

    var dmap01 = map01();
    Map<String, dynamic> mapobj01() => {
          'cols': dmap01,
        };

    a1.add(mapobj01());

    Map<String, dynamic> map02() => {
          'pname': 'OTP',
          'value': otp,
        };

    var dmap02 = map02();
    Map<String, dynamic> mapobj02() => {
          'cols': dmap02,
        };

    a1.add(mapobj02());

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
          'procName': GlobalConstant.CntrDmgExp_OtpVerify,
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
            var products = data1['ds']['tables'][0]['rowsList'][0]['cols'];
            if (products['Status'] == "0") {
              Toast.show(products['Msg'], context, gravity: Toast.CENTER);
              return;
            } else {
              showYesNo(context, "Confirm", "Are you sure?");
            }
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
}

class RetriveModel {
  var data;

  RetriveModel(this.data, this.type);

  int type;
}
