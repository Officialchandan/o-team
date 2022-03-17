import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

import 'ModelClassReportDetail/GrpModel.dart';

class ReportOverAllSaleDetailActivity extends StatefulWidget {
  String city_params, Api_Name, title, date_req;
  ReportOverAllSaleDetailActivity(
      this.city_params, this.Api_Name, this.title, this.date_req);
  @override
  State<StatefulWidget> createState() {
    return ReoportView();
  }
}

class ReoportView extends State<ReportOverAllSaleDetailActivity> {
  var products;
  var listdata;
  var TAG = "hourlyinflow";

  List<GrpModel> TimeList = new List();
  // List<DateModel> DateList = new List();
  List items = new List();
  List items_column_Heading = new List();
  List items_first_column = new List();

  Future<void> UpdateData() async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String FROM_DATE_HorlyReprt =
        (await Utility.getStringPreference(GlobalConstant.FROM_DATE_Report));
    String TO_DATE_HorlyReprt =
        (await Utility.getStringPreference(GlobalConstant.TO_DATE_Report));
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    String AllCityIds = "";
    if (widget.Api_Name != "rpt_SaleOverall_Mapp") {
      AllCityIds =
          (await Utility.getStringPreference(GlobalConstant.AllCityIds));
    }
    var data = GlobalConstant.GetMapForRePortDetail(
        FROM_DATE_HorlyReprt, TO_DATE_HorlyReprt, AllCityIds, widget.date_req);

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': widget.Api_Name,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController
          .postsNew(GlobalConstant.SignUp, json.encode(map2()))
          .then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, "Response: " + data1.toString());
          if (data1['status'] == 0) {
            if (data1['ds']['tables'].length > 0) {
              var products = data1['ds']['tables'][0]['rowsList'];
              var header = data1['ds']['tables'][0]['header'];

              for (int i = 0; i < header.length; i++) {
                if (i == 0 || i == 1) {
                } else {
                  items_column_Heading.add(header[i]);
                }
              }

              FirstHeadName = header[1]["name"].toString();
              var list = products;
              TimeList = new List();
              //  Utility.log(TAG + " vallength1 ", value.length);
              //timegroup
              var GrpMap = groupBy(
                  list.toList(), (obj) => obj["cols"][header[0]["name"]]);

              //start group time
              GrpMap.forEach((key, value) {
                items_first_column = new List();
                items = new List();
                for (var t in value) {
                  var data = t["cols"];
                  items_first_column.add(data[header[1]["name"]].toString());
                  items.add(data);
                  // items.add(data[0]["cols"]);
                }

                TimeList.add(new GrpModel(key.toString(), items,
                    items_column_Heading, items_first_column));
              }); //end group time

              // SetAmountListIng();
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
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  //FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    UpdateData();
    //_focusNode = FocusNode();
  }

  TextEditingController controller = new TextEditingController();
  @override
  void dispose() {
    // _focusNode.dispose();
    super.dispose();
  }

  String FirstHeadName = "";

  //if row Count 0 so 1st row
  List<Widget> _buildCells(int count, int rowcount, var items) {
    ;
    return List.generate(
      count,
      (index) => rowcount == 0
          ? new Column(
              children: [
                Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: GlobalWidget.getColumWidth(),
                    color: colorPrimary,
                    // margin: EdgeInsets.all(4.0),
                    child: Text(
                      items_column_Heading[index]["name"].toString() +
                          "\n" +
                          GlobalConstant.getamtCount(
                              items_column_Heading[index], items),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    )),
                Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    width: GlobalWidget.getColumWidth(),
                    color: Colors.white,
                    // margin: EdgeInsets.all(4.0),
                    child: Text(
                      GlobalWidget.getstringValue(items[rowcount]
                              [items_column_Heading[index]["name"].toString()]
                          .toString()),
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      maxLines: 1,
                    )),
              ],
            )
          : Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              width: GlobalWidget.getColumWidth(),
              color: rowcount == 0 ? colorPrimary : Colors.white,
              // margin: EdgeInsets.all(4.0),
              child: Text(
                GlobalWidget.getstringValue(items[rowcount]
                        [items_column_Heading[index]["name"].toString()]
                    .toString()),
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              )),
    );
  }

  List<Widget> _buildRows(int no_of_rows, var items) {
    return List.generate(
      no_of_rows,
      (index) {
        return Row(
            children: _buildCells(items_column_Heading.length, index, items));
      },
    );
  }

  static Widget getAllAmount(List<GrpModel> dateList, items_column_heading) {
    double amt = 0.0;

    try {
      for (var d1 in dateList) {
        var items = d1.items;
        for (var itemsobj in items) {
          try {
            amt = amt + double.parse(itemsobj[items_column_heading["name"]]);
          } catch (e) {}
        }
      }

      amt = GlobalConstant.ConvertDecimal(amt);
      return items_column_heading["type"] != "varchar"
          ? GlobalConstant.getContainer(amt, items_column_heading["name"])
          : new Container();
    } catch (e) {}

    return new Container();
  }

  getListIng() {
    return ListView.builder(
        itemCount: TimeList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index1) {
          return InkWell(
            onTap: () {},
            child: ExpansionTile(
              title: Text(TimeList[index1].TimeGroup),
              children: [
                SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: GlobalConstant.buildCellsHeding(
                            TimeList[index1].items_first_column.length,
                            TimeList[index1].items_first_column,
                            FirstHeadName,
                            context),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildRows(
                                TimeList[index1].items_first_column.length,
                                TimeList[index1].items),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: GlobalWidget.getAppbar(widget.title),
      body: new ListView(
        shrinkWrap: true,
        children: [
          items_column_Heading.length > 0 ? getListIng() : new Container(),
          items_column_Heading.length > 0
              ? new Container(
                  height: 60.0,
                  child: new ListView.builder(
                    itemCount: items_column_Heading.length,
                    itemBuilder: (context, index_head) {
                      return getAllAmount(
                          TimeList, items_column_Heading[index_head]);
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                )
              : new Container(),
/*
            amt_firstcolumn_list.length > 0
                ?SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildCellsHedingAmt(amt_firstcolumn_list
                            .length,
                        amt_firstcolumn_list),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildRowsAmt(amt_firstcolumn_list
                                .length,
                           amt_firstcolumn_list),
                      ),
                    ),
                  )
                ],
              ),
            ):new Container()
         */
        ],
      ),
    );
  }

//Create a single table
}
