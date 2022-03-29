import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalListHorizontal.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/SearchModel.dart';
import 'package:rxdart/rxdart.dart';

class VehicleNotOutActivity extends StatefulWidget {
  String city_params, Api_Name, title, date_req;
  VehicleNotOutActivity(this.city_params, this.Api_Name, this.title, this.date_req);

  @override
  State<StatefulWidget> createState() {
    return ReoportView();
  }
}

class ReoportView extends State<VehicleNotOutActivity> {
//  List<SearchModel> _items = new List();
  final subject = new PublishSubject<String>();
  bool _isLoading = false;
  List<SearchModel> duplicateItems = List<SearchModel>();
  List<SearchModel> items = List<SearchModel>();
  var products;

  var listdata;

  var TAG = "ReprtDetailClass";

  Future<void> UpdateData() async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String FROM_DATE_OverAllSale = (await Utility.getStringPreference(GlobalConstant.FROM_DATE_Report));
    String TO_DATE_OverAllSale = (await Utility.getStringPreference(GlobalConstant.TO_DATE_Report));

    var data = GlobalConstant.GetMapForRePortDetail(FROM_DATE_OverAllSale, TO_DATE_OverAllSale, widget.city_params, widget.date_req);

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

      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          if (data1['status'] == 0) {
            if (data1['ds']['tables'].length > 0) {
              var products = data1['ds']['tables'][0]['rowsList'];
              for (int i = 0; i < products.length; i++) {
                _addBook(products[i]['cols']);
              }
              items.addAll(duplicateItems);
              Utility.log(TAG, items.length);
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
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  Future _textChanged(String text) async {
    List<SearchModel> dummySearchList = List<SearchModel>();
    dummySearchList.addAll(duplicateItems);
    if (text.isNotEmpty) {
      List<SearchModel> dummyListData = List<SearchModel>();
      dummySearchList.forEach((item) {
        if (item.title.toLowerCase().contains(text.toLowerCase())) {
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

  void _addBook(dynamic book) {
    setState(() {
      String Name = book['DocDate'].toString();
      duplicateItems.add(new SearchModel(Name.trim(), "${book["DocDate"]}", book));
    });
  }

  //FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    UpdateData();
    subject.stream.listen(_textChanged);
  }

  TextEditingController controller = new TextEditingController();
  @override
  void dispose() {
    // _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: GlobalWidget.getAppbar(widget.title),
      body: new Container(
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
                                  //  autofocus: true,
                                  controller: controller,
                                  cursorColor: Colors.black,
                                  decoration: new InputDecoration(hintText: GlobalConstant.SearchHint, border: InputBorder.none),
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
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
            _isLoading
                ? new Center(
                    child: new CircularProgressIndicator(),
                  )
                : new Container(),
            new Expanded(
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  //Create a form
  Widget _buildChart() {
    return ListView(
      children: [
        Container(
          child: Row(
            children: <Widget>[
              Container(
                child: Table(children: _buildTableColumnOne()),
                width: GlobalHorizontal.getRowWidth, //Fix the first column
              ),
              Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        child: Table(children: _buildTableRow()),
                        width: GlobalHorizontal.getRowHeight * 30,
                      )))
            ],
          ),
        )
      ],
    );
  }

  //Create the first column row

  List<TableRow> _buildTableColumnOne() {
    List<TableRow> returnList = new List();
    returnList.add(_buildSingleColumnOne(-1));
    for (int i = 0; i < items.length; i++) {
      returnList.add(_buildSingleColumnOne(i));
    }
    return returnList;
  }

  //Create tableRows
  List<TableRow> _buildTableRow() {
    List<TableRow> returnList = new List();
    returnList.add(_buildSingleRow(-1));
    for (int i = 0; i < items.length; i++) {
      returnList.add(_buildSingleRow(i));
    }
    return returnList;
  }

  //Create the first column tableRow
  TableRow _buildSingleColumnOne(int index) {
    return TableRow(
        //First line style add background color
        children: [
          //Increase row height
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'Date' : items[index].title.toString(), index == -1),
        ]);
  }

  //Create a row of tableRow
  TableRow _buildSingleRow(int index) {
    return TableRow(
        //First line style add background color
        children: [
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'Status' : items[index].data["Status"].toString(), index == -1),
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'DocNo' : items[index].data["DocNo"].toString(), index == -1),
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'Remarks' : items[index].data["Remarks"].toString(), index == -1),
          GlobalHorizontal.buildSideBox(
              index, index == -1 ? 'FromLocation' : items[index].data["FromLocation"].toString(), index == -1),
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'ToLocation' : items[index].data["ToLocation"].toString(), index == -1),
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'DocTy' : items[index].data["DocTy"].toString(), index == -1),
          GlobalHorizontal.buildSideBox(index, index == -1 ? 'AvgGrcSale' : items[index].data["AvgGrcSale"].toString(), index == -1),
        ]);
  }
  //Create a single table
}

class RetriveModel {
  var data;
  RetriveModel(this.data);
}
