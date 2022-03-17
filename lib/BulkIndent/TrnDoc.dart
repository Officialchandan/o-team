import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

class TrnDOCActivity extends StatefulWidget {
  var data;
  TrnDOCActivity(this.data);
  @override
  State<StatefulWidget> createState() {
    return ViewData();
  }
}

class ViewData extends State<TrnDOCActivity> {
  List<PendingModel> litems = new List();
  var Popdone;
  int current_index = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  GetUpdateBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        Popdone = true;
        bool falg = false;
        for (int i = 0; i < litems.length; i++) {
          if (litems[i].flag_RT == false) {
            falg = true;
            GlobalWidget.showMyDialog(
                context,
                "Please mark rtv for " +
                    litems[i].data["Coco"] +
                    "(" +
                    litems[i].data["Pid"] +
                    ")",
                "");
            break;
          }
        }
        if (falg == false) {
          CompleteRetriveOrder();
        }
      },
      child: Text(
        'TRN DOC',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  GetCloseBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        'Cancel',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
          child: new Scaffold(
            appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
            bottomNavigationBar: new Container(
              margin: EdgeInsets.all(2.0),
              color: colorPrimary,
              // height: 60.0,
              child: new Row(
                children: [
                  Expanded(
                    child: GetUpdateBtn(),
                  ),
                ],
              ),
            ),
            body: GetListDataview(),
          ),
          onWillPop: pop),
    );
    ;
  }

  @override
  void initState() {
    UpdateData();
  }

  bool LockStatus = false;
  String TAG = "TrnDOCActivity";

  Future<void> UpdateData() async {
    /* if (widget.data["Lockst"] == "Lock") {
      LockStatus = true;
    }
    Utility.log(TAG, widget.data);
*/
    litems = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    Map<String, dynamic> map() => {
          'pname': 'Secid',
          'value': widget.data.toString(),
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> mapfinal() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };
    var data = mapfinal();
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> mapdata() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_Whrtv_Itemlist,
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
            GlobalConstant.SignUp, json.encode(mapdata()));
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
    for (int i = 0; i < list.length; i++) {
      String imagpath = "";
      try {
        String img = list[i]['cols']['Imgpath'];
        imagpath = img.toString().substring(
                img.lastIndexOf('\\') + 1, img.toString().lastIndexOf('.')) +
            "-100x100.jpg";
        imagpath = GlobalConstant.PhotoUrl + imagpath;
        Utility.log(TAG, imagpath);
      } catch (e) {}
      Utility.log(TAG, imagpath);

      double srt_qty = 0.0;
      double qty = 0.0;
      /*try
      {
        srt_qty=double.parse(list[i]['cols']["SQty"]);
      }catch(e)
      {
        srt_qty=0.0;
      }
      try
      {
        qty=double.parse(list[i]['cols']["Qty"]);
        qty=qty-srt_qty;
      }catch(e)
      {
        srt_qty=0.0;
      }*/

      PendingModel p1 =
          new PendingModel(list[i]['cols'], imagpath, false, qty, srt_qty);
      litems.add(p1);
    }
    setState(() {
      try {
        //   getCount();
        // _refreshIndicatorKey.currentState.deactivate();

      } catch (e) {}
    });
  }
