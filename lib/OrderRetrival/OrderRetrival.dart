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

class OrderRetrivalActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return orderRetriveView();
  }
}

class orderRetriveView extends State<OrderRetrivalActivity> {
  List<RetriveModel> litems = new List();
  int active = 1;
  int current_index = 0;
  bool _refreshing = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
        bottomNavigationBar: new Container(
          color: Colors.grey[300],
          padding: EdgeInsets.only(top: 5.0),
          alignment: Alignment.center,
          height: 55.0,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: new InkWell(
                  onTap: () {
                    setState(() {
                      active = 1;
                      //getPending();
                    });
                  },
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "All",
                        style: active == 1 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                      ),
                      new Container(
                        padding: GlobalWidget.getpaddingNavBottom(),
                        decoration: active == 1 ? GlobalWidget.getDecoration(true) : GlobalWidget.getDecoration(false),
                        constraints: GlobalWidget.getBoxConstraint(),
                        child: new Text(
                          '${All_Count.toString()}',
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
                    active = 2;
                    setState(() {
                      //getretrived();
                    });
                  },
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "VG",
                        style: active == 2 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                      ),
                      new Container(
                        padding: GlobalWidget.getpaddingNavBottom(),
                        decoration: active == 2 ? GlobalWidget.getDecoration(true) : GlobalWidget.getDecoration(false),
                        constraints: GlobalWidget.getBoxConstraint(),
                        child: new Text(
                          '${All_Vg.toString()}',
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
                    setState(() {
                      active = 3;
                      //getnotfound();
                    });
                  },
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "GRC",
                        style: active == 3 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                      ),
                      new Container(
                        padding: GlobalWidget.getpaddingNavBottom(),
                        decoration: active == 3 ? GlobalWidget.getDecoration(true) : GlobalWidget.getDecoration(false),
                        constraints: GlobalWidget.getBoxConstraint(),
                        child: new Text(
                          '${All_GRC.toString()}',
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
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () {
            _refresh();
            setState(() {
              _refreshing = true;
            });
            return new Future.delayed(const Duration(milliseconds: 10), () {});
          },
          child: new ListView.builder(
              itemCount: litems.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return new InkWell(
                  onTap: () {},
                  child: getRowData(index),
                );
              }),
        ));
  }

  @override
  void initState() {
    UpdateData();
  }

  String TAG = "OrderRetrivalActivity";

  Future<void> UpdateData() async {
    litems = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    var data = GlobalConstant.GetMapForRetrival(COCO_ID);

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.PROCName_Retrival_ODR,
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
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  void SetListInItem(list) {
    for (int i = 0; i < list.length; i++) {
      int type = 0;
      try {
        int veg_pend = int.parse(list[i]['cols']['VegPend']);
        int veg_recive = int.parse(list[i]['cols']['Vegrcv']);
        int g_pend = int.parse(list[i]['cols']['Gpend']);
        int g_rcv = int.parse(list[i]['cols']['Grcv']);
        if ((veg_pend + veg_recive) > 0 && (g_rcv + g_pend) <= 0) {
          type = 1;
        } else if ((veg_pend + veg_recive) <= 0 && (g_rcv + g_pend) > 0) {
          type = 2;
        }

        //1 for vg 2 for Grc
      } catch (e) {}

      litems.add(new RetriveModel(list[i]['cols'], type));
    }
    setState(() {
      try {
        getCount();
        // _refreshIndicatorKey.currentState.deactivate();

      } catch (e) {}
    });
  }

  getRowData(int index) {
    if (active == 2 && litems[index].type == 1) {
      return getRowDataContainer(index);
    }
    if (active == 3 && litems[index].type == 2) {
      return getRowDataContainer(index);
    }
    if (active == 1) {
      return getRowDataContainer(index);
    } else {
      return new Container();
    }
  }

  String getRiConut(int index) {
    int k = 0;
    try {
      k = int.parse(litems[index].data['Vegrcv']) + int.parse(litems[index].data['Grcv']);
    } catch (e) {}
    return k.toString();
  }

  String getVGConut(int index) {
    int k = 0;
    try {
      k = int.parse(litems[index].data['Vegrcv']) + int.parse(litems[index].data['VegPend']);
    } catch (e) {}
    return k.toString();
  }

  String getGRCConut(int index) {
    int k = 0;
    try {
      k = int.parse(litems[index].data['Gpend']) + int.parse(litems[index].data['Grcv']);
    } catch (e) {}
    return k.toString();
  }

  String getPiConut(int index) {
    int k = 0;
    try {
      k = int.parse(litems[index].data['VegPend']) + int.parse(litems[index].data['Gpend']);
    } catch (e) {}
    return k.toString();
  }

  Future<void> _refresh() {
    _refreshIndicatorKey.currentState?.show()?.then((_) {
      if (litems.length > 0) {
        setState(() {
          _refreshing = false;
        });
      }
    });
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
      if (litems[i].type == 1) {
        All_Vg = All_Vg + 1;
      }
      if (litems[i].type == 2) {
        All_GRC = All_GRC + 1;
      }
      All_Count = All_Count + 1;
    }
  }

  getRowDataContainer(int index) {
    return new Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Row(
            children: [
              Expanded(
                flex: 2,
                child: new Text(litems[index].data['OrderId'].toString(), style: TextStyle(color: Colors.black, fontSize: 14.0)),
              ),
              Expanded(
                flex: 5,
                child: new Text(
                  litems[index].data['Customer'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
              Expanded(
                flex: 3,
                child: new Text(
                  litems[index].data['TatTime'].toString(),
                  style: TextStyle(color: Colors.blue[300], fontSize: 14.0),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                child: new Text(
                  "Total : " + litems[index].data['Items'].toString(),
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Expanded(
                child: new Text(
                  "PI : " + getPiConut(index),
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Expanded(
                child: new Text(
                  "RI : " + getRiConut(index),
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Expanded(
                child: new Text(
                  "NF : " + litems[index].data['ShortMarked'].toString(),
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                child: new Text(
                  "VG Count : " + getVGConut(index),
                  style: TextStyle(color: Colors.green, fontSize: 12.0),
                ),
              ),
              Expanded(
                child: new Text(
                  "GRC Count : " + getGRCConut(index),
                  style: TextStyle(color: colorPrimary, fontSize: 12.0),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),
          new Text(
            "Add : " + litems[index].data['Address'].toString(),
            style: TextStyle(color: Colors.black54),
          ),
          Divider(
            thickness: 2.0,
          )
        ],
      ),
    );
  }
}

class RetriveModel {
  var data;
  RetriveModel(this.data, this.type);
  int type;
}
