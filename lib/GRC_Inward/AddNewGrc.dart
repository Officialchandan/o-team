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
  String TAG = "AddNewGrc";
  final FocusNode _FMRPFocus = FocusNode();
  final FocusNode _FQTYFocus = FocusNode();
  final FocusNode _FFQTYFocus = FocusNode();
  final FocusNode _FSRemarkFocus = FocusNode();
  final FocusNode _FBestFocus = FocusNode();
  final FocusNode _FGRemarkFocus = FocusNode();
  final FocusNode _FDateFocus = FocusNode();

  TextEditingController dateController = TextEditingController();
  TextEditingController inwDayMonthController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController freeQTYController = TextEditingController();
  TextEditingController schemeRemarkController = TextEditingController();
  TextEditingController generalRemarkController = TextEditingController();
  String price = "0.0";
  String itemName = "";
  String POQTY = "Pqty";
  String invoiceDate = "";
  String dropdownValue = 'Months';
  String userID = "14";
  String selectedListId = "";
  String imageStatus = "Not Changed";
  String schemeStatus = "Not Changed";
  String PrdSch = "";

  bool loading = true;
  bool expanseEnable = true;
  bool schemeFlg = false;
  bool onlyFreeQtyValue = false;
  bool barCodeValue = false;

  int dateType = 0;

  var data1;
  var result;
  var mfgDate;

  static List<ModelSearchItem> searchItems = [];
  List<String> spinnerItems = [
    'Months',
    'Days',
  ];

  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat("yyyy-MM-dd");
  final picker = ImagePicker();
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  GlobalKey<AutoCompleteTextFieldState<ModelSearchItem>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;

  @override
  void initState() {
    getSearchItems();
    getUserId();
    mfgDate = dateFormat.format(currentDate);
    Utility.log("tagdate", mfgDate.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: GlobalWidget.getAppbar("ADD GRC INWARD"),
          body: Form(
            key: _formKey,
            child: new ListView(
              padding: EdgeInsets.all(10.0),
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
                      child: getImagePickerBtn(),
                    ),
                  ],
                ),
                itemName == ""
                    ? new Container()
                    : InkWell(
                        child: GlobalWidget.showItemName(itemName),
                        onTap: () {
                          GlobalConstant.OpenZoomImage(data1, context);
                        },
                      ),
                SizedBox(
                  height: 10,
                ),
                expanseEnable == true
                    ? new Column(
                        children: [
                          getDateRow(),
                          dateType == 1 ? getBestBefore() : new Container(),
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
                      child: mrpField(),
                    ),
                  ],
                ),
                new Row(
                  children: [
                    Expanded(
                      child: qtyField(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: freeQTYField(),
                    ),
                  ],
                ),
                schemeRemarkField(),
                generalRemarkField(),
                new Row(
                  children: [
                    Expanded(
                      child: getItemBarcode(),
                    ),
                    Expanded(
                      child: getItemOnlyFreeQty(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                getAddBtn(),
              ],
            ),
          )),
    );
  }

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

  Future getImage() async {
    try {
      String qrResult = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

      log("qrResult-->$qrResult");

//      String qrResult = await BarcodeScanner.scan();
      result = qrResult;
      var itemDetail = await DatabaseHelper.db.getSingleItemDetailBarCode(qrResult, context);

      log("itemDetail-->$itemDetail");

      itemDetail = json.decode(itemDetail);
      selectedListId = itemDetail["ItId"].toString();
      itemName = itemDetail["ItId"].toString() + "  " + itemDetail["ItName"].toString();
      for (int i = 0; i < widget.product_qty_list.length; i++) {
        var colm = widget.product_qty_list[i]["cols"];
        if (colm["ItId"].toString() == itemDetail["ItId"].toString()) {
          POQTY = colm["PoQty"].toString();
          setState(() {});
          try {
            if (colm["ExpEnable"].toString() == "0") {
              expanseEnable = false;
            } else {
              expanseEnable = true;
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
        schemeFlg = true;
        Navigator.of(context)
            .push(
          new MaterialPageRoute(
              builder: (_) => new ItemSchemeActivity(PrdSch, itemDetail["ItId"].toString(), itemDetail["ItName"].toString())),
        )
            .then((val) {
          if (val != null) {
            var data = val;
            imageStatus = "${data['ImageStatus']}";
            schemeStatus = "${data['schemeStatus']}";
            schemeRemarkController.text = "${data['remark']}";
            setState(() {});
          }
        });
      }

      Utility.log("tagPrdSch", PrdSch);
      setState(() {
        searchTextField.textField.controller.text = "";
      });
      GlobalWidget.getItemDetail(context, selectedListId, getData);
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

  getImagePickerBtn() {
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

  Future<void> addItemDetail() async {
    if (selectedListId == "") {
      GlobalWidget.showToast(context, GlobalConstant.ItemError);
      return;
    }

    String expDate1 = "";
    List<Map<String, dynamic>> dataRow = [];
    if (dateType == 1) {
      if (dropdownValue == "Months") {
        DateTime newDate =
            new DateTime(selectedDate.year, selectedDate.month + int.parse(inwDayMonthController.text.toString()), selectedDate.day);

        expDate1 = dateFormat.format(newDate);
        Utility.log("tag", expDate1);
      } else {
        DateTime mDate = selectedDate;
        DateTime newDate = mDate.add(Duration(days: int.parse(inwDayMonthController.text.toString())));

        expDate1 = dateFormat.format(newDate);
        Utility.log("tag", dateFormat.format(newDate));
      }

      dataRow.add(Utility.getColumnMap('MnfDt', invoiceDate));
      dataRow.add(Utility.getColumnMap('BestBfrPrd', dropdownValue));
      dataRow.add(Utility.getColumnMap('BestBfr', inwDayMonthController.text));
    } else {
      expDate1 = invoiceDate;
    }

    List<Map<String, dynamic>> a1 = [];

    //a1.add(mapobj());
    dataRow.add(Utility.getColumnMap('Confirm', false));
    dataRow.add(Utility.getColumnMap('IWID', widget.InwardId.toString()));
    dataRow.add(Utility.getColumnMap('IWTID', "0"));
    dataRow.add(Utility.getColumnMap('ItId', selectedListId));
    dataRow.add(Utility.getColumnMap('Qty', qtyController.text));
    dataRow.add(Utility.getColumnMap('MRP', mrpController.text));
    dataRow.add(Utility.getColumnMap('FreeQty', freeQTYController.text));
    dataRow.add(Utility.getColumnMap('ExclFree', "1"));
    dataRow.add(Utility.getColumnMap('ExpDate', expDate1));

    dataRow.add(Utility.getColumnMap('Scheme', schemeFlg));
    dataRow.add(Utility.getColumnMap('PrdSch', PrdSch));
    dataRow.add(Utility.getColumnMap('InwSchemeRemark', schemeRemarkController.text));
    dataRow.add(Utility.getColumnMap('NoBarcode', barCodeValue));
    dataRow.add(Utility.getColumnMap('Remark', generalRemarkController.text));
    dataRow.add(Utility.getColumnMap('InwSchStatus', schemeStatus));
    dataRow.add(Utility.getColumnMap('MobApp', "1"));
    dataRow.add(Utility.getColumnMap('InwImgStatus', imageStatus));
    dataRow.add(Utility.getColumnMap('FrcWith', 0));
    dataRow.add(Utility.getColumnMap('FrcQty', 0.0));

    Map<String, dynamic> param = {
      'header': [],
      'name': 'param',
      'rowsList': dataRow,
    };

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> input = {
      'dbPassword': userPass,
      'dbUser': USER_ID,
      'host': GlobalConstant.host,
      'key': GlobalConstant.key,
      'os': GlobalConstant.OS,
      'procName': GlobalConstant.Inward_Save,
      'rid': '',
      'srvId': GlobalConstant.SrvID,
      'timeout': GlobalConstant.TimeOut,
      'param': param,
    };
    log("input--->$input");

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var value = await apiController.postsNew(GlobalConstant.SignUp, json.encode(input));
        Dialogs.hideProgressDialog(context);
        var data = value;
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          GlobalWidget.showToast(context, "Success");
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
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  Future<void> onSelectItem(ModelSearchItem item) async {
    selectedListId = item.id;
    itemName = item.id + "  " + item.name;
    var itemDetail = await DatabaseHelper.db.getSingleItemDetail(selectedListId);
    Utility.log("tag", item.id + "  " + itemName);
    Utility.log("tag", itemDetail);

    var Datap = json.decode(itemDetail);
    for (int i = 0; i < widget.product_qty_list.length; i++) {
      var colm = widget.product_qty_list[i]["cols"];
      if (colm["ItId"].toString() == Datap["ItId"].toString()) {
        POQTY = colm["PoQty"].toString();
        if (colm["ExpEnable"].toString() == "0") {
          expanseEnable = false;
        } else {
          expanseEnable = true;
        }
        break;
      }
    }
    Utility.log("tagPrdSch", PrdSch.toString());
    price = Datap["Price"].toString();
    PrdSch = Datap["PrdSch"].toString();
    PrdSch = GlobalWidget.getstringValue1(PrdSch.toString());
    if (PrdSch != "") {
      schemeFlg = true;
      Navigator.of(context)
          .push(new MaterialPageRoute(
              builder: (_) => new ItemSchemeActivity(PrdSch.toString(), Datap["ItId"].toString(), Datap["ItName"].toString())))
          .then((val) {
        if (val != null) {
          var data = val;
          imageStatus = "${data['ImageStatus']}";
          schemeStatus = "${data['schemeStatus']}";
          schemeRemarkController.text = "${data['remark']}";
          setState(() {});
        }
      });
    }

    setState(() {
      searchTextField.textField.controller.text = "";
    });
    GlobalWidget.getItemDetail(context, selectedListId, getData);
  }

  mrpField() {
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

        controller: mrpController,
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

  qtyField() {
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
        controller: qtyController,
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

  freeQTYField() {
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
        controller: freeQTYController,
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

  itemNameField() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(key, searchItems, searchTextField, onSelectItem);
  }

  schemeRemarkField() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: _FSRemarkFocus,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChange(context, _FSRemarkFocus, _FGRemarkFocus);
        },
        controller: schemeRemarkController,
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

  generalRemarkField() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        //textInputAction: TextInputAction.done,
        focusNode: _FGRemarkFocus,
        onFieldSubmitted: (value) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FGRemarkFocus);
        },
        controller: generalRemarkController,
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

  getItemOnlyFreeQty() {
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
          qtyController.text = "0";
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
        if (dateController.text.trim().isEmpty || invoiceDate.isEmpty) {
          GlobalWidget.showToast(context, "Please select date");
          return;
        }

        if (_formKey.currentState.validate()) {
          if (onlyFreeQtyValue) {
            try {
              double fqty = double.parse(freeQTYController.text.toString());
              double qty = double.parse(qtyController.text.toString());
              if (fqty <= 0) {
                GlobalWidget.showToast(context, "Enter valid value for Free Qty");
              } else if (fqty + qty <= 0) {
                GlobalWidget.showToast(context, "Qty and Free Qty both can't be 0.Please enter correct Qty.");
              } else {
                addItemDetail();
              }
            } catch (e) {
              GlobalWidget.showToast(context, "Qty and Free Qty both can't be 0.Please enter correct Qty.");
            }
          } else {
            addItemDetail();
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

  getItemBarcode() {
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

  getData(var data) {
    data1 = data;
  }

  invoiceDateField() {
    return Container(
      height: 50,
      child: DateTimeField(
        controller: dateController,
        focusNode: _FDateFocus,
        onFieldSubmitted: (value) {
          selectedDate = value;
          invoiceDate = dateFormat.format(value);

          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FDateFocus);
        },
        decoration: new InputDecoration(hintText: "Select Date", fillColor: Colors.white),
        onShowPicker: (context, currentValue) async {
          return showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: currentDate.subtract(new Duration(days: 365 * 20)),
            lastDate: currentDate.add(new Duration(days: 365 * 10)),
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
          selectedDate = val;
          invoiceDate = dateFormat.format(val);
          mfgDate = val;
          // Utility.setStringPreference(GlobalConstant.FROM_DATE_Report, _frdate);
        },
      ),
    );
  }

  Future<void> getUserId() async {
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
  }

  getDateRow() {
    return new Row(
      children: [
        Expanded(
          child: new Row(
            children: [
              InkWell(
                onTap: () {
                  dateType = 0;
                  setState(() {});
                },
                child: new Row(
                  children: [
                    Icon(dateType == 0 ? Icons.check_box : Icons.check_box_outline_blank),
                    Text("Exp Dt."),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  dateType = 1;
                  setState(() {});
                },
                child: new Row(
                  children: [
                    Icon(dateType == 1 ? Icons.check_box : Icons.check_box_outline_blank),
                    Text("Mfg Dt."),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: invoiceDateField(),
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
              child: inwQtyField(),
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

  inwQtyField() {
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
        controller: inwDayMonthController,
        decoration: GlobalWidget.TextFeildDecoration1(""),
        validator: (value) {
          return null;
        },
      ),
    );
  }

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
}
