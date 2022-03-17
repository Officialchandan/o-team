import 'dart:convert';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/CityModel.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/DateModel.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/GrpModel.dart';

import '../ApiController.dart';
import '../Dialogs.dart';
import '../GlobalConstant.dart';
import '../GlobalWidget.dart';
import '../NetworkCheck.dart';

class MyAppReportNew extends StatefulWidget {
  @override
  _MyAppReportNewState createState() => _MyAppReportNewState();
}

class _MyAppReportNewState extends State<MyAppReportNew> {
  List<GrpModel> TimeList = new List();
  List<DateModel> DateList = new List();
  List<CityModel> city_modelList = new List();
  List items = new List();
  List items_column_Heading = new List();
  List items_first_column = new List();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Tutorial - TutorialKart'),
        ),
        body: new ListView(
          shrinkWrap: true,
          children: [
            items_column_Heading.length > 0
                ? new Container(
                    height: 60.0,
                    child: new ListView.builder(
                      itemCount: items_column_Heading.length,
                      itemBuilder: (context, index_head) {
                        return GlobalConstant.getAllAmount(
                            city_modelList, items_column_Heading[index_head]);
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                  )
                : new Container(),
            items_column_Heading.length > 0
                ? ListView.builder(
                    itemCount: city_modelList.length,
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, cityIndex) {
                      return ExpansionTile(
                        title: Text(city_modelList[cityIndex].CityName),
                        children: [
                          new Container(
                            height: 60.0,
                            child: new ListView.builder(
                              itemCount: items_column_Heading.length,
                              itemBuilder: (context, index_head) {
                                return GlobalConstant.getCityWiseAmount(
                                    city_modelList[cityIndex].DateList,
                                    city_modelList[cityIndex].DateList.length,
                                    items_column_Heading[index_head]);
                              },
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                          getListIng(cityIndex)
                        ],
                      );
                    })
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
        )

        /**/,
      ),
    );
  }

  @override
  void initState() {
    UpdateData();
    setState(() {});
  }

  //if row Count 0 so 1st row
  List<Widget> _buildCells(int count, int rowcount, var items) {
    return List.generate(
      count,
      (index) => Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 150.0,
        color: rowcount == 0 ? colorPrimary : Colors.white,
        // margin: EdgeInsets.all(4.0),
        child: rowcount == 0
            ? Text(
                items_column_Heading[index]["name"].toString() +
                    "\n" +
                    GlobalConstant.getamtCount(
                        items_column_Heading[index], items),
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
              )
            : Text(
                items[rowcount][items_column_Heading[index]["name"].toString()]
                    .toString(),
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              ),
      ),
    );
  }

  //if row Count 0 so 1st row
  List<Widget> _buildCellsAmt(int count, int rowcount, var items1) {
    ;
    return List.generate(
      count,
      (index) => Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 150.0,
        color: rowcount == 0 ? colorPrimary : Colors.white,
        // margin: EdgeInsets.all(4.0),
        child: rowcount == 0
            ? Text(
                "" + amt_header_list[index],
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
              )
            : Text(
                GlobalConstant.GetAmountVal(city_modelList,
                    items1[rowcount].Header.toString(), amt_header_list[index]),
                //amt_header_list[index],
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              ),
      ),
    );
  }

  //colum 1
  List<Widget> _buildCellsHeding(int count, items_first_column) {
    return List.generate(
      count,
      (index) => Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10.0),
        width: 200.0,
        color: index != 0 ? Colors.white : colorPrimary,
        //margin: EdgeInsets.all(4.0),
        child: index == 0
            ? Text(
                "COCO\n",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
              )
            : Text(
                items_first_column[index].toString(),
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              ),
      ),
    );
  }

  //colum 1
  List<Widget> _buildCellsHedingAmt(int count, items_first_column) {
    return List.generate(
      count,
      (index) => Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10.0),
        width: 200.0,
        color: index != 0 ? Colors.white : colorPrimary,
        //margin: EdgeInsets.all(4.0),
        child: index == 0
            ? Text(
                "COCO",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
              )
            : Text(
                amt_firstcolumn_list[index].Header.toString(),
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              ),
      ),
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

  List<Widget> _buildRowsAmt(int no_of_rows, var items) {
    return List.generate(
      no_of_rows,
      (index) {
        return Row(
            children: _buildCellsAmt(amt_header_list.length, index, items));
      },
    );
  }

  String TAG = "TAG";

  Future<void> UpdateData() async {
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String FROM_DATE_Report =
        (await Utility.getStringPreference(GlobalConstant.FROM_DATE_Report));
    String TO_DATE_Report =
        (await Utility.getStringPreference(GlobalConstant.TO_DATE_Report));
    String AllCityIds =
        (await Utility.getStringPreference(GlobalConstant.AllCityIds));

    /* var data = GlobalConstant.GetMapForRePortDetail(
        "2020-12-28", TO_DATE_Report, AllCityIds, "1");*/
    var data = GlobalConstant.GetMapForRePortDetail(
        FROM_DATE_Report, TO_DATE_Report, AllCityIds, "1");

    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': "rpt_SaleOverall",
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
          if (data1['ds']['tables'].length > 0) {
            var products = data1['ds']['tables'][0]['rowsList'];
            var header = data1['ds']['tables'][0]['header'];

            for (int i = 0; i < header.length; i++) {
              if (i != 2) {
                items_column_Heading.add(header[i]);
              }
            }

            var list = products;
            var Grp2Map = groupBy(list, (obj) => obj["cols"]['grp1']);
            Grp2Map.forEach((key_city, city_value) {
              DateList = new List();
              //dategroup
              var Grp1Map =
                  groupBy(city_value.toList(), (obj) => obj["cols"]['grp1']);
              //start  date loop

              Grp1Map.forEach((key_date, value) {
                TimeList = new List();
                //  Utility.log(TAG + " vallength1 ", value.length);
                //timegroup
                var GrpMap =
                    groupBy(value.toList(), (obj) => obj["cols"]['grp']);

                //start group time
                GrpMap.forEach((key, value) {
                  items_first_column = new List();
                  items = new List();
                  for (var t in value) {
                    var data = t["cols"];
                    items_first_column.add(data["Head"].toString());
                    items.add(data);
                    // items.add(data[0]["cols"]);
                  }

                  TimeList.add(new GrpModel(key.toString(), items,
                      items_column_Heading, items_first_column));
                }); //end group time

                DateList.add(new DateModel(key_date, TimeList));
              });
              //end date loop

              city_modelList.add(new CityModel(key_city, DateList));
            });

            SetAmountListIng();
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

  getListIng(int cityindex) {
    return ListView.builder(
        itemCount: city_modelList[cityindex].DateList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, dateIndex) {
          return ExpansionTile(
            title:
                Text(city_modelList[cityindex].DateList[dateIndex].DateString),
            children: [
              new Container(
                height: 60.0,
                child: new ListView.builder(
                  itemCount: items_column_Heading.length,
                  itemBuilder: (context, index_head) {
                    return GlobalConstant.getDateWiseAmount(
                        city_modelList[cityindex]
                            .DateList[dateIndex]
                            .grp_modelList,
                        city_modelList[cityindex]
                            .DateList[dateIndex]
                            .grp_modelList
                            .length,
                        items_column_Heading[index_head]);
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
              ListView.builder(
                  itemCount: city_modelList[cityindex]
                      .DateList[dateIndex]
                      .grp_modelList
                      .length,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index1) {
                    return InkWell(
                      onTap: () {},
                      child: ExpansionTile(
                        title: Text(city_modelList[cityindex]
                            .DateList[dateIndex]
                            .grp_modelList[index1]
                            .TimeGroup),
                        children: [
                          SingleChildScrollView(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildCellsHeding(
                                      city_modelList[cityindex]
                                          .DateList[dateIndex]
                                          .grp_modelList[index1]
                                          .items_first_column
                                          .length,
                                      city_modelList[cityindex]
                                          .DateList[dateIndex]
                                          .grp_modelList[index1]
                                          .items_first_column),
                                ),
                                Flexible(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: _buildRows(
                                          city_modelList[cityindex]
                                              .DateList[dateIndex]
                                              .grp_modelList[index1]
                                              .items_first_column
                                              .length,
                                          city_modelList[cityindex]
                                              .DateList[dateIndex]
                                              .grp_modelList[index1]
                                              .items),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  })
            ],
          );
        });
  }

  List amt_header_list = new List();
  List<RowFirstListVal> amt_firstcolumn_list = new List();
  List<RowListVal> RowValue_List = new List();

  //for Amount heading Name
  void SetAmountListIng() {
    double amt = 0.0;
    try {
      for (var items in items_column_Heading) {
        if (items["type"] == "int" || items["type"] == "decimal") {
          amt_header_list.add(items["name"].toString());
        }
      }

      for (var amt_head in amt_header_list) {
        Utility.log(TAG, amt_head);
      }
    } catch (e) {
      Utility.log(TAG, e.toString());
    }

    GetCityAmountValue();
  }

  void GetCityAmountValue() {
    double amt = 0.0;
    try {
      amt_firstcolumn_list.add(new RowFirstListVal("city", "", new List()));

      for (var items in city_modelList) {
        amt_firstcolumn_list
            .add(new RowFirstListVal("city", items.CityName, new List()));

        for (var dates in items.DateList) {
          amt_firstcolumn_list
              .add(new RowFirstListVal("date", dates.DateString, new List()));
          for (var times in dates.grp_modelList) {
            amt_firstcolumn_list
                .add(new RowFirstListVal("time", times.TimeGroup, new List()));
          }
        }
      }

      for (var amt_head in amt_firstcolumn_list) {
        Utility.log(TAG, amt_head.Header);
      }
    } catch (e) {
      Utility.log(TAG, e.toString());
    }
  }
}

class RowListVal {
  String Header;
  String Amount;

  RowListVal(this.Header, this.Amount);
}

class RowFirstListVal {
  String Type;
  String Header;

  RowFirstListVal(this.Type, this.Header, this.items);

  List<RowListVal> items;
}