/*
  getRowData(int index) {
    return getRowDataContainer(index);
  }*/

  Future<void> _refresh() {
    UpdateData();
  }

  int All_Count = 0;
  int All_Vg = 0;
  int All_GRC = 0;

  void getCount() {
    All_Count = 0;
    All_Vg = 0;
    All_GRC = 0;
    for (int i = 0; i < litems.length; i++) {
      if (litems[i].imagpath == 1) {
        All_Vg = All_Vg + 1;
      }
      if (litems[i].imagpath == 2) {
        All_GRC = All_GRC + 1;
      }
      All_Count = All_Count + 1;
    }
  }

  Future<void> UpdateStatusOfItem(double qty, String status, String ItId,
      String Citid, int index, var DataOfList) async {
    List a1 = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, dynamic> map03() => {
          'pname': 'Itemid',
          'value': ItId,
        };

    var dmap03 = map03();
    Map<String, dynamic> mapobj03() => {
          'cols': dmap03,
        };
    a1.add(mapobj03());

    Map<String, dynamic> map04() => {
          'pname': 'Citid',
          'value': Citid,
        };

    var dmap04 = map04();
    Map<String, dynamic> mapobj04() => {
          'cols': dmap04,
        };
    a1.add(mapobj04());

    Map<String, dynamic> map() => {
          'pname': 'secid',
          'value': widget.data["SecId"],
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map01() => {
          'pname': 'Qty',
          'value': qty,
        };

    var dmap01 = map01();
    Map<String, dynamic> mapobj01() => {
          'cols': dmap01,
        };
    a1.add(mapobj01());

    Map<String, dynamic> map02() => {
          'pname': 'st',
          'value': status,
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
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_Whrtv_Save,
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
          Utility.log(TAG, data1);
          if (data1['ds']['tables'].length > 0) {
            var msg = data1['ds']['tables'][0]['rowsList'][0]["cols"]["Msg"];
            if (msg == "Ok") {
              //
            } else {
              GlobalWidget.showMyDialog(context, "", msg);
            }
          }
          setState(() {});
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

  getRowDataContainer(var dataval, index) {
    return new Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                  child: new Container(
                padding: EdgeInsets.only(left: 10.0),
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalWidget.getRowInsideDevide(),

                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Image(
                              image: NetworkImage(dataval.imagpath),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          //width: MediaQuery.of(context).size.width - 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(dataval.data['ItName'].toString()),
                              Text("BCode : " +
                                  dataval.data['Barcode'].toString()),
                              Text("Stk : " + dataval.data['Stock'].toString()),
                              //Text("Qty : " + items[index].qty),
                              //Text("PackSz : " + items[index].packSize),
                            ],
                          ),
                        )
                      ],
                    ),
                    //GlobalWidget.getRowInsideDevide(),
                    /*new Row(
                          children: [
                            Expanded(
                              child: new Text("Barcode : " +
                                  dataval.data['Barcode'].toString(),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.left,),

                            ),
                            Expanded(
                              child: new Text("Stk : " + dataval.data['Stock'].toString(),
                                style: TextStyle(color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.right,),
                            ),
                          ],
                        ),
*/
                  ],
                ),
              )),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),
          Divider(
            thickness: 2.0,
          )
        ],
      ),
    );
  }

  String RT = "";
  String NF = "";
  GetListDataview() {
    Utility.log(TAG, "message" + widget.data.toString());

    return new ListView(
        // padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: [getListConditionBased()]);
  }

  LockOrder(String text) async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String COCO_CITY_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_CITY_ID));
    String EMPCODE =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));

    List a1 = new List();

    Map<String, dynamic> map() => {
          'pname': 'Cocoid',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());
    Map<String, dynamic> map01() => {
          'pname': 'Citid',
          'value': widget.data["Citid"],
        };

    var dmap01 = map01();
    Map<String, dynamic> mapobj01() => {
          'cols': dmap01,
        };
    a1.add(mapobj01());

    Map<String, dynamic> map02() => {
          'pname': 'LockSt',
          'value': text,
        };

    var dmap02 = map02();
    Map<String, dynamic> mapobj02() => {
          'cols': dmap02,
        };
    a1.add(mapobj02());

    Map<String, dynamic> map03() => {
          'pname': 'Secid',
          'value': widget.data["SecId"],
        };

    var dmap03 = map03();
    Map<String, dynamic> mapobj03() => {
          'cols': dmap03,
        };
    a1.add(mapobj03());

    Map<String, dynamic> mapfianl() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = mapfianl();
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
          'procName': GlobalConstant.Mapp_Whrtv_IndLck,
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
          LockStatus = true;
          Popdone = true;
          if (data1['ds']['tables'].length > 0) {
            var msg = data1['ds']['tables'][0]['rowsList'][0]["cols"]["Msg"];
            var status =
                data1['ds']['tables'][0]['rowsList'][0]["cols"]["status"];
            if (msg != "") {
              GlobalWidget.showMyDialog(context, "", msg);
            }
            if (status == 0) {
              LockStatus = !LockStatus;
            }
          }
          setState(() {});
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

  Future<bool> pop() {
    Navigator.pop(context, Popdone);
  }

  getListConditionBased() {
    return new ListView.builder(
        itemCount: litems.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext ctxt, int index) {
          return new InkWell(
            onTap: () {},
            child: getRowDataContainer(litems[index], index),
          );
        });
  }

  Future<void> CompleteRetriveOrder() async {
    List a1 = new List();

    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));

    Map<String, dynamic> map7() => {
          'pname': 'Str',
          'value': "<Doc>" + getSrcXml() + "</Doc>",
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };

    a1.add(mapobj7());

    Map<String, dynamic> mapfinal() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };
    Utility.log(TAG, json.encode(mapfinal()));
    Map<String, dynamic> mapdata() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_Whrtv_Save_Blk,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': mapfinal(),
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController
          .postsNew(GlobalConstant.SignUp, json.encode(mapdata()))
          .then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, "Response: " + data1.toString());

          String msg = data1['msg'];
          GlobalWidget.showMyDialog(context, "", msg);

          if (data1['status'] == 0) {
            Popdone = true;
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
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  String userID;
  String getSrcXml() {
    // StringBuffer src = new StringBuffer();
    var src = "";
    for (int i = 0; i < litems.length; i++) {
      double qty = litems[i].qty - litems[i].srt_qty;
      src = src +
          "<RtvItm>" +
          "<ItId>" +
          litems[i].data["ItId"] +
          "</ItId>" +
          "<Citid>" +
          litems[i].data["Citid"] +
          "</Citid>" +
          "<Pid>" +
          litems[i].data["Pid"] +
          "</Pid>" +
          "<Qty>" +
          litems[i].data["Qty"].toString() +
          "</Qty>" +
          "<Schqty>" +
          litems[i].srt_qty.toString() +
          "</Schqty>" +
          "  </RtvItm>";
    }
    return src.toString();
  }

  AlertReturn() {
    CompleteRetriveOrder();
  }

  void getRetrivedNF(dataval) {
    double rt_val = 0.0;
    double nf_val = 0.0;
    for (int i = 0; i < litems.length; i++) {
      if (litems[i].flag_RT == true) {
        rt_val = rt_val + litems[i].qty;
        nf_val = nf_val + litems[i].srt_qty;
      }
    }

    RT = "${rt_val.toString()}";
    NF = "${nf_val.toString()}";
  }
}

class PendingModel {
  var data;
  bool flag_RT;
  double srt_qty;
  double qty;
  String imagpath;
  PendingModel(this.data, this.imagpath, this.flag_RT, this.qty, this.srt_qty);
}
