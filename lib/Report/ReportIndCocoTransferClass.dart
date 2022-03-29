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
import 'package:ondoprationapp/Report/ModelClassReportDetail/DateModel.dart';

import 'ModelClassReportDetail/CityModel.dart';
import 'ModelClassReportDetail/GrpModel.dart';

class InterCocoDetailActivity extends StatefulWidget {
  String city_params, Api_Name, title, date_req;

  InterCocoDetailActivity(this.city_params, this.Api_Name, this.title, this.date_req);

  @override
  State<StatefulWidget> createState() {
    return ReoportView();
  }
}

class ReoportView extends State<InterCocoDetailActivity> {
  List<GrpModel> TimeList = new List();
  List<DateModel> DateList = new List();
  List<CityModel> city_modelList = new List();
  List items = new List();
  List items_column_Heading = new List();
  List items_first_column = new List();

  var products;

  var listdata;

  var TAG = "InterCocoDetail";

  Future<void> UpdateData() async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String FROM_DATE_InterCoco = (await Utility.getStringPreference(GlobalConstant.FROM_DATE_Report));
    String TO_DATE_InterCoco = (await Utility.getStringPreference(GlobalConstant.TO_DATE_Report));
    String AllCityIds = (await Utility.getStringPreference(GlobalConstant.AllCityIds));

    var data = GlobalConstant.GetMapForRePortDetail(FROM_DATE_InterCoco, TO_DATE_InterCoco, AllCityIds, widget.date_req);

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

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
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var products = data1['ds']['tables'][0]['rowsList'];
            var header = data1['ds']['tables'][0]['header'];

            /* for (int i = 0; i < products.length; i++) {
                _addBook(products[i]['cols']);
              }
              items.addAll(duplicateItems);
              Utility.log(TAG,items.length);
              */
            for (int i = 0; i < header.length; i++) {
              if (i == 0 || i == 2 || i == 1 || i == 3) {
              } else {
                items_column_Heading.add(header[i]);
              }
            }
            FirstHeadName = header[3]["name"];

            var list = products;
            var Grp2Map = groupBy(list, (obj) => obj["cols"][header[0]["name"]]);
            Grp2Map.forEach((key_city, city_value) {
              DateList = new List();
              //dategroup
              var Grp1Map = groupBy(city_value.toList(), (obj) => obj["cols"][header[1]["name"]]);
              //start  date loop

              Grp1Map.forEach((key_date, value) {
                TimeList = new List();
                //  Utility.log(TAG + " vallength1 ", value.length);
                //timegroup
                var GrpMap = groupBy(value.toList(), (obj) => obj["cols"][header[2]["name"]]);

                //start group time
                GrpMap.forEach((key, value) {
                  items_first_column = new List();
                  items = new List();
                  String fromcoco = key;

                  //items_first_column.add(data[].toString());
                  for (int i = 0; i < value.length; i++) {
                    var data = value[i]["cols"];
                    items_first_column.add(data[header[3]["name"]].toString());
                    fromcoco = data[header[3]["name"]].toString();
                    items.add(data);
                  }

                  Utility.log(TAG + " lastcolumlen", fromcoco + " " + items.length.toString() + "  " + key_city);
                  /*for (var t in value) {

                    }
*/
                  TimeList.add(new GrpModel(key.toString(), items, items_column_Heading, items_first_column));
                }); //end group time

                DateList.add(new DateModel(key_date, TimeList));
              });
              //end date loop

              city_modelList.add(new CityModel(key_city, DateList));
            });

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

  //FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    UpdateData();
    //_focusNode = FocusNode();
  }

  String FirstHeadName = "";
  TextEditingController controller = new TextEditingController();

  @override
  void dispose() {
    // _focusNode.dispose();
    super.dispose();
  }

  getListIng(int cityindex) {
    return ListView.builder(
        itemCount: city_modelList[cityindex].DateList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, dateIndex) {
          return ExpansionTile(
            title: Text(city_modelList[cityindex].DateList[dateIndex].DateString),
            children: [
              new Container(
                height: 60.0,
                child: new ListView.builder(
                  itemCount: items_column_Heading.length,
                  itemBuilder: (context, index_head) {
                    return GlobalConstant.getDateWiseAmount(city_modelList[cityindex].DateList[dateIndex].grp_modelList,
                        city_modelList[cityindex].DateList[dateIndex].grp_modelList.length, items_column_Heading[index_head]);
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
              ListView.builder(
                  itemCount: city_modelList[cityindex].DateList[dateIndex].grp_modelList.length,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index1) {
                    return InkWell(
                      onTap: () {},
                      child: ExpansionTile(
                        title: Text(city_modelList[cityindex].DateList[dateIndex].grp_modelList[index1].TimeGroup),
                        children: [
                          SingleChildScrollView(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: GlobalConstant.buildCellsHeding(
                                      city_modelList[cityindex].DateList[dateIndex].grp_modelList[index1].items_first_column.length,
                                      city_modelList[cityindex].DateList[dateIndex].grp_modelList[index1].items_first_column,
                                      FirstHeadName,
                                      context),
                                ),
                                Flexible(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _buildRows(
                                          city_modelList[cityindex]
                                              .DateList[dateIndex]
                                              .grp_modelList[index1]
                                              .items_first_column
                                              .length,
                                          city_modelList[cityindex].DateList[dateIndex].grp_modelList[index1].items),
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
                          GlobalConstant.getamtCount(items_column_Heading[index], items),
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
                      GlobalWidget.getstringValue(items[rowcount][items_column_Heading[index]["name"].toString()].toString()),
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
                GlobalWidget.getstringValue(items[rowcount][items_column_Heading[index]["name"].toString()].toString()),
                style: TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
              )),
    );
  }

  List<Widget> _buildRows(int no_of_rows, var items) {
    return List.generate(
      no_of_rows,
      (index) {
        return Row(children: _buildCells(items_column_Heading.length, index, items));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: GlobalWidget.getAppbarRefrsh(widget.title, ReturnValue),
      body: new ListView(
        shrinkWrap: true,
        children: [
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
                              return GlobalConstant.getCityWiseAmount(city_modelList[cityIndex].DateList,
                                  city_modelList[cityIndex].DateList.length, items_column_Heading[index_head]);
                            },
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                        getListIng(cityIndex)
                      ],
                    );
                  })
              : new Container(),
          items_column_Heading.length > 0
              ? new Container(
                  height: 60.0,
                  child: new ListView.builder(
                    itemCount: items_column_Heading.length,
                    itemBuilder: (context, index_head) {
                      return GlobalConstant.getAllAmount(city_modelList, items_column_Heading[index_head]);
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  ReturnValue() {
    city_modelList = new List();
    DateList = new List();
    UpdateData();
  }
}

class RetriveModel {
  var data;

  RetriveModel(this.data);
}
