import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/GRC_Inward/Grc_InwardClass.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

class POReciving extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecivingView();
  }
}

var po_item_data;

class RecivingView extends State<POReciving> {
  final FocusNode _FPoNoFocus = FocusNode();
  final FocusNode _FBillDateFocus = FocusNode();
  final FocusNode _FBillNoFocus = FocusNode();
  final FocusNode _FBillCBillNoFocus = FocusNode();
  final FocusNode _FAmtFocus = FocusNode();
  final FocusNode _FCAmtFocus = FocusNode();
  final FocusNode _FRemarkFocus = FocusNode();

  void desposeFocus() {
    _FPoNoFocus.unfocus();
    _FBillDateFocus.unfocus();
    _FBillNoFocus.unfocus();
    _FBillCBillNoFocus.unfocus();
    _FAmtFocus.unfocus();
    _FCAmtFocus.unfocus();
    _FRemarkFocus.unfocus();
    Navigator.of(context).pop();
  }

  List AppointMent_List = new List();
  ScrollController _scrollController = ScrollController();
  var form_key = GlobalKey<FormState>();
  String TotalItem = "";
  String TLwQty = "";
  String TPOQty = "";
  String userID = "";
  var _partyName;
  var AlertDetailPo;
  var products2;
  var history;

  final dateFormat = DateFormat("yyyy-MM-dd");
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool _obscureText3 = true;
  bool _obscureText4 = true;
  // Toggles the password show status
  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  void _toggle3() {
    setState(() {
      _obscureText3 = !_obscureText3;
    });
  }

  void _toggle4() {
    setState(() {
      _obscureText4 = !_obscureText4;
    });
  }

  DateTime selectedDateTime = DateTime.now();

