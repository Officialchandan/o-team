import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalFile.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SacnBill/UpdatePgiNumber.dart';
import 'package:ondoprationapp/SearchModel/SearchModel.dart';
import 'package:rxdart/rxdart.dart';

import 'AddNewGrc.dart';

class GrcInwardActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReoportView();
  }
}

class ReoportView extends State<GrcInwardActivity> {
  List<String> rcvStatus = [
    "Select RCV Status",
    "Full",
    "Partial",
  ];

  @override
  void dispose() {
    super.dispose();

    desposeFocus();
  }

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentStatus;

  final subject = new PublishSubject<String>();
  bool _isLoading = false,
      _isPOItemnabled = false,
      _isNewINEnabled = false,
      _isCancelEnabled = false,
      _isSaveEnabled = false;
  List<SearchModel> duplicateItems = List<SearchModel>();
  List<SearchModel> items = List<SearchModel>();
  var products;
  var Updatedata;
  var listdata;
  var _partyName;
  var TAG = "ReprtDetailClass";
  String Grc_Call_id = "0";
  String InwardId = "0";
  String userID = "";
  double ttlIwQty = 0;
  int tvICnt = 0;
  var products2;
  var product_qty_list;
  Future<void> UpdateData() async {
    ttlIwQty = 0;
    items = new List();
    duplicateItems = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="14143";

    var data = GlobalConstant.GetMapForInwardGrc(InwardId);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Inward_FillInward,
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
        // GlobalWidget.GetToast(context, data.body.toString());
        var data1 = json.decode(data.body);

        if (data1['status'] == 0) {
          try {
            if (data1['ds']['tables'].length > 0) {
              var products = data1['ds']['tables'][1]['rowsList'];
              product_qty_list = data1['ds']['tables'][2]['rowsList'];
              Updatedata = data1['ds']['tables'][0]['rowsList'][0]["cols"];
              InvoiceAmtController.text = Updatedata["InvoiceAmt"].toString();
              InvoiceDtController.text = Updatedata["InvoiceDt"].toString();
              InvoiceNoController.text = Updatedata["InvoiceNo"].toString();
              RemarkController.text = Updatedata["Remark"].toString();
              TtlQtyController.text = Updatedata["TtlQty"].toString();
              POIDController.text = Updatedata["POID"].toString();
              InwardId = Updatedata["IWID"].toString();
              _partyName = Updatedata["Party"].toString();
              _isSaveEnabled = true;
              _isPOItemnabled = true;
              _isNewINEnabled = false;
              for (int i = 0; i < products.length; i++) {
                _addBook(products[i]['cols']);
                var dat = products[i]['cols'];
                ttlIwQty +=
                    double.parse(dat["FreeQty"]) + double.parse(dat["Qty"]);
              }
              tvICnt = products.length;
              items.addAll(duplicateItems);

              Utility.log(TAG, items.length);
              setState(() {});
            }
          } catch (e) {
            //  GlobalWidget.showMyDialog(context, "",e.toString());
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

  Future<void> GetPoItems() async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    // COCO_ID="2239";
    List a1 = new List();
    Map<String, dynamic> map() => {
          'pname': 'CocoPID',
          'value': COCO_ID,
        };
    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    a1.add(mapobj());

    Map<String, dynamic> map_01() => {
          'pname': 'POId',
          'value': POIDController.text.toString(),
        };

    var dmap_01 = map_01();
    Map<String, dynamic> mapobj_01() => {
          'cols': dmap_01,
        };
    a1.add(mapobj_01());
    Map<String, dynamic> map_02() => {
          'pname': 'InwForm',
          'value': "1",
        };
    var dmap_02 = map_02();
    Map<String, dynamic> mapobj_02() => {
          'cols': dmap_02,
        };
    a1.add(mapobj_02());
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
          'procName': GlobalConstant.PO_OrderItems,
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
        // GlobalWidget.GetToast(context, data.body.toString());
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          double tPoQty = 0;
          double tInwQty = 0;
          if (data1['ds']['tables'].length > 0) {
            products2 = data1['ds']['tables'][0]['rowsList'];
            AlertDetailPo = data1['ds']['tables'][1]['rowsList'][0]["cols"];
            for (int i = 0; i < products2.length; i++) {
              var colm = products2[i]["cols"];
              if (colm["Qty"] != null) {
                tPoQty += double.parse(colm["Qty"].toString());
                tInwQty += double.parse(colm["InwQty"].toString());
              }
            }
            TPOQty = tPoQty.toString();
            TLwQty = tInwQty.toString();
            TotalItem = products2.length.toString();
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

  Future<void> DeleteData(int index) async {
    Map<String, dynamic> map() => {
          'pname': 'IWTID',
          'value': items[index].data["IWTID"],
        };
    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = map1();
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Inward_DeleteInward,
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
          UpdateData();
          setState(() {});
          GlobalWidget.GetToast(context, "Delete Successfully");
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
/*

  Future _textChanged(String text) async {
    List<SearchModel> dummySearchList = List<SearchModel>();
    dummySearchList.addAll(duplicateItems);
    if (text.isNotEmpty) {
      List<SearchModel> dummyListData = List<SearchModel>();
      dummySearchList.forEach((item) {
        if (item.title.toLowerCase().contains(text.toLowerCase()))
        {
          dummyListData.add(item);
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
*/

  void _addBook(dynamic book) {
    setState(() {
      String Name = book['ItId'].toString() +
          " " +
          book['ItName'].toString() +
          " " +
          book['Barcode'].toString() +
          " ";
      duplicateItems.add(new SearchModel(Name.trim(), "${Name}", book));
    });
  }

  //FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentStatus = _dropDownMenuItems[0].value;
    duplicateItems = new List();
    items = new List();
    UpdateData();
    // subject.stream.debounce(new Duration(milliseconds: 600)).listen(_textChanged);
  }

  TextEditingController controller = new TextEditingController();

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String status in rcvStatus) {
      items.add(new DropdownMenuItem(value: status, child: new Text(status)));
    }
    return items;
  }

  int active = 1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        desposeFocus();
      },
      child: new Scaffold(
        appBar: GlobalWidget.getAppbar("GRC INWARD"),
        body: getWidgets(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Utility.log(InwardId, userID);

            if (InwardId != "0" || userID == "2534813") {
              Navigator.of(context)
                  .push(
                new MaterialPageRoute(
                    builder: (_) =>
                        new AddNewGrcActivity(InwardId, product_qty_list)),
              )
                  .then((val) {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (val != null) {
                  UpdateData();
                }
              });
            } else {
              GlobalWidget.showMyDialog(
                  context, "", "Create Inward before Add Items");
            }
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  final FocusNode _PoNoFocus = FocusNode();
  final FocusNode _BillNoFocus = FocusNode();
  final FocusNode _BillQtyFocus = FocusNode();
  final FocusNode _BillAmtFocus = FocusNode();
  final FocusNode _BillDateFocus = FocusNode();
  final FocusNode _BillRemarkFocus = FocusNode();

  bool read_poidcontroller = false;
  var POIDController = TextEditingController();

  POIDFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        readOnly: read_poidcontroller,
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        focusNode: _PoNoFocus,
        textInputAction: TextInputAction.search,
        // maxLength: 50,
        //   onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        onFieldSubmitted: (value) {
          if (POIDController.text.isNotEmpty) {
            _GetSuppliers(POIDController.text.trim());
            GlobalWidget.fieldFocusChange(context, _PoNoFocus, _BillNoFocus);
          } else {
            GlobalWidget.GetToast(context, "Enter PO Number");
          }
        },
        controller: POIDController,
        //  decoration: GlobalWidget.TextFeildDecoration2(Updatedata==null?"":GlobalWidget.getstringValue1(Updatedata["POID"].toString()), "PO NO"),
        decoration: GlobalWidget.TextFeildDecoration2("", "PO NO"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter POID ';
          }
          return null;
        },
      ),
    );
  }

  var TtlQtyController = TextEditingController();

  TtlQtyFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        focusNode: _BillQtyFocus,
        //textInputAction: TextInputAction.done,
        maxLength: 3,
        onFieldSubmitted: (term) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _BillQtyFocus);
        },
        controller: TtlQtyController,
        // decoration: GlobalWidget.TextFeildDecoration2(Updatedata==null?"":GlobalWidget.getstringValue1(Updatedata["TtlQty"]), "Bill QTY"),
        decoration: GlobalWidget.TextFeildDecoration2("", "Bill QTY"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter TtlQty ';
          }
          return null;
        },
      ),
    );
  }

  var RemarkController = TextEditingController();

  RemarkFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        maxLines: 5,
        minLines: 1,
        keyboardType: TextInputType.text,
        focusNode: _BillRemarkFocus,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (term) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _BillRemarkFocus);
        },
        controller: RemarkController,
        //  decoration: GlobalWidget.TextFeildDecoration2(Updatedata==null?"":GlobalWidget.getstringValue1(Updatedata["Remark"]), "Remark"),
        decoration: GlobalWidget.TextFeildDecoration2("", "Remark"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter Remark ';
          }
          return null;
        },
      ),
    );
  }

  var InvoiceNoController = TextEditingController();
  InvoiceNoFeild() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: _BillNoFocus,
        //textInputAction: TextInputAction.done,
        maxLength: 50,
        onFieldSubmitted: (term) {
          GlobalWidget.fieldFocusChange(context, _BillNoFocus, _BillQtyFocus);
        },
        controller: InvoiceNoController,
        //  decoration: GlobalWidget.TextFeildDecoration2(Updatedata==null?"":GlobalWidget.getstringValue1(Updatedata["InvoiceNo"]), "Bill Number"),
        decoration: GlobalWidget.TextFeildDecoration2("", "Bill Number"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter Bill No ';
          }
          return null;
        },
      ),
    );
  }

  var InvoiceDtController = TextEditingController();
  String _frdate = "";
  final dateFormat = DateFormat("yyyy-MM-dd");
  DateTime selectedDateTime = DateTime.now();

  InvoiceDtFeild() {
    return Container(
      height: 50,
      child: DateTimeField(
        focusNode: _BillDateFocus,
        controller: InvoiceDtController,
        onFieldSubmitted: (term) {
          GlobalWidget.fieldFocusChange(context, _BillDateFocus, _BillAmtFocus);
        },
        // decoration: GlobalWidget.TextFeildDecoration2("","Invoice Date"),
        decoration: new InputDecoration(
            hintText: "Bill Date",
            // labelText: "Bill Date",
            fillColor: Colors.white),
        onShowPicker: (context, currentValue) async {
          return showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: selectedDateTime.subtract(new Duration(days: 365 * 20)),
            lastDate: selectedDateTime,
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
          FocusScope.of(context).unfocus();
          FocusScope.of(context).nextFocus();
        },
      ),
    );
  }

  var InvoiceAmtController = TextEditingController();
  InvoiceAmtFeild() {
    return InkWell(
      onTap: () {},
      child: new Container(
        margin: EdgeInsets.only(top: 10),
        child: TextFormField(
          // keyboardType: TextInputType.number,
          keyboardType: TextInputType.text,

          //textInputAction: TextInputAction.done,
          maxLength: 50,
          focusNode: _BillAmtFocus,
          onFieldSubmitted: (term) {
            GlobalWidget.fieldFocusChange(
                context, _BillAmtFocus, _BillRemarkFocus);
            //    _fieldFocusChange(context, );
          },
          controller: InvoiceAmtController,
          //  decoration: GlobalWidget.TextFeildDecoration2(Updatedata==null?"":GlobalWidget.getstringValue1(Updatedata["InvoiceAmt"]), "Bill Amount"),
          decoration: GlobalWidget.TextFeildDecoration2("", "Bill Amount"),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter Bill Amount ';
            }
            return null;
          },
        ),
      ),
    );
  }

  //Create a form
  Widget _buildChart() {
    return new ListView.builder(
      padding: new EdgeInsets.only(bottom: 50),
      itemCount: items.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
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
                          flex: 3,
                          child: new Text(items[index].data["ItId"].toString()),
                        ),
                        Expanded(
                          flex: 7,
                          child: new Text(
                            items[index].data["ItName"].toString(),
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: new Text(
                            "MRP. " + items[index].data["MRP"].toString(),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: new Text(
                            "QTY : " + items[index].data["Qty"].toString(),
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: new Text(
                            "FQTY : " + items[index].data["FreeQty"].toString(),
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    /*
                    new Row(
                      children: [
                        Expanded(
                          child: new Text(
                            "ExpDate. " + items[index].data["ExpDate"].toString(),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        */ /* Expanded(
                          flex:3,
                          child: new Text("PrevailMRP : "+items[index].data["PrevailMRP"].toString(),style: TextStyle(color: Colors.black),textAlign: TextAlign.start,),
                        ),*/ /*
                        Expanded(
                          child: new Text(
                            items[index].data["ExpEnable"].toString() == "1" ? " ExpEnable : YES" : "ExpEnable : NO",
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),*/
                    /*new Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: new Text(
                            "Kyi : " + items[index].data["Kyi"].toString(),
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: new Text(
                            "Barcode : " + items[index].data["Barcode"].toString(),
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),*/
                    InkWell(
                      onTap: () {
                        DeleteData(index);
                      },
                      child: new Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width,
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 25,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 2.0,
              )
            ],
          ),
          onTap: () {},
        );
      },
    );
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height:
          MediaQuery.of(context).size.height, // Change as per your requirement
      width:
          MediaQuery.of(context).size.width, // Change as per your requirement
      child: ListView.builder(
        // shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: products2.length,
        itemBuilder: (BuildContext context, int index) {
          return new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Row(
                children: [
                  /* Expanded(
                   flex: 2,
                   child:  Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Image.network(GlobalConstant.PhotoUrl+products2[index]["cols"]["ItId"].toString()+GlobalConstant.PhotoDimention),
                   ),
                 ),*/
                  Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          products2[index]["cols"]["ItName"],
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: Text(
                                  products2[index]["cols"]["ItId"].toString()),
                            ),
                            Expanded(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Item QTY : ",
                                    style: TextStyle(
                                        color: colorPrimary, fontSize: 12),
                                  ),
                                  Text(
                                    products2[index]["cols"]["Qty"],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        new Row(
                          children: [
                            Expanded(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Inw St: ",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 12),
                                  ),
                                  Text(
                                    products2[index]["cols"]["InwSt"],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Inw Qty: ",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 12),
                                  ),
                                  Text(
                                    products2[index]["cols"]["InwQty"],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                thickness: 2,
              )
            ],
          );
        },
      ),
    );
  }

  String TotalItem = "";
  String TLwQty = "";
  String TPOQty = "";
  var AlertDetailPo;

  getPoList() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Container(
              child: new Column(
                children: [
                  new Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child:
                            Text("POID : " + AlertDetailPo["PONo"].toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                      ),
                      // SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: Text(
                          AlertDetailPo["PName"].toString(),
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(
                            "Titm : " + TotalItem,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            "TPOQty : " + TPOQty,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            "TIwQty : " + TLwQty,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 2.0,
                  ),
                ],
              ),
            ),
            content: setupAlertDialoadContainer(),
          );
        });
  }

  GetUpdateBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => UpdatePgiNumber()));
      },
      child: Text(
        'PGI SCAN',
        style: GlobalWidget.textbtnstyle1(),
      ),
    );
  }

  GetCloseBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {},
      child: Text(
        'OKTOSEND DOCUMENT',
        style: GlobalWidget.textbtnstyle1(),
      ),
    );
  }

  getDataFirst() {
    return new Container(
      //height: MediaQuery.of(context).size.height,
      //  margin: EdgeInsets.only(top: 22.0),
      child: new Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 50.0,
            color: Colors.grey[300],
            child: Row(
              children: <Widget>[
                Expanded(
                  child: new Container(
                    width: MediaQuery.of(context).size.width,
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
                              //autofocus: true,
                              controller: controller,
                              cursorColor: Colors.black,
                              decoration: new InputDecoration(
                                  hintText: GlobalConstant.SearchHint,
                                  border: InputBorder.none),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          //_isLoading ? new Center(child: new CircularProgressIndicator(),) : new Container(),
        ],
      ),
    );
  }

  AlertReturn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => GrcInwardActivity()));
  }

  Future<void> SubmitItemDetail() async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    List a1 = new List();
    Map<String, dynamic> map3() => {
          'pname': 'IWID',
          'value': Updatedata["IWID"].toString(),
        };
    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'TtlQty',
          'value': TtlQtyController.text.toString(),
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());
    Map<String, dynamic> map5() => {
          'pname': 'RcvStatus',
          'value': _currentStatus.toString().trim(),
        };
    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };
    a1.add(mapobj5());
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
          'procName': GlobalConstant.Inward_SaveTrans,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      var dataerror;
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        // GlobalWidget.GetToast(context, data.body.toString());
        var data1 = json.decode(data.body);
        dataerror = data1;
        Utility.log(TAG, "Response: " + data1.toString());

        if (data1['status'] == 0) {
          String Pdocno =
              data1['ds']['tables'][0]['rowsList'][0]["cols"]["DocNo"];
          GlobalWidget.showMyDialogWithReturnNew(
              context,
              "Success",
              "Doc saved successfuly and PGI no is : " + Pdocno.toString(),
              AlertReturn);
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
        GlobalWidget.showMyDialog(context, "",
            GlobalConstant.interNetException(dataerror + "\n" + e.toString()));
      }
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  Future<void> AddNewItemDetail() async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String CityId =
        (await Utility.getStringPreference(GlobalConstant.COCO_CITY_ID));
    List a1 = new List();
    //a1.add(mapobj());
    Map<String, dynamic> map3() => {
          'pname': 'CityId',
          'value': CityId,
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'POId',
          'value': POIDController.text.toString().trim(),
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };
    a1.add(mapobj4());
    Map<String, dynamic> map5() => {
          'pname': 'CPID',
          'value': COCO_ID,
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };

    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'Party',
          'value': _partyName.toString().trim(),
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };

    a1.add(mapobj6());

    Map<String, dynamic> map7() => {
          'pname': 'InvoiceNo',
          'value': InvoiceNoController.text.toString().trim(),
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };

    a1.add(mapobj7());
    Map<String, dynamic> map8() => {
          'pname': 'InvoiceDt',
          'value': InvoiceDtController.text.toString().trim(),
        };

    var dmap8 = map8();
    Map<String, dynamic> mapobj8() => {
          'cols': dmap8,
        };
    a1.add(mapobj8());

    Map<String, dynamic> map9() => {
          'pname': 'InvoiceAmt',
          'value': InvoiceAmtController.text.toString().trim(),
        };

    var dmap9 = map9();
    Map<String, dynamic> mapobj9() => {
          'cols': dmap9,
        };

    a1.add(mapobj9());

    Map<String, dynamic> map10() => {
          'pname': 'DlvInfo',
          'value': 'By Hand',
        };
    var dmap10 = map10();
    Map<String, dynamic> mapobj10() => {
          'cols': dmap10,
        };
    a1.add(mapobj10());

    Map<String, dynamic> map11() => {
          'pname': 'TtlQty',
          'value': TtlQtyController.text.toString().trim(),
        };

    var dmap11 = map11();
    Map<String, dynamic> mapobj11() => {
          'cols': dmap11,
        };

    a1.add(mapobj11());

    Map<String, dynamic> map12() => {
          'pname': 'IWID',
          'value': InwardId,
        };
    var dmap12 = map12();
    Map<String, dynamic> mapobj12() => {
          'cols': dmap12,
        };
    a1.add(mapobj12());

    Map<String, dynamic> map13() => {
          'pname': 'Remark',
          'value': RemarkController.text.toString().trim(),
        };

    var dmap13 = map13();
    Map<String, dynamic> mapobj13() => {
          'cols': dmap13,
        };
    a1.add(mapobj13());

    Map<String, dynamic> map14() => {
          'pname': 'BillChallan',
          'value': 1,
        };

    var dmap14 = map14();
    Map<String, dynamic> mapobj14() => {
          'cols': dmap14,
        };

    a1.add(mapobj14());
    Map<String, dynamic> map15() => {
          'pname': 'ZID',
          'value': "0",
        };

    var dmap15 = map15();
    Map<String, dynamic> mapobj15() => {
          'cols': dmap15,
        };

    a1.add(mapobj15());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var dataf = map1();
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
          'procName': GlobalConstant.Inward_new,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': dataf,
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
          var datacols = data1['ds']['tables'][0]['rowsList'];
          InwardId = datacols[0]["cols"]["IWID"];

          _isNewINEnabled = false;
          _isSaveEnabled = true;
          setState(() {});

          GlobalWidget.GetToast(context, "Data Saved Successfully ");

          /* try
          {
            products=data1['ds']['tables'][1]['rowsList'];
            for (int i = 0; i < products.length; i++) {
              _addBook(products[i]['cols']);
              var dat = products[i]['cols'];
              ttlIwQty += double.parse(dat["FreeQty"]) + double.parse(dat["Qty"]);
            }
            //tvICnt = products.length;
            items.addAll(duplicateItems);
            tvICnt=items.length;
            setState(() {
            });

          }catch(e)
          {
          }*/
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
      UpdateData();
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  getUpdateBtn() {
    return RaisedButton(
      shape: _isSaveEnabled == false
          ? GlobalWidget.getButtonThemeDisabeled()
          : GlobalWidget.getButtonTheme(),
      color: _isSaveEnabled == false ? Colors.grey : GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: _isSaveEnabled == false
          ? null
          : () {
              if (TtlQtyController.text.toString().length < 0) {
                GlobalWidget.GetToast(context, "Please enter bill quantity . ");
              } else {
                if (_currentStatus == "Select RCV Status") {
                  GlobalWidget.GetToast(context, "Please select rcv status");
                  return;
                }
                showSubmitDialog(context);
              }
            },
      child: Text(
        'Save',
        maxLines: 1,
        style: GlobalWidget.textbtnstyle1(),
      ),
    );
  }

  getPOItemBtn() {
    return RaisedButton(
      shape: _isPOItemnabled == false
          ? GlobalWidget.getButtonThemeDisabeled()
          : GlobalWidget.getButtonTheme(),
      color:
          _isPOItemnabled == false ? Colors.grey : GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      disabledColor: Colors.grey,
      onPressed: _isPOItemnabled == false
          ? null
          : () {
              if (AlertDetailPo == null) {
                GetPoItems();
              } else {
                getPoList();
              }
            },
      child: Text(
        'POITM',
        maxLines: 1,
        style: GlobalWidget.textbtnstyle1(),
      ),
    );
  }

  Future<void> showSubmitDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Are you sure you want to save?"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.of(context).pop();
                SubmitItemDetail();
              },
            ),
          ],
        );
      },
    );
  }

  getAddBtn() {
    return RaisedButton(
      shape: _isNewINEnabled == false
          ? GlobalWidget.getButtonThemeDisabeled()
          : GlobalWidget.getButtonTheme(),
      color:
          _isNewINEnabled == false ? Colors.grey : GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: _isNewINEnabled == false
          ? null
          : () {
              List str = new List();
              List str_name = new List();

              str.add(POIDController.text.toString());
              str_name.add("Enter PO  no");

              str.add(InvoiceNoController.text.toString());
              str_name.add("Enter Bill  no:");

              str.add(TtlQtyController.text.toString());
              str_name.add("Enter Valid Quantity:");

              str.add(InvoiceDtController.text.toString());
              str_name.add("Enter Valid Bill Date.");

              str.add(InvoiceAmtController.text.toString());
              str_name.add("Enter Valid Amount.");

              /*  str.add(RemarkController.text.toString());
        str_name.add("Enter Remark.");
*/
              bool val = GlobalFile.ValidateString(context, str, str_name);
              if (val == true) {
                Utility.log("tag", _currentStatus);
                /*  if (_currentStatus.toString() == "Select RCV Status") {
            GlobalWidget.GetToast(context, "Please select rcv status");
            return;
          }else
            {
              AddNewItemDetail();
            }*/

                AddNewItemDetail();
              }
            },
      child: Text(
        'NewINWD',
        maxLines: 1,
        style: GlobalWidget.textbtnstyle1(),
      ),
    );
  }

  getCancelBtn() {
    return RaisedButton(
      shape: _isCancelEnabled == false
          ? GlobalWidget.getButtonThemeDisabeled()
          : GlobalWidget.getButtonTheme(),
      color:
          _isCancelEnabled == false ? Colors.grey : GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: _isCancelEnabled == false
          ? null
          : () {
              //  GetPoItems();
              _Reset();
            },
      child: Text(
        'Cancel',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GlobalWidget.textbtnstyle1(),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  _scrollListener() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  getWidgets() {
    if (active == 1) {
      return new ListView(
        padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          new Form(
            child: new Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: POIDFeild(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        GlobalWidget.getstringValue(_partyName),
                        style: TextStyle(color: colorPrimary, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                new Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: InvoiceNoFeild(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TtlQtyFeild(),
                    ),
                  ],
                ),

                new Row(
                  children: [
                    Expanded(
                      child: InvoiceDtFeild(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: InvoiceAmtFeild(),
                    ),
                  ],
                ),

                new Row(
                  children: [
                    Expanded(
                      child: RemarkFeild(),
                    ),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),

                new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: new DropdownButton(
                        isExpanded: true,
                        value: _currentStatus,
                        underline: GlobalConstant.getUnderline(),
                        items: _dropDownMenuItems,
                        onChanged: changedDropDownItem,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                new Row(
                  children: [
                    Expanded(
                      child: getPOItemBtn(),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: getAddBtn(),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: getCancelBtn(),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: getUpdateBtn(),
                    ),
                  ],
                ),

                new Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 50.0,
                  color: Colors.grey[300],
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(
                            "Inward ID : " + InwardId,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            "InCnt : " + tvICnt.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            "TInwQty : " + ttlIwQty.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // getDataFirst(),
                _buildChart(),
                //  getDataFirst(),
              ],
            ),
            key: _formKey,
          ),
        ],
      );
    }
  }

  _GetSuppliers(String trim) async {
    var data =
        GlobalConstant.GetMapForInwardGrcPOParty(POIDController.text.trim());
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.InwardGrc_POParty,
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
            var Updatedata = data1['ds']['tables'][0]['rowsList'][0]["cols"];
            _partyName = Updatedata["PName"].toString();
            _isNewINEnabled = true;
            _isPOItemnabled = true;
            read_poidcontroller = true;
            _isCancelEnabled = true;
            GetPoItems();
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

  _Reset() {
    _isNewINEnabled = false;
    _isCancelEnabled = false;
    _isPOItemnabled = false;
    _isSaveEnabled = false;
    read_poidcontroller = false;
    InvoiceAmtController.text = "";
    InvoiceDtController.text = "";
    InvoiceNoController.text = "";
    RemarkController.text = "";
    TtlQtyController.text = "";
    POIDController.text = "";
    InwardId = "";
    _partyName = "";
    tvICnt = 0;
    ttlIwQty = 0;
    items.clear();

    setState(() {});
  }

  changedDropDownItem(String value) {
    setState(() {
      _currentStatus = value;
    });
  }

  void desposeFocus() {
    _PoNoFocus.unfocus();
    _BillNoFocus.unfocus();
    _BillQtyFocus.unfocus();
    _BillAmtFocus.unfocus();
    _BillDateFocus.unfocus();
    _BillRemarkFocus.unfocus();
    Navigator.of(context).pop();
  }
}

class RetriveModel {
  var data;

  RetriveModel(this.data);
}
