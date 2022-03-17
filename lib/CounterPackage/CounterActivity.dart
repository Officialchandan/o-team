import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';

import '../GlobalData/ApiController.dart';
import '../GlobalData/Dialogs.dart';
import '../GlobalData/GlobalConstant.dart';
import '../GlobalData/GlobalWidget.dart';
import '../GlobalData/NetworkCheck.dart';
import '../GlobalData/Utility.dart';
import '../SearchModel/SearchItem.dart';

class CounterActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CounterView();
  }
}

class CounterView extends State<CounterActivity> {
  Future<void> GetItemDetail() async {
    if (SelectedListId == "") {
      GlobalWidget.GetToast(context, GlobalConstant.ItemError);
      return;
    }
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    var data = GlobalConstant.GetMapForListBasedStockItemDetail(
        COCO_ID, SelectedListId);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));

    List a1 = new List();
    Map<String, dynamic> map() => {
          'pname': 'itid',
          'value': SelectedListId,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'pid',
          'value': COCO_ID,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };

    a1.add(mapobj1());

    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_getItemInfo,
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
          if (data1['ds']['tables'][0]['rowsList'].length > 0) {
            /* Stock=data1['ds']['tables'][0]['rowsList'][0]['cols']['Stock'];
              InTransit=data1['ds']['tables'][0]['rowsList'][0]['cols']['InTransit'];
              setState(() {
                getstock=true;
              });*/
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: GlobalWidget.getAppbar("Counter Detail"),
      body: new ListView(
        shrinkWrap: true,
        children: [
          new Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomerFeild(),
                      SizedBox(
                        height: 20,
                      ),
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

                      /*  Text(widget.data["line_items"][0]["name"].toString(),style: TextStyle(fontSize: 16.0),),

                     SizedBox(height: 10,),

                     new Row(
                       children: [

                         Expanded(child:  Text(AppLocalizations.of(context).translate("total"),style: TextStyle(color: Colors.black,fontSize: 16.0),),),
                         Expanded(child:  Text(widget.data["currency"]+" "+widget.data["total"],style: TextStyle(color: GlobalConstant.getTextColor(),fontSize: 14.0),textAlign: TextAlign.end,),),

                       ],
                     ),

                     SizedBox(height: 10,),

                     new Row(
                       children: [
                         Expanded(child: Text(widget.data["status"],style: TextStyle(color: Colors.black,fontSize: 16.0),),),
                         Expanded(child: Text(widget.data["date_created"],style: TextStyle(color: GlobalConstant.getTextColor(),fontSize: 14.0),textAlign: TextAlign.end,),)
                       ],
                     ),
*/
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListView.builder(
              itemCount: DataItem.length,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {},
                  child: getData(index),
                );
              }),
        ],
      ),
      /*  body: Form(
       child: ListView(
         padding: GlobalWidget.getpadding(),
         children: [

           CustomerFeild(),
           SizedBox(height: 20,),
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
         ],
       ),
     ),*/
    );
  }

  List<DataVal> DataItem = new List();
  var result;
  final picker = ImagePicker();

  Future getImage() async {
/*
    Utility.log(TAG, "imageclicked");
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    Uint8List bytes = file.readAsBytesSync();
    String barcode = await scanner.scanBytes(bytes);*/
    // String barcode = await BarcodeScanner.scan();

    try {
      //  String qrResult = await BarcodeScanner.scan();
      String qrResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", false, ScanMode.DEFAULT);

      result = qrResult;
      print(qrResult);

      SelectedListId = qrResult;
      GlobalWidget.getItemDetail(context, SelectedListId, getData);
      var itemDetail =
          await DatabaseHelper.db.getSingleItemDetail(SelectedListId);
      Utility.log("tag", itemDetail);
      DataItem.add(new DataVal(json.decode(itemDetail)));
      setState(() {
        searchTextField.textField.controller.text = qrResult.toString();
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
    var itemDetail =
        await DatabaseHelper.db.getSingleItemDetail(SelectedListId);
    GlobalWidget.getItemDetail(context, SelectedListId, getData);
    Utility.log("tag", itemDetail);
    DataItem.add(new DataVal(json.decode(itemDetail)));
    setState(() {
      searchTextField.textField.controller.text = item.name;
    });
  }

  String SelectedListId;
  var Item_IdController = TextEditingController();

  ItemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(
            key, SearchItems, searchTextField, onSelectItem);
  }

  var CustomerController = TextEditingController();
  CustomerFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        controller: CustomerController,
        decoration: GlobalWidget.TextFeildDecoration2("Customer", "Customer"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter Customer ';
          }

          return null;
        },
      ),
    );
  }

  _toggle4() {
    Navigator.of(context)
        .push(
      new MaterialPageRoute(builder: (_) => SearchItem()),
    )
        .then((val) {
      FocusScope.of(context).requestFocus(new FocusNode());
      if (val != null) {
        setState(() async {
          var data = json.decode(val);
          String name = "${data['name']}";
          String Id = "${data['id']}";
          Item_IdController.text = name;
          SelectedListId = Id;
          var itemDetail =
              await DatabaseHelper.db.getSingleItemDetail(SelectedListId);
          Utility.log("tag", itemDetail.toString());
          DataItem.add(new DataVal(json.decode(itemDetail)));
          setState(() {});
          //GetItemDetail();
        });
      }
    });
  }

  String Item_id = "";

  final ItemNameController = TextEditingController();

  String TAG = "TAGDATA";

  getData(int index) {
    return Card(
      elevation: 3.0,
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  flex: 8,
                  //width: MediaQuery.of(context).size.width - 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Row(
                        children: [
                          Expanded(
                            child: Text(DataItem[index].data["ItId"] +
                                "  " +
                                DataItem[index].data["ItName"]),
                          ),
                          Expanded(
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.delete,
                                  color: colorPrimary,
                                )),
                          ),
                        ],
                      ),
                      new Row(
                        children: [
                          Expanded(
                            child:
                                Text("MRP : " + DataItem[index].data["Price"]),
                          ),
                          Expanded(
                            child: Text(
                              "MRP : " + DataItem[index].data["Price"],
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      new Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 30,
                            color: colorPrimary,
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Text("1"),
                          SizedBox(
                            width: 40,
                          ),
                          Icon(
                            Icons.remove_circle_outline,
                            size: 30,
                            color: colorPrimary,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    /*for(int i=0;i<10;i++)
      {
        DataItem.add(new DataVal(i));
      }*/

    getSearchItems();
  }
}

class DataVal {
  var data;
  DataVal(this.data);
}
