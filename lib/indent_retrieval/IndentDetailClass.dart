import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:uuid/uuid.dart';

class IndentDetailActivity extends StatefulWidget {
  var data;

  IndentDetailActivity(this.data);

  @override
  State<StatefulWidget> createState() {
    Utility.log("cityidval", data['Citid']);
    return ViewData();
  }
}

class ViewData extends State<IndentDetailActivity> {
  List<PendingModel> litems = [];
  List<PendingModel> retrivedItems = [];
  List<PendingModel> Retrived_litems2 = [];
  List<PendingModel> SORT_litems = [];
  List<PendingModel> SORT_litems2 = [];
  List<PendingModel> NF_litems = [];
  List<PendingModel> NF_litems2 = [];

  List<Product> items = [];
  List<Product> product = [];

  List<Product> pItem = [];
  List<Product> rItem = [];
  List<Product> srItem = [];
  List<Product> nfItem = [];

  int active = 1;
  var Popdone;
  Color myColor = Colors.grey;
  int currentIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    // await LockOrder("Lock");
    await updateData();

    if (widget.data['Lockst'] == "Lock") {
      lockStatus = true;
      if (lockStatus == false) {
        lockOrder("Lock");
      } else {
        lockOrder("Unlock");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: new Scaffold(
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

                        items.clear();
                        items.addAll(product);
                        //getPending();
                      });
                    },
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Icon(
                          Icons.shopping_cart,
                          color: active == 1 ? GlobalWidget.getcolor(true) : GlobalWidget.getcolor(false),
                        ),
                        Text(
                          "Pending",
                          style: active == 1 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: new InkWell(
                    onTap: () {
                      active = 2;
                      items.clear();
                      items.addAll(product);
                      setState(() {
                        // getretrived();
                      });
                    },
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Icon(
                          Icons.shopping_basket,
                          color: active == 2 ? GlobalWidget.getcolor(true) : GlobalWidget.getcolor(false),
                        ),
                        Text(
                          "Retrived",
                          style: active == 2 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
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
                        items.clear();
                        items.addAll(product);
                        //getnotfound();
                      });
                    },
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Icon(
                          Icons.not_interested,
                          color: active == 3 ? GlobalWidget.getcolor(true) : GlobalWidget.getcolor(false),
                        ),
                        Text(
                          "SRT Items",
                          style: active == 3 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: new InkWell(
                    onTap: () {
                      setState(() {
                        active = 4;
                        items.clear();
                        items.addAll(product);
                        //getnotfound();
                      });
                    },
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Icon(
                          Icons.delete,
                          color: active == 4 ? GlobalWidget.getcolor(true) : GlobalWidget.getcolor(false),
                        ),
                        Text(
                          "Cancel",
                          style: active == 4 ? GlobalWidget.getTextStyleBottomText(true) : GlobalWidget.getTextStyleBottomText(false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: getListDataView(context),
        ),
        onWillPop: pop);
  }

  bool lockStatus = false;
  String TAG = "IndentDetailActivity";

  Future<void> updateData() async {
    Utility.log(TAG, widget.data);

    String cocoId = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    var data = GlobalConstant.GetMapForIndentDetail(cocoId, widget.data['Citid'], widget.data['SecId']);
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
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
      EasyLoading.show();
      try {
        Map<String, dynamic> data1 = await apiController.post(url: GlobalConstant.SignUp, input: map2());

        EasyLoading.dismiss();

        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var item = data1['ds']['tables'][0]['rowsList'];
            setListInItem(item);

            List<dynamic> itemList = data1['ds']['tables'][0]['rowsList'];
            getItemFromMap(itemList);
          }
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        print("eeeeeeeeeee-----------------------------$e");

        GlobalWidget.showMyDialog(context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  getItemFromMap(List<dynamic> itemList) async {
    print("getItemFromMap--->${itemList.length}");

    items.clear();
    await Future.forEach(itemList, (map) async {
      Product product = Product.fromJson(json.encode(map["cols"]));

      print("product--->$product");

      if (product.imgpath.isNotEmpty) {
        product.imgpath =
            product.imgpath.toString().substring(product.imgpath.lastIndexOf('\\') + 1, product.imgpath.toString().lastIndexOf('.')) +
                "-100x100.jpg";
      }

      product.totalQty = product.srtQty + product.qty;
      product.retrivedQty = product.qty;
      product.sortQty = product.srtQty;
      items.add(product);

      if (product.rtvst == "NF") {
        nfItem.add(product);
      }

      if (product.rtvst == "PRT") {
        srItem.add(product);
        rItem.add(product);
      }

      if (product.rtvst == "RT") {
        rItem.add(product);
      }
      if (product.rtvst == "PN") {
        pItem.add(product);
      }
    });

    product.addAll(items);

    print("itemlength-->${items.length}");

    log("products-->${items.toString()}");
  }

  void setListInItem(var itemList) {
    print("setListInItem----->");

    items.clear();

    litems.clear();
    for (int i = 0; i < itemList.length; i++) {
      String imagpath = "";
      try {
        String img = itemList[i]['cols']['Imgpath'];
        imagpath = img.toString().substring(img.lastIndexOf('\\') + 1, img.toString().lastIndexOf('.')) + "-100x100.jpg";
        Utility.log(TAG, imagpath);
      } catch (e) {}
      Utility.log(TAG, itemList[i]['cols']["Qty"]);

      double srt_qty = 0.0;
      double qty = 0.0;
      try {
        srt_qty = double.parse(itemList[i]['cols']["schqty"]);
      } catch (e) {
        srt_qty = 0.0;
      }
      try {
        qty = double.parse(itemList[i]['cols']["Qty"]);
        qty = qty - srt_qty;
      } catch (e) {
        srt_qty = 0.0;
      }

      PendingModel p1 = PendingModel(itemList[i]['cols'], imagpath, true, false, false, qty, srt_qty);
      print("p1------------------------$p1");
      if (itemList[i]['cols']["Rtvst"] == "PN") {
        print("PN");
        litems.add(p1);
        print("My item list->$litems");
      } else if (itemList[i]['cols']["Rtvst"] == "RT") {
        p1.flag_RT = true;
        p1.flag_srt = false;
        p1.flag_nf = false;

        retrivedItems.add(p1);
        Retrived_litems2 = retrivedItems.toSet().toList();
        print("Retrived_litems-->$Retrived_litems2");
      } else if (itemList[i]['cols']["Rtvst"] == "PRT") {
        p1.flag_RT = false;
        p1.flag_srt = true;
        p1.flag_nf = false;
        SORT_litems.add(p1);
        SORT_litems2 = SORT_litems.toSet().toList();
        retrivedItems.add(p1);
        Retrived_litems2 = retrivedItems.toSet().toList();

        print("SORT_litems--$SORT_litems");
      } else if (itemList[i]['cols']["Rtvst"] == "NF") {
        p1.flag_RT = false;
        p1.flag_srt = false;
        p1.flag_nf = true;
        NF_litems.add(p1);

        NF_litems2 = NF_litems.toSet().toList();
      }
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
    updateData();
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

  Future<void> updateStatusOfItem({double qty, String status, String itId, String citid, int index, Product dataOfList}) async {
    List a1 = [];
    String cocoId = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, dynamic> map03() => {
          'pname': 'Itemid',
          'value': itId,
        };

    var dmap03 = map03();
    Map<String, dynamic> mapobj03() => {
          'cols': dmap03,
        };
    a1.add(mapobj03());

    Map<String, dynamic> map04() => {
          'pname': 'Citid',
          'value': citid,
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
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
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
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          Utility.log(TAG, data1);
          if (data1['ds']['tables'].length > 0) {
            var msg = data1['ds']['tables'][0]['rowsList'][0]["cols"]["Msg"];
            debugPrint("msg-->$msg");
            if (msg == "Ok") {
              switch (active) {
                case 1:
                  pItem.removeAt(index);
                  break;
                case 2:
                  rItem.removeAt(index);
                  break;
                case 3:
                  srItem.removeAt(index);
                  break;
                case 4:
                  nfItem.removeAt(index);
                  break;
              }

              if (status == "NF") {
                dataOfList.pending = false;

                nfItem.add(dataOfList);
              } else if (status == "RT") {
                dataOfList.pending = false;
                rItem.add(dataOfList);
              } else if (status == "PRT") {
                dataOfList.pending = false;
                rItem.add(dataOfList);
                srItem.add(dataOfList);
              }
            } else {
              GlobalWidget.showMyDialog(context, "", msg);
            }
          }
          setState(() {});
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

  /*getRowDataContainer(PendingModel dataval, index) {
    return new Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2),
      margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(style: BorderStyle.solid, width: 1.3),
        // gradient: LinearGradient(
        //   begin: Alignment.topRight,
        //   end: Alignment.bottomLeft,
        //   stops: [0.1, 0.3, 0.7, 0.9],
        //   colors: [
        //     Colors.grey[500],
        //     Colors.grey[400],
        //     Colors.grey[300],
        //     Colors.grey[200],
        //   ],
        // ),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                  flex: 2,
                  child: new Container(
                    child: CachedNetworkImage(
                      imageUrl: GlobalConstant.PhotoUrl + dataval.imagpath,
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/loading.png"),
                      fit: BoxFit.contain,
                    ),
                  )),
              Expanded(
                  flex: 8,
                  child: new Container(
                    padding: EdgeInsets.only(left: 10.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalWidget.getRowInsideDevide(),
                        new Text(
                          dataval.data['ItName'].toString(),
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                          textAlign: TextAlign.left,
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            Expanded(
                              child: new Text(
                                "Barcode : " +
                                    dataval.data['Barcode'].toString(),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              child: new Text(
                                "Stk : " + dataval.data['Stock'].toString(),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: new Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (dataval.flag_srt == true &&
                                          dataval.qty > 0) {
                                        dataval.qty = dataval.qty - 1;

                                        dataval.srt_qty = dataval.srt_qty + 1;
                                      }
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: dataval.flag_srt == true
                                          ? colorPrimary
                                          : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    dataval.qty.toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (dataval.flag_srt == true &&
                                          dataval.srt_qty > 0) {
                                        print("dataval");
                                        dataval.srt_qty = dataval.srt_qty - 1;
                                        dataval.qty = dataval.qty + 1;
                                      }
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: dataval.flag_srt == true
                                          ? colorPrimary
                                          : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "SRT QTY : ${dataval.srt_qty.toString()}",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: new Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      dataval.flag_RT = true;
                                      dataval.flag_srt = false;
                                      dataval.flag_nf = false;

                                      dataval.srt_qty = 0.0.abs();
                                      dataval.qty =
                                          double.parse(dataval.data["Qty"])
                                              .abs();

                                      dataval.qty = dataval.qty.abs();
                                      dataval.srt_qty = 0.0.abs();
                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          dataval.flag_RT == true
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color: dataval.flag_RT == true
                                              ? colorPrimary
                                              : Colors.grey,
                                        ),
                                        Text(
                                          "RT",
                                          style: TextStyle(
                                              color: dataval.flag_RT == true
                                                  ? colorPrimary
                                                  : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (double.parse(dataval.data["Qty"])
                                              .abs() !=
                                          1.0) {
                                        myColor = Colors.grey;
                                        dataval.flag_srt = true;
                                        dataval.flag_RT = false;
                                        dataval.flag_nf = false;
                                      }

                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          dataval.flag_srt == true
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color: dataval.flag_srt == true
                                              ? colorPrimary
                                              : myColor,
                                        ),
                                        Text(
                                          "PRT",
                                          style: TextStyle(
                                            color: dataval.flag_srt == true
                                                ? colorPrimary
                                                : myColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      dataval.flag_srt = false;
                                      dataval.flag_RT = false;
                                      dataval.flag_nf = true;
                                      dataval.srt_qty = 0.0.abs();
                                      dataval.srt_qty =
                                          double.parse(dataval.data["Qty"])
                                              .abs();

                                      dataval.srt_qty = dataval.srt_qty.abs();
                                      dataval.qty = 0.0.abs();
                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          dataval.flag_nf == true
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color: dataval.flag_nf == true
                                              ? colorPrimary
                                              : Colors.grey,
                                        ),
                                        Text(
                                          "NF",
                                          style: TextStyle(
                                              color: dataval.flag_nf == true
                                                  ? colorPrimary
                                                  : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  if (lockStatus == true) {
                                    double qty = 0.0;
                                    String Status = "RT";
                                    if (dataval.flag_nf == true) {
                                      dataval.qty = 0.0;
                                      Status = "NF";
                                      Utility.log("tag", dataval.data["Qty"]);
                                      dataval.srt_qty =
                                          double.parse(dataval.data["Qty"]);

                                      Utility.log(TAG, qty);
                                      updateStatusOfItem(
                                          qty: qty,
                                          status: Status,
                                          itId: dataval.data["ItId"].toString(),
                                          citid:
                                              dataval.data["Citid"].toString(),
                                          index: index,
                                          dataOfList: dataval);
                                    } else if (dataval.flag_RT == true) {
                                      Status = "RT";
                                      dataval.srt_qty = 0.0;
                                      dataval.qty =
                                          double.parse(dataval.data["Qty"]);

                                      qty = dataval.qty;

                                      Utility.log(TAG, qty);
                                      updateStatusOfItem(
                                          qty: qty,
                                          status: Status,
                                          itId: dataval.data["ItId"].toString(),
                                          citid:
                                              dataval.data["Citid"].toString(),
                                          index: index,
                                          dataOfList: dataval);
                                    } else if (dataval.flag_srt == true) {
                                      Status = "PRT";
                                      if (dataval.srt_qty == 0.0) {
                                        GlobalWidget.showMyDialog(
                                            context,
                                            "Short Qty Can't be zero for Partial Not Found.Use NF Option for all Item Not found",
                                            "");
                                      } else if (dataval.qty == 0.0) {
                                        GlobalWidget.showMyDialog(
                                            context,
                                            "",
                                            "Short Qty Can't be equalt to Qty for Partial Not Found.Use NF Option for all Item Not found"
                                                "");
                                      } else {
                                        qty = dataval.srt_qty;

                                        Utility.log(TAG, qty);
                                        updateStatusOfItem(
                                            qty: qty,
                                            status: Status,
                                            itId:
                                                dataval.data["ItId"].toString(),
                                            citid: dataval.data["Citid"]
                                                .toString(),
                                            index: index,
                                            dataOfList: dataval);
                                      }
                                    }
                                  } else {
                                    GlobalWidget.showMyDialog(context, "Alert",
                                        "Please Lock Order First ");
                                  }
                                  setState(() {});
                                },
                                child: new Container(
                                  width: 20.0,
                                  padding: EdgeInsets.only(
                                      left: 5.0,
                                      right: 5.0,
                                      top: 2.0,
                                      bottom: 2.0),
                                  child: Text(
                                    "Ok",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                ),
                              ),
                            )
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }*/

  getListDataView(BuildContext context) {
    return new ListView(
        // padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: [
          new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        if (lockStatus == false) {
                          lockOrder("Lock");
                        } else {
                          lockOrder("Unlock");
                        }
                      },
                      child: new Container(
                        width: 20.0,
                        padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          lockStatus == false ? "Lock Order" : "Rtv Complete",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: new Container(
                      width: 20.0,
                      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                      child: Text(
                        widget.data['Section'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0, color: colorPrimary),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        if (lockStatus == false) {
                          GlobalWidget.showMyDialog(context, "", "Please Lock order first");
                        } else if (Retrived_litems2.length == 0) {
                          GlobalWidget.showMyDialog(
                              context, "", "No item retrive for Transfer.Please retrive some item for make Transfer");
                        } else {
                          String msg = "Are you sure you want to create Doc?";
                          if (SORT_litems2.length > 0) {
                            msg = "There are item Pending for retrival Are you sure you want to create Doc?";
                          }

                          GlobalWidget.showMyDialogWithReturn(context, "Confirm", msg, alertReturn);
                        }
                      },
                      child: new Container(
                        width: 20.0,
                        padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          "TRN DOC",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
              GlobalWidget.getRowInsideDevide(),
              new Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: Text(
                      widget.data['TCounter'],
                      style: TextStyle(color: Colors.black, fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              GlobalWidget.getRowInsideDevide(),
              Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: Text(
                      "PI : " + litems.length.toString(),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "RI : " + Retrived_litems2.length.toString(),
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "SRI : " + SORT_litems2.length.toString(),
                      style: TextStyle(color: Colors.blueAccent),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "CI : " + NF_litems2.length.toString(),
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 30.0),
          productListView(context),
          // getListConditionBased()
        ]);
  }

  lockOrder(String text) async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String COCO_CITY_ID = (await Utility.getStringPreference(GlobalConstant.COCO_CITY_ID));
    String EMPCODE = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    List a1 = [];

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
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String Item_Id = (await Utility.getStringPreference(GlobalConstant.USER_ID));

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

      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, "Response: " + data1.toString());
          if (data1['status'] == 0) {
            lockStatus = true;

            Popdone = true;
            setState(() {});
            if (data1['ds']['tables'].length > 0) {
              var msg = data1['ds']['tables'][0]['rowsList'][0]["cols"]["Msg"];
              var status = data1['ds']['tables'][0]['rowsList'][0]["cols"]["status"];
              if (msg != "") {
                // GlobalWidget.showMyDialog(context, "", msg);
              }
              if (status == 0) {
                lockStatus = !lockStatus;
              }
            }
            setState(() {});
          } else {
            if (data1['msg'].toString() == "Login failed for user") {
              GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
            } else {
              GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
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

  Future<bool> pop() {
    Navigator.pop(context, Popdone);
  }

  /* getListConditionBased() {
    if (active == 1) {
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
    } else if (active == 2) {
      return new ListView.builder(
          itemCount: Retrived_litems2.length,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext ctxt, int index) {
            return new InkWell(
              onTap: () {},
              child: getRowDataContainer(Retrived_litems2[index], index),
            );
          });
    } else if (active == 3) {
      return new ListView.builder(
          itemCount: SORT_litems2.length,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext ctxt, int index) {
            return new InkWell(
              onTap: () {},
              child: getRowDataContainer(SORT_litems2[index], index),
            );
          });
    } else if (active == 4) {
      return new ListView.builder(
          itemCount: NF_litems2.length,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext ctxt, int index) {
            return new InkWell(
              onTap: () {},
              child: getRowDataContainer(NF_litems2[index], index),
            );
          });
    }
  }*/

  productListView(context) {
    List<Product> mProduct = [];

    if (active == 1) {
      mProduct = pItem;
      print("product-->$product");
    } else if (active == 2) {
      mProduct = rItem;
    } else if (active == 3) {
      mProduct = srItem;
    } else {
      mProduct = nfItem;
    }

    print("mProduct-->${mProduct.toString()}");

    return ListView.builder(
        itemCount: mProduct.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext ctxt, int index) {
          return new InkWell(
            onTap: () {},
            child: itemListTile(
              action: active,
              onUpdate: (
                Product p,
              ) {
                print("onUpdate--->${p.toString()}");
                updateStatusOfItem(status: p.rtvst, index: index, citid: p.citid, itId: p.itId, qty: p.retrivedQty, dataOfList: p);
              },
              product: mProduct[index],
            ),
          );
        });
  }

  Future<void> completeRetriveOrder() async {
    List a1 = [];

    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    var uuid = Uuid();
    Map<String, dynamic> map2() => {
          'pname': 'IndId',
          'value': widget.data['Citid'],
        };
    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'pname': 'PID',
          'value': 2643,
        };
    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());
    Map<String, dynamic> map4() => {
          'pname': 'Ty',
          'value': 13,
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());
    Map<String, dynamic> map5() => {
          'pname': 'dPID',
          'value': COCO_ID,
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };

    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'ForPID',
          'value': widget.data["Tpid"].toString(),
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };

    a1.add(mapobj6());

    Map<String, dynamic> map7() => {
          'pname': 'trnxml',
          'value': "<DocumentElement>" + getSrcXml() + "</DocumentElement>",
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };

    a1.add(mapobj7());

    Map<String, dynamic> map8() => {
          'pname': 'DTy',
          'value': "2",
        };

    var dmap8 = map8();
    Map<String, dynamic> mapobj8() => {
          'cols': dmap8,
        };

    a1.add(mapobj8());

    Map<String, dynamic> map9() => {
          'pname': 'DuId',
          'value': uuid.v4().toString(),
        };

    var dmap9 = map9();
    Map<String, dynamic> mapobj9() => {
          'cols': dmap9,
        };

    a1.add(mapobj9());
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
          'procName': GlobalConstant.StkTrf_NewSave,
          'rid': "",
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': mapfinal(),
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController.postsNew(GlobalConstant.SignUp, json.encode(mapdata())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, "Response: " + data1.toString());
          if (data1['status'] == 0) {
            print("Data__________");
            lockStatus = true;
            Popdone = true;

            if (data1['ds']['tables'].length > 0) {
              var DocNo = data1['ds']['tables'][0]['rowsList'][0]["cols"]["DocNo"];
              String msg = "Doc Created Successful. Doc No is:" + DocNo.toString();
              GlobalWidget.showMyDialog(context, "", msg);
            } else {
              GlobalWidget.showMyDialog(context, "Error ", "Unable to create Doc.");
            }
          } else {
            if (data1['msg'].toString() == "Login failed for user") {
              GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
            } else {
              print("Error--->${data1['msg'].toString()}");
              GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
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
    for (int i = 0; i < Retrived_litems2.length; i++) {
      double qty = (Retrived_litems2[i].qty) - (Retrived_litems2[i].srt_qty);

      src = src +
          "<SV>" +
          "<ItId>" +
          Retrived_litems2[i].data["ItId"] +
          "</ItId>" +
          "<Qty>" +
          qty.toString() +
          "</Qty>" +
          "<RtvBy>" +
          userID +
          "</RtvBy>" +
          "</SV>";
    }

    print("getSrcXml--->$src");
    return src.toString();
  }

  alertReturn() {
    completeRetriveOrder();
  }

  Widget itemListTile({Product product, int action, Function(Product p) onUpdate}) {
    double retrivedQty = 0.0;
    double srtQty = 0.0;
    double total = 0.0;
    bool enablePlusMinus = false;

    String status = "PN";

    bool rt = true;
    bool prt = false;
    bool nf = false;

    retrivedQty = product.qty;
    srtQty = product.srtQty;
    total = product.srtQty + product.qty;
    status = product.rtvst;

    print("widget.index${action}");

    if (action == 1) {
      rt = true;
      prt = false;
      nf = false;
    } else if (action == 2) {
      rt = true;
      prt = false;
      nf = false;
    } else if (action == 3) {
      rt = false;
      prt = true;
      nf = false;
    } else {
      rt = false;
      prt = false;
      nf = true;
    }
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2),
      margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(style: BorderStyle.solid, width: 1.3),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                  flex: 2,
                  child: new Container(
                    child: CachedNetworkImage(
                      imageUrl: GlobalConstant.PhotoUrl + product.imgpath,
                      errorWidget: (context, url, error) => Image.asset("assets/loading.png"),
                      fit: BoxFit.contain,
                    ),
                  )),
              Expanded(
                  flex: 8,
                  child: new Container(
                    padding: EdgeInsets.only(left: 10.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalWidget.getRowInsideDevide(),
                        new Text(
                          product.itName,
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                          textAlign: TextAlign.left,
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            Expanded(
                              child: new Text(
                                "Barcode : " + product.barcode,
                                style: TextStyle(color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              child: new Text(
                                "Stk : " + product.stock,
                                style: TextStyle(color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: new Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (enablePlusMinus && retrivedQty != 0.0) {
                                        retrivedQty = retrivedQty - 1.0;
                                        srtQty = srtQty + 1.0;

                                        setState(() {});
                                      }
                                    },
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: enablePlusMinus ? colorPrimary : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    retrivedQty.toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (enablePlusMinus && retrivedQty != total) {
                                        srtQty = srtQty - 1.0;

                                        retrivedQty = retrivedQty + 1.0;

                                        setState(() {});
                                      }
                                    },
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: enablePlusMinus ? colorPrimary : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "SRT QTY : ${srtQty}",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: new Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      rt = true;
                                      prt = false;
                                      nf = false;

                                      retrivedQty = total;
                                      srtQty = 0.0;

                                      status = "RT";
                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          rt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: rt ? colorPrimary : Colors.grey,
                                        ),
                                        Text(
                                          "RT",
                                          style: TextStyle(color: rt ? colorPrimary : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (total != 1) {
                                        rt = false;
                                        prt = true;
                                        nf = false;
                                        enablePlusMinus = true;
                                        status = "PRT";
                                      }

                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          prt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: prt ? colorPrimary : Colors.grey,
                                        ),
                                        Text(
                                          "PRT",
                                          style: TextStyle(
                                            color: prt ? colorPrimary : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      rt = false;
                                      prt = false;
                                      nf = true;
                                      srtQty = total;
                                      retrivedQty = 0.0;
                                      status = "NF";

                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          nf ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: nf ? colorPrimary : Colors.grey,
                                        ),
                                        Text(
                                          "NF",
                                          style: TextStyle(color: nf ? colorPrimary : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  if (lockStatus == true) {
                                    double qty = 0.0;

                                    print("ok--->${product.rtvst}");
                                    if (status == "NF") {
                                      status = "NF";

                                      product.qty = 0.0;
                                      product.srtQty = srtQty;
                                      product.sortQty = srtQty;
                                      product.totalQty = total;
                                      product.retrivedQty = retrivedQty;
                                      product.rtvst = status;

                                      onUpdate(product);
                                    } else if (status == "RT") {
                                      status = "RT";
                                      product.srtQty = srtQty;
                                      product.qty = total;
                                      product.sortQty = srtQty;
                                      product.totalQty = total;
                                      product.retrivedQty = retrivedQty;
                                      product.rtvst = status;

                                      onUpdate(product);
                                    } else if (status == "PRT") {
                                      status = "PRT";
                                      if (srtQty == 0.0) {
                                        GlobalWidget.showMyDialog(context,
                                            "Short Qty Can't be zero for Partial Not Found.Use NF Option for all Item Not found", "");
                                      } else if (retrivedQty == 0.0) {
                                        GlobalWidget.showMyDialog(
                                            context,
                                            "",
                                            "Short Qty Can't be equalt to Qty for Partial Not Found.Use NF Option for all Item Not found"
                                                "");
                                      } else {
                                        // widget.product.retrivedQty = retrivedQty;
                                        // widget.product.srtQty = srtQty;
                                        product.srtQty = srtQty;
                                        product.sortQty = srtQty;
                                        product.totalQty = total;
                                        product.retrivedQty = retrivedQty;
                                        product.qty = retrivedQty;
                                        product.rtvst = status;

                                        onUpdate(product);
                                      }
                                    }
                                  } else {
                                    GlobalWidget.showMyDialog(context, "Alert", "Please Lock Order First ");
                                  }
                                },
                                child: new Container(
                                  width: 20.0,
                                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                                  child: Text(
                                    "Ok",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                ),
                              ),
                            )
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class PendingModel {
  var data;
  bool flag_RT, flag_nf, flag_srt;
  double srt_qty;
  double qty;

  PendingModel(this.data, this.imagpath, this.flag_RT, this.flag_nf, this.flag_srt, this.qty, this.srt_qty);

  String imagpath;
}

class Product {
  Product({
    this.itId,
    this.barcode,
    this.qty,
    this.citid,
    this.section,
    this.secid,
    this.mainCat,
    this.imgpath,
    this.stock,
    this.itName,
    this.rtvst,
    this.srtQty,
  });

  String itId;
  String barcode;
  double qty;
  String citid;
  String section;
  String secid;
  String mainCat;
  String imgpath;
  String stock;
  String itName;
  String rtvst;
  double srtQty;
  double retrivedQty = 0;
  double sortQty = 0;
  double totalQty = 0.0;
  bool pending = false;
  bool notFont = false;

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        itId: json["ItId"] == null ? null : json["ItId"],
        barcode: json["Barcode"] == null ? null : json["Barcode"],
        qty: json["Qty"] == null ? 0.0 : double.parse(json["Qty"].toString()),
        citid: json["Citid"] == null ? null : json["Citid"],
        section: json["Section"] == null ? null : json["Section"],
        secid: json["Secid"] == null ? null : json["Secid"],
        mainCat: json["MainCat"] == null ? null : json["MainCat"],
        imgpath: json["Imgpath"] == null ? "" : json["Imgpath"],
        stock: json["Stock"] == null ? null : json["Stock"],
        itName: json["ItName"] == null ? null : json["ItName"],
        rtvst: json["Rtvst"] == null ? null : json["Rtvst"],
        srtQty: json["schqty"] == null ? 0.0 : double.parse(json["schqty"].toString()),
      );

  Map<String, dynamic> toMap() => {
        "ItId": itId == null ? null : itId,
        "Barcode": barcode == null ? null : barcode,
        "Qty": qty == null ? null : qty,
        "Citid": citid == null ? null : citid,
        "Section": section == null ? null : section,
        "Secid": secid == null ? null : secid,
        "MainCat": mainCat == null ? null : mainCat,
        "Imgpath": imgpath == null ? null : imgpath,
        "Stock": stock == null ? null : stock,
        "ItName": itName == null ? null : itName,
        "Rtvst": rtvst == null ? null : rtvst,
        "schqty": srtQty == null ? null : srtQty,
      };

  @override
  String toString() {
    return 'Product{itId: $itId, barcode: $barcode, qty: $qty, citid: $citid, section: $section, secid: $secid, mainCat: $mainCat, imgpath: $imgpath, stock: $stock, itName: $itName, rtvst: $rtvst, srtQty: $srtQty, retrivedQty: $retrivedQty, sortQty: $sortQty, totalQty: $totalQty, pending: $pending, notFont: $notFont}';
  }
}
