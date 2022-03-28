import 'dart:convert';
import 'dart:developer';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

import 'ShowSchemeBox.dart';

class AddNewGrcActivity extends StatefulWidget {
  String InwardId;
  var product_qty_list;

  AddNewGrcActivity(this.InwardId, this.product_qty_list);

  @override
  State<StatefulWidget> createState() {
    Utility.log("tag", product_qty_list);
    return ViewAddGrc();
  }
}

class ViewAddGrc extends State<AddNewGrcActivity> {
  final FocusNode _FMRPFocus = FocusNode();
  final FocusNode _FQTYFocus = FocusNode();
  final FocusNode _FFQTYFocus = FocusNode();
  final FocusNode _FSRemarkFocus = FocusNode();
  final FocusNode _FBestFocus = FocusNode();
  final FocusNode _FGRemarkFocus = FocusNode();
  final FocusNode _FDateFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _FMRPFocus.unfocus();
    _FQTYFocus.unfocus();
    _FFQTYFocus.unfocus();
    _FSRemarkFocus.unfocus();
    _FBestFocus.unfocus();
    _FGRemarkFocus.unfocus();
    _FDateFocus.unfocus();
  }

  String userID = "14";
  // var Item_IdController = TextEditingController();
  var StockIdController = TextEditingController();
  String SelectedListId = "";

  bool Schemeflg = false;
  String ImageStatus = "Not Changed";
  String schemeStatus = "Not Changed";
  String PrdSch = "";
  final picker = ImagePicker();
  var result;

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

  Future getImage() async {
    try {
      String qrResult = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

      log("qrResult-->$qrResult");

//      String qrResult = await BarcodeScanner.scan();
      result = qrResult;
      var itemDetail = await DatabaseHelper.db.getSingleItemDetailBarCode(qrResult, context);

      log("itemDetail-->$itemDetail");

      itemDetail = json.decode(itemDetail);
      SelectedListId = itemDetail["ItId"].toString();
      Item_name = itemDetail["ItId"].toString() + "  " + itemDetail["ItName"].toString();
      for (int i = 0; i < widget.product_qty_list.length; i++) {
        var colm = widget.product_qty_list[i]["cols"];
        if (colm["ItId"].toString() == itemDetail["ItId"].toString()) {
          POQTY = colm["PoQty"].toString();
          setState(() {});
          try {
            if (colm["ExpEnable"].toString() == "0") {
              expanse_enable = false;
            } else {
              expanse_enable = true;
            }
          } catch (e) {}
          break;
        }
      }

      /* var itemDetail1=await DatabaseHelper.db.getSingleItemDetail(SelectedListId);
      Utility.log("tag", itemDetail1);
      var Datap=json.decode(itemDetail1);
     */
      var Datap = itemDetail;
      price = Datap["Price"].toString();
      PrdSch = Datap["PrdSch"].toString().trim();
      PrdSch = GlobalWidget.getstringValue1(PrdSch);
      if (PrdSch != "") {
        Schemeflg = true;
        Navigator.of(context)
            .push(
          new MaterialPageRoute(
              builder: (_) => new ItemSchemeActivity(PrdSch, itemDetail["ItId"].toString(), itemDetail["ItName"].toString())),
        )
            .then((val) {
          if (val != null) {
            var data = val;
            ImageStatus = "${data['ImageStatus']}";
            schemeStatus = "${data['schemeStatus']}";
            SchemeRemarkController.text = "${data['remark']}";
            setState(() {});
          }
        });
      }

      Utility.log("tagPrdSch", PrdSch);
      setState(() {
        searchTextField.textField.controller.text = "";
      });
      GlobalWidget.getItemDetail(context, SelectedListId, getData);
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
    setState(() {});
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
          //getImage2();
          //GetItemDetail();
        },
        child: Text(
          "Scan",
          style: TextStyle(color: Colors.white, fontSize: 10.0),
        ),
      ),
    );
  }

  var MfgDate;
  String TAG = "AddNewGrc";
  Future<void> AddItemDetail() async {
    if (SelectedListId == "") {
      GlobalWidget.GetToast(context, GlobalConstant.ItemError);
      return;
    }

    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    List a1 = new List();
    //a1.add(mapobj());

    Map<String, dynamic> map3() => {
          'pname': 'Confirm',
          'value': false,
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'IWID',
          'value': widget.InwardId.toString(),
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());

    Map<String, dynamic> map04() => {
          'pname': 'IWTID',
          'value': "0",
        };

    var dmap04 = map04();
    Map<String, dynamic> mapobj04() => {
          'cols': dmap04,
        };

    a1.add(mapobj04());
    Map<String, dynamic> map5() => {
          'pname': 'ItId',
          'value': SelectedListId,
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };
    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'Qty',
          'value': QTYController.text.toString(),
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };
    a1.add(mapobj6());
    Map<String, dynamic> map7() => {
          'pname': 'MRP',
          'value': MRPController.text.toString(),
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };

    a1.add(mapobj7());

    Map<String, dynamic> map8() => {
          'pname': 'FreeQty',
          'value': FreeQTYController.text.toString(),
        };

    var dmap8 = map8();
    Map<String, dynamic> mapobj8() => {
          'cols': dmap8,
        };
    a1.add(mapobj8());

    if (onlyFreeQtyValue == true) {
      Map<String, dynamic> map08() => {
            'pname': 'ExclFree',
            'value': "1",
          };
      var dmap08 = map08();
      Map<String, dynamic> mapobj08() => {
            'cols': dmap08,
          };
      a1.add(mapobj08());
    }
    var mfdate_val;
    try {
      if (date_val == 1) {
        if (dropdownValue == "Months") {
          try {
            var newDate = new DateTime(MfgDate.year, MfgDate.month + int.parse(InwDayMonthController.text.toString()), MfgDate.day);
            Utility.log("tag", dateFormat.format(newDate));
            mfdate_val = dateFormat.format(newDate);
          } catch (e) {
            Utility.log("tag", e);
          }
        } else {
          try {
            var date = MfgDate.add(Duration(days: int.parse(InwDayMonthController.text.toString())));
            Utility.log("tag", dateFormat.format(date));
            mfdate_val = dateFormat.format(date);
          } catch (e) {}
        }
      } else {
        mfdate_val = "";
      }
    } catch (e) {
      mfdate_val = "";
    }
    Map<String, dynamic> map9() => {
          'pname': 'ExpDate',
          'value': _frdate == null ? "" : _frdate,
        };

    var dmap9 = map9();
    Map<String, dynamic> mapobj9() => {
          'cols': dmap9,
        };
    a1.add(mapobj9());
    if (date_val == 1) {
      Map<String, dynamic> map0009() => {
            'pname': 'BestBfrPrd',
            'value': dropdownValue.toString(),
          };

      var dmap0009 = map0009();
      Map<String, dynamic> mapobj0009() => {
            'cols': dmap0009,
          };
      a1.add(mapobj0009());

      Map<String, dynamic> map009() => {
            'pname': 'BestBfr',
            'value': InwDayMonthController.text.toString(),
          };

      var dmap009 = map009();
      Map<String, dynamic> mapobj009() => {
            'cols': dmap009,
          };
      a1.add(mapobj009());
      Map<String, dynamic> map09() => {
            'pname': 'MnfDt',
            'value': _frdate == null ? "" : _frdate,
          };

      var dmap09 = map09();
      Map<String, dynamic> mapobj09() => {
            'cols': dmap09,
          };
      a1.add(mapobj09());
    }

    Map<String, dynamic> map10() => {
          'pname': 'Scheme',
          'value': Schemeflg,
        };

    var dmap10 = map10();
    Map<String, dynamic> mapobj10() => {
          'cols': dmap10,
        };
    a1.add(mapobj10());

    Map<String, dynamic> map11() => {
          'pname': 'PrdSch',
          'value': PrdSch.toString(),
        };

    var dmap11 = map11();
    Map<String, dynamic> mapobj11() => {
          'cols': dmap11,
        };
    a1.add(mapobj11());

    Map<String, dynamic> map12() => {
          'pname': 'InwSchemeRemark',
          'value': SchemeRemarkController.text.toString(),
        };

    var dmap12 = map12();
    Map<String, dynamic> mapobj12() => {
          'cols': dmap12,
        };
    a1.add(mapobj12());