  getDateContainer() {
    return Container(
      child: DateTimeField(
        controller: RCVTimeController,
        focusNode: _FBillDateFocus,
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
        decoration: InputDecoration(labelText: 'Bill Date'),
        format: dateFormat,
        onChanged: (val) {
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FBillDateFocus);
          // _frdate = dateFormat.format(val);
          // Utility.setStringPreference(GlobalConstant.FROM_DATE_Report, _frdate);
        },
      ),
    );
  }

  bool read_poidcontroller = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        desposeFocus();
      },
      child: new Scaffold(
        appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
        body: new Form(
            key: form_key,
            child: new Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.white,
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                  new Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            GlobalWidget.getstringValue(_partyName),
                            style: TextStyle(color: colorPrimary, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: PONumberFeild(),
                        ),
                      ),
                    ],
                  ),
                  getDateContainer(),
                  SizedBox(
                    height: 20,
                  ),
                  new Row(
                    children: [
                      Expanded(
                        child: BILLNumberFeild(),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Conf_BILLNumberFeild(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: [
                      Expanded(
                        child: POAmountFeild(),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Conf_POAmountFeild(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  PORemarkFeild(),
                  new Row(
                    children: [
                      Expanded(
                        child: GetItemLisButton(),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GetSaveButton(),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GetResetButton(),
                      ),
                    ],
                  ),
                  history != null
                      ? ListView.builder(
                          itemCount: history.length,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: new Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          history[index]['cols']['PoId'] == null ? "" : history[index]['cols']['PoId'],
                                          style: TextStyle(fontSize: 12, color: Colors.black),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          history[index]['cols']['Billno'] == null ? "" : history[index]['cols']['Billno'],
                                          style: TextStyle(fontSize: 12, color: Colors.black),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          history[index]['cols']['Amt'] == null ? "" : history[index]['cols']['Amt'],
                                          style: TextStyle(fontSize: 12, color: Colors.red),
                                          textAlign: TextAlign.right,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: new Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Text(
                                              "RcmTm : ",
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                            ),
                                            Text(
                                              history[index]['cols']['GtRcvTm'] == null ? "" : history[index]['cols']['GtRcvTm'],
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            Text(
                                              "InsDt : ",
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                            ),
                                            Text(
                                              "",
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                              textAlign: TextAlign.right,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 4,
                                )
                              ],
                            );
                          })
                      : new Container(),
                  ListView.builder(
                      itemCount: AppointMent_List.length,
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
            )

            /*    new ListView(
              padding: EdgeInsets.all(10.0),

              children:
              [
                new Row(
                  children: [
                    Expanded(
                      child: PONumberFeild(),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: BILLNumberFeild(),
                    ),

                    SizedBox(width: 10,),

                    Expanded(
                      child: RCVTimeFeild(),
                    ),
                  ],
                ),
                new Row(
                  children: [
                  ],
                ),

                POAmountFeild(),
                PORemarkFeild(),
                new Row(
                  children: [
                    Expanded(
                      child: GetItemLisButton(),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: GetSaveButton(),
                    ),
                    SizedBox(width: 10,),

                    Expanded(
                      child: GetResetButton(),
                    ),
                  ],
                ),

                po_item_data!=null?
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(po_item_data[0]['cols']['PName'],style: TextStyle(fontSize: 16,color: Colors.black),),
                    ) ,Container(
                      child: Text(po_item_data[0]['cols']['OrdDt'],style: TextStyle(fontSize: 16,color: Colors.black),),
                    )
                  ],
                ):new Container(),
              ],
            )
        */
            ),
      ),
    );
  }

  GetItemLisButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        if (PONumberController.text.toString().length >= 3) {
          GetPoItemData(PONumberController.text.toString());
        } else {
          GlobalWidget.showToast(context, "Enter PO Number");
        }
      },
      child: Text(
        'Item List',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetSaveButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        if (form_key.currentState.validate()) {
          // UpdateData();
          SubmitPoItemData();
        }
      },
      child: Text(
        'Save',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetResetButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        _partyName = "";
        POAmountController.text = "";
        POAmountController_con.text = "";
        PORemarkController.text = "";
        PONumberController.text = "";
        BILLNumberController.text = "";
        BILLNumberController_con.text = "";
        RCVTimeController.text = "";
        read_poidcontroller = false;
        setState(() {});
      },
      child: Text(
        'Reset',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  final PONumberController = TextEditingController();
  PONumberFeild() {
    return TextFormField(
      readOnly: read_poidcontroller,
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      focusNode: _FPoNoFocus,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],

      autofocus: true,
      onTap: () {
        FocusScope.of(context).requestFocus(_FPoNoFocus);
      },
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (value) {
        if (PONumberController.text.isNotEmpty) {
          _GetSuppliers(PONumberController.text.trim());

          GlobalWidget.fieldFocusChange(context, _FPoNoFocus, _FBillNoFocus);
        } else {
          GlobalWidget.showToast(context, "Enter PO Number");
        }
      },
      controller: PONumberController,
      decoration: GlobalWidget.TextFeildDecoration("PO Number"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter PO number';
        }
        return null;
      },
    );
  }

  final PORemarkController = TextEditingController();

  PORemarkFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 5,
      minLines: 1,
      focusNode: _FRemarkFocus,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FRemarkFocus),
      controller: PORemarkController,
      decoration: GlobalWidget.TextFeildDecoration("Remark"),
    );
  }

  final POAmountController = TextEditingController();

  POAmountFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      obscureText: _obscureText3,
      //textInputAction: TextInputAction.done,
      focusNode: _FAmtFocus,
      onFieldSubmitted: (_) => GlobalWidget.fieldFocusChange(context, _FAmtFocus, _FCAmtFocus),
      controller: POAmountController,
      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Amount",
        suffixIcon: IconButton(
          onPressed: () => _toggle3(),
          icon: GlobalWidget.getIcon(_obscureText3),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter amount';
        }
        return null;
      },
    );
  }

  final POAmountController_con = TextEditingController();
  Conf_POAmountFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      ////textInputAction: TextInputAction.done,
      obscureText: _obscureText4,
      focusNode: _FCAmtFocus,
      onFieldSubmitted: (_) => GlobalWidget.fieldFocusChange(context, _FCAmtFocus, _FRemarkFocus),
      controller: POAmountController_con,

      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Confirm Amount",
        suffixIcon: IconButton(
          onPressed: () => _toggle4(),
          icon: GlobalWidget.getIcon(_obscureText4),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter amount';
        } else if (value.toString() != POAmountController.text.toString()) {
          GlobalWidget.showToast(context, "Amount and confirm amount should be same");
          return 'not match';
        }
        return null;
      },
    );
  }

  final BILLNumberController = TextEditingController();
  final BILLNumberController_con = TextEditingController();

  BILLNumberFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: _obscureText1,
      focusNode: _FBillNoFocus,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => GlobalWidget.fieldFocusChange(context, _FBillNoFocus, _FBillCBillNoFocus),
      controller: BILLNumberController,
      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Bill Number",
        suffixIcon: IconButton(
          onPressed: () => _toggle1(),
          icon: GlobalWidget.getIcon(_obscureText1),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter BILL number';
        }
        return null;
      },
    );
  }

  Conf_BILLNumberFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      obscureText: _obscureText2,
      focusNode: _FBillCBillNoFocus,
      onFieldSubmitted: (_) => GlobalWidget.fieldFocusChange(context, _FBillCBillNoFocus, _FAmtFocus),
      controller: BILLNumberController_con,
      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Confirm Bill No.",
        suffixIcon: IconButton(
          onPressed: () => _toggle2(),
          icon: GlobalWidget.getIcon(_obscureText2),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter confirm bill number';
        } else if (value.toString() != BILLNumberController.text.toString()) {
          GlobalWidget.showToast(context, "Bill No and Confirm bill No should be same");

          return 'not match';
        }
        return null;
      },
    );
  }

  _GetSuppliers(String trim) async {
    var data = GlobalConstant.GetMapForInwardGrcPOParty(PONumberController.text.trim());
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
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
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var Updatedata = data1['ds']['tables'][0]['rowsList'][0]["cols"];
            _partyName = Updatedata["PName"].toString();
            read_poidcontroller = true;
            loadHistory();
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

  Future<void> loadHistory() async {
    List a1 = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, dynamic> map() => {
          'pname': 'CocoPid',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'POId',
          'value': PONumberController.text.toString(),
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

    var data = map_final();
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> mapdata() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.PoRcv_List,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(mapdata()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            history = data1['ds']['tables'][0]['rowsList'];
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
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  String TAG = "PORECIVING";

  Future<void> GetPoItemData(String POID) async {
    List a1 = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, dynamic> map() => {
          'pname': 'CocoPID',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'POId',
          'value': POID,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };
    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'InwForm',
          'value': "1",
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());

    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = map_final();
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> mapdata() => {
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
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(mapdata()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "GetPoItemData Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var list = data1['ds']['tables'][1]['rowsList'];
            products2 = data1['ds']['tables'][0]['rowsList'];
            AlertDetailPo = data1['ds']['tables'][1]['rowsList'][0]["cols"];
            po_item_data = list;
            var data_list = data1['ds']['tables'][0]['rowsList'];
            double total_Inwitm = 0;
            double total_poitm = 0;
            for (int i = 0; i < data_list.length; i++) {
              var colm = data_list[i]["cols"];
              if (colm["Qty"] != null) {
                total_poitm += double.parse(colm["Qty"].toString());
                total_Inwitm += double.parse(colm["InwQty"].toString());
              }
              // AppointMent_List.add(data_list[i]);
            }
            TotalItem = "${data_list.length}";
            TPOQty = "${total_poitm}";
            TLwQty = "${total_Inwitm}";
            getPoList();
            setState(() {});
            // SetListInItem(list);
          }
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            Utility.log("GetPoItemData Error --> ", data1['msg'].toString());
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
                        child: Text("POID : " + AlertDetailPo["PONo"].toString(),
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

  Widget setupAlertDialoadContainer() {
    return Container(
      height: MediaQuery.of(context).size.height, // Change as per your requirement
      width: MediaQuery.of(context).size.width, // Change as per your requirement
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
                 ),
*/
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
                              child: Text(products2[index]["cols"]["ItId"].toString()),
                            ),
                            Expanded(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Item QTY : ",
                                    style: TextStyle(color: colorPrimary, fontSize: 12),
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
                                    style: TextStyle(color: Colors.blue, fontSize: 12),
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
                                    style: TextStyle(color: Colors.blue, fontSize: 12),
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

  Future<void> SubmitPoItemData() async {
    List a1 = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, dynamic> map() => {
          'pname': 'CocoPID',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'POId',
          'value': PONumberController.text.toString(),
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };
    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'RcvRmk',
          'value': PORemarkController.text.toString(),
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'pname': 'Amt',
          'value': POAmountController.text.toString(),
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'BillNo',
          'value': BILLNumberController.text.toString(),
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };
    a1.add(mapobj4());

    Map<String, dynamic> map5() => {
          'pname': 'RcvRgTm',
          'value': RCVTimeController.text.toString(),
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };
    a1.add(mapobj5());

    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = map_final();
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> mapdata() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.POList_Save,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var value = await apiController.postsNew(GlobalConstant.SignUp, json.encode(mapdata()));
        Dialogs.hideProgressDialog(context);
        var data = value;
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          GlobalWidget.showToast(context, "Data Save Successfilly");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GrcInwardActivity()));
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

  final RCVTimeController = TextEditingController();

  RCVTimeFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: RCVTimeController,
      decoration: GlobalWidget.TextFeildDecoration("RCV Time"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter RCV Time';
        }
        return null;
      },
    );
  }

  getData(int index) {
    return new Column(
      children: [
        Text(
          "Item Name ${AppointMent_List[index]['ItName']}",
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(
          height: 4.0,
        ),
        new Row(
          children: [
            Text(
              "Item Id ${AppointMent_List[index]['ItId']}",
              style: TextStyle(color: colorPrimary),
            ),
            Text(
              "Item Qty ${AppointMent_List[index]['Qty']}",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        //   SizedBox(height: 4.0,),
        /*  new Row(
          children: [
            Text("TItm ${AppointMent_List[index]['ItId']}",style: TextStyle(color: colorPrimary),),
            Text("TPOQty ${AppointMent_List[index]['Qty']}",style: TextStyle(color: Colors.blue),),
            Text("TlwQty ${AppointMent_List[index]['Qty']}",style: TextStyle(color: Colors.blue),),
          ],
        ),*/
        Divider(
          thickness: 1.0,
        )
      ],
    );
  }
}