/*
    Map<String, dynamic> map13() => {
      'pname': 'InwSchemeRemark',
      'value': SchemeRemarkController.text.toString(),
    };

    var dmap13=map13();
    Map<String, dynamic> mapobj13() => {
      'cols': dmap13,
    };

    a1.add(mapobj13());
*/
    Map<String, dynamic> map14() => {
          'pname': 'NoBarcode',
          'value': barCodeValue.toString(),
        };

    var dmap14 = map14();
    Map<String, dynamic> mapobj14() => {
          'cols': dmap14,
        };

    a1.add(mapobj14());

    Map<String, dynamic> map15() => {
          'pname': 'Remark',
          'value': GenralRemarkController.text.toString(),
        };
    var dmap15 = map15();
    Map<String, dynamic> mapobj15() => {
          'cols': dmap15,
        };

    a1.add(mapobj15());

    Map<String, dynamic> map16() => {
          'pname': 'InwSchStatus',
          'value': schemeStatus,
        };

    var dmap16 = map16();
    Map<String, dynamic> mapobj16() => {
          'cols': dmap16,
        };

    a1.add(mapobj16());

    Map<String, dynamic> map17() => {
          'pname': 'MobApp',
          'value': "1",
        };

    var dmap17 = map17();
    Map<String, dynamic> mapobj17() => {
          'cols': dmap17,
        };

    a1.add(mapobj17());

    /*   dt.addRow(dt.NewRow().add(new Object[]{"InwSchStatus", schemeStatus}));
    dt.addRow(dt.NewRow().add(new Object[]{"InwImgStatus", ImageStatus}));
 */

    Map<String, dynamic> map18() => {
          'pname': 'InwImgStatus',
          'value': ImageStatus,
        };

    var dmap18 = map18();
    Map<String, dynamic> mapobj18() => {
          'cols': dmap18,
        };

    a1.add(mapobj18());
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
          'procName': GlobalConstant.Inward_Save,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var value = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data = value;
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          GlobalWidget.GetToast(context, "Success");
          Navigator.pop(context, true);
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

  bool expanse_enable = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GlobalWidget.getAppbar("ADD GRC INWARD"),
        body: getInsertForm(),
      ),
    );
  }

  String price = "0.0";

  Future<void> onSelectItem(ModelSearchItem item) async {
    SelectedListId = item.id;
    Item_name = item.id + "  " + item.name;
    var itemDetail = await DatabaseHelper.db.getSingleItemDetail(SelectedListId);
    Utility.log("tag", item.id + "  " + Item_name);
    Utility.log("tag", itemDetail);

    var Datap = json.decode(itemDetail);
    for (int i = 0; i < widget.product_qty_list.length; i++) {
      var colm = widget.product_qty_list[i]["cols"];
      if (colm["ItId"].toString() == Datap["ItId"].toString()) {
        POQTY = colm["PoQty"].toString();
        if (colm["ExpEnable"].toString() == "0") {
          expanse_enable = false;
        } else {
          expanse_enable = true;
        }
        break;
      }
    }
    Utility.log("tagPrdSch", PrdSch.toString());
    price = Datap["Price"].toString();
    PrdSch = Datap["PrdSch"].toString();
    PrdSch = GlobalWidget.getstringValue1(PrdSch.toString());
    if (PrdSch != "") {
      Schemeflg = true;
      Navigator.of(context)
          .push(new MaterialPageRoute(
              builder: (_) => new ItemSchemeActivity(PrdSch.toString(), Datap["ItId"].toString(), Datap["ItName"].toString())))
          .then((val) {
        if (val != null) {
          var data = val;
          ImageStatus = "${data['ImageStatus']}";
          schemeStatus = "${data['schemeStatus']}";
          SchemeRemarkController.text = "${data['remark']}";
          setState(() {});
        }
      });
    }

    setState(() {
      searchTextField.textField.controller.text = "";
    });
    GlobalWidget.getItemDetail(context, SelectedListId, getData);
  }

  String Item_name = "";

  var MRPController = TextEditingController();
  MRPFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        focusNode: _FMRPFocus,

        //textInputAction: TextInputAction.done,
        maxLength: 10,
        onFieldSubmitted: (String text) {
          setState(() {
            FocusScope.of(context).nextFocus();
            double price_double = double.parse(price);
            double price_text = double.parse(text);
            if (price_double != price_text) {
              GlobalWidget.showMyDialog(context, "", "MRP is different from prevailing MRP. Cross Check.");
            }
            GlobalWidget.fieldFocusChange(context, _FMRPFocus, _FQTYFocus);
          });
        },

        controller: MRPController,
        decoration: GlobalWidget.TextFeildDecoration2("MRP", "MRP"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter MRP';
          }
          return null;
        },
      ),
    );
  }

  var QTYController = TextEditingController();
  QTYFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,
        //textInputAction: TextInputAction.done,
        maxLength: 7,
        focusNode: _FQTYFocus,
        readOnly: onlyFreeQtyValue,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChange(context, _FQTYFocus, _FFQTYFocus);
        },
        controller: QTYController,
        decoration: GlobalWidget.TextFeildDecoration2("Quantity", "Quantity"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter QTY ';
          }
          return null;
        },
      ),
    );
  }

  var FreeQTYController = TextEditingController();
  FreeQTYFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        //textInputAction: TextInputAction.done,
        maxLength: 7,
        focusNode: _FFQTYFocus,
        //  readOnly: onlyFreeQtyValue==true?true:false,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChange(context, _FFQTYFocus, _FSRemarkFocus);
        },
        controller: FreeQTYController,
        decoration: GlobalWidget.TextFeildDecoration2("Free Quantity", "Free Quantity "),
        validator: (value) {
          /*if (value.isEmpty)
            {
              return 'Please enter FreeQTY ';
            }*/
          return null;
        },
      ),
    );
  }

  ItemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(key, SearchItems, searchTextField, onSelectItem);
  }

  var SchemeRemarkController = TextEditingController();

  SchemeRemarkFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: _FSRemarkFocus,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChange(context, _FSRemarkFocus, _FGRemarkFocus);
        },
        controller: SchemeRemarkController,
        decoration: GlobalWidget.TextFeildDecoration2("Scheme Remark", "SchemeRemark"),
        /* validator: (value)
          {
            if (value.isEmpty)
            {
              return 'Please enter Scheme Remark ';
            }

            return null;
          },*/
      ),
    );
  }

  var GenralRemarkController = TextEditingController();

  GenralRemarkFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        //textInputAction: TextInputAction.done,
        focusNode: _FGRemarkFocus,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FGRemarkFocus);
        },
        controller: GenralRemarkController,
        decoration: GlobalWidget.TextFeildDecoration2("General Remark", "General Remark"),
        /*    validator: (value)
          {
            if (value.isEmpty)
            {
              return 'Please enter GenralRemark ';
            }
            return null;
          },*/
      ),
    );
  }

  bool onlyFreeQtyValue = false;
  GetItemonlyFreeQty() {
    return CheckboxListTile(
      //contentPadding: EdgeInsets.only(left: 0.0,right: 0.0),
      contentPadding: EdgeInsets.all(0.0),
      title: Text(
        "Only Free Qty",
        style: TextStyle(fontSize: 12),
      ),
      value: onlyFreeQtyValue,
      onChanged: (newValue) {
        if (newValue == true) {
          QTYController.text = "0";
        }
        setState(() {
          onlyFreeQtyValue = newValue;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }

  getAddBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          if (onlyFreeQtyValue) {
            try {
              double fqty = double.parse(FreeQTYController.text.toString());
              double qty = double.parse(QTYController.text.toString());
              if (fqty <= 0) {
                GlobalWidget.GetToast(context, "Enter valid value for Free Qty");
              } else if (fqty + qty <= 0) {
                GlobalWidget.GetToast(context, "Qty and Free Qty both can't be 0.Please enter correct Qty.");
              } else {
                AddItemDetail();
              }
            } catch (e) {
              GlobalWidget.GetToast(context, "Qty and Free Qty both can't be 0.Please enter correct Qty.");
            }
          } else {
            AddItemDetail();
          }
        }
        /*  if(MRPController.text.toString().length<0)
        {
          GlobalWidget.GetToast(context, "Enter valid value for MRP . ");
        }
        else if(QTYController.text.toString().length<0)
        {
          GlobalWidget.GetToast(context, "Enter valid value for Quantity . ");
        }else
        {
        }*/
      },
      child: Text(
        'Add/Update Item',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  bool barCodeValue = false;
  GetItemBarcode() {
    return CheckboxListTile(
      contentPadding: EdgeInsets.all(0.0),
      title: Text(
        "Item has no barcode",
        style: TextStyle(fontSize: 12),
      ),
      value: barCodeValue,
      onChanged: (newValue) {
        setState(() {
          barCodeValue = newValue;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }

  String POQTY = "Pqty";
  final _formKey = GlobalKey<FormState>();
  getInsertForm() {
    return Form(
      key: _formKey,
      child: new ListView(
        padding: EdgeInsets.all(10.0),
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
          Item_name == ""
              ? new Container()
              : InkWell(
                  child: GlobalWidget.showItemName(Item_name),
                  onTap: () {
                    GlobalConstant.OpenZoomImage(data1, context);
                  },
                ),
          SizedBox(
            height: 10,
          ),
          expanse_enable == true
              ? new Column(
                  children: [
                    getDateRow(),
                    date_val == 1 ? getBestBefore() : new Container(),
                  ],
                )
              : new Container(),
          new Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  POQTY,
                  style: TextStyle(color: Colors.green, fontSize: 20),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 8,
                child: MRPFeild(),
              ),
            ],
          ),
          new Row(
            children: [
              Expanded(
                child: QTYFeild(),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: FreeQTYFeild(),
              ),
            ],
          ),
          SchemeRemarkFeild(),
          GenralRemarkFeild(),
          new Row(
            children: [
              Expanded(
                child: GetItemBarcode(),
              ),
              Expanded(
                child: GetItemonlyFreeQty(),
              ),
            ],
          ),
          SizedBox(
            height: 60,
          ),
          getAddBtn(),
        ],
      ),
    );
  }

  var data1;
  getData(var data) {
    data1 = data;
  }

  String _frdate = "";
  final dateFormat = DateFormat("yyyy-MM-dd");
  //final dateFormat = DateFormat("dd/MM/yyyy");
  DateTime selectedDateTime = DateTime.now();
  var ExpDtController = TextEditingController();

  InvoiceDtFeild() {
    return Container(
      height: 50,
      child: DateTimeField(
        controller: ExpDtController,
        focusNode: _FDateFocus,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FDateFocus);
        },
        decoration: new InputDecoration(hintText: "Select Date", fillColor: Colors.white),
        onShowPicker: (context, currentValue) async {
          return showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: selectedDateTime.subtract(new Duration(days: 365 * 20)),
            lastDate: selectedDateTime.add(new Duration(days: 365 * 10)),
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light(),
                child: child,
              );
            },
          );
        },
        // decoration: InputDecoration(labelText: 'Date'),
        format: dateFormat,
        onChanged: (val) {
          _frdate = dateFormat.format(val);
          MfgDate = val;
          // Utility.setStringPreference(GlobalConstant.FROM_DATE_Report, _frdate);
        },
      ),
    );
  }

  @override
  void initState() {
    getSearchItems();
    getUserId();
    MfgDate = dateFormat.format(selectedDateTime);
    Utility.log("tagdate", MfgDate.toString());
  }

  Future<void> getUserId() async {
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
  }

  int date_val = 0;

  getDateRow() {
    return new Row(
      children: [
        Expanded(
          child: new Row(
            children: [
              InkWell(
                onTap: () {
                  date_val = 0;
                  setState(() {});
                },
                child: new Row(
                  children: [
                    Icon(date_val == 0 ? Icons.check_box : Icons.check_box_outline_blank),
                    Text("Exp Dt."),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  date_val = 1;
                  setState(() {});
                },
                child: new Row(
                  children: [
                    Icon(date_val == 1 ? Icons.check_box : Icons.check_box_outline_blank),
                    Text("Mfg Dt."),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: InvoiceDtFeild(),
        )
      ],
    );
  }

  getBestBefore() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        new Row(
          children: [
            Expanded(
              child: Text("Best Before"),
            ),
            Expanded(
              child: InwQtyFeild(),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: getDurationInt(),
            ),
          ],
        ),
      ],
    );
  }

  String dropdownValue = 'Months';

  List<String> spinnerItems = [
    'Months',
    'Days',
  ];

  getDurationInt() {
    return new Theme(
      data: GlobalConstant.getSpinnerTheme(context),
      child: DropdownButton<String>(
        hint: Text(dropdownValue),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 28,
        elevation: 16,
        style: TextStyle(color: Colors.black, fontSize: 22),
        underline: Container(
          height: 2,
          color: Colors.grey,
        ),
        onChanged: (String data) {
          setState(() {
            dropdownValue = data;
            //  GlobalWidget.GetToast(context, "value : "+dropdownValue);
            Utility.log("tag", dropdownValue);
          });
        },
        items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  var InwDayMonthController = TextEditingController();
  InwQtyFeild() {
    return Container(
      height: 30,
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        focusNode: _FBestFocus,
        //textInputAction: TextInputAction.done,
        //maxLength: 5,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FBestFocus);
        },
        controller: InwDayMonthController,
        decoration: GlobalWidget.TextFeildDecoration1(""),
        validator: (value) {
          return null;
        },
      ),
    );
  }
}
