import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/SearchModel.dart';
import 'package:rxdart/rxdart.dart';

import 'SearchModel.dart';

class SearchMenu extends StatefulWidget {
  static String tag = 'SearchMenu';

  @override
  _SearchMenuState createState() => new _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
//  List<SearchModel> _items = new List();
  final subject = new PublishSubject<String>();
  bool _isLoading = false;
  List<SearchModel> duplicateItems = List<SearchModel>();
  List<SearchModel> items = List<SearchModel>();
  var products;

  var listdata;

  Future<void> UpdateData() async {
    String Menu_Data = (await Utility.getStringPreference(GlobalConstant.Menu_Data));
    Utility.log("tag", Menu_Data);

    products = json.decode(Menu_Data);

    for (int i = 0; i < products.length; i++) {
      _addBook(products[i]);
    }
    items.addAll(duplicateItems);
    setState(() {});
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
      String FID = book['FID'].toString();
      switch (FID) {
        case "1":
          String Name = "Order Retrieval";
          duplicateItems.insert(0, new SearchModel(Name, "${book["FID"]}", book));
          break;

        case "2":
          String Name = "Indent Retrieval";
          duplicateItems.insert(2, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "3":
          String Name = "Bulk Indent Retrieval";
          duplicateItems.insert(3, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "4":
          String Name = "Mark Attendance";
          duplicateItems.insert(4, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "5":
          String Name = "Market Survey";
          duplicateItems.insert(5, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "6":
          String Name = "Stock Audit";
          duplicateItems.insert(7, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "7":
          String Name = "Report";
          duplicateItems.insert(9, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "8":
          String Name = "Exception Mobile";
          duplicateItems.insert(12, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "9":
          String Name = "New Order Retrieval";
          duplicateItems.insert(1, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "10":
          String Name = "Store Audit";
          duplicateItems.insert(10, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "11":
          String Name = "Short Item Purchase";
          duplicateItems.insert(11, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "12":
          String Name = "Item Info";
          duplicateItems.insert(8, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "13":
          String Name = "List Based Stock Audit";
          duplicateItems.insert(6, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "14":
          String Name = "Bill Scan";
          duplicateItems.insert(17, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "15":
          String Name = "Inward GRC";
          duplicateItems.insert(15, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "16":
          String Name = "PO RECEIVING";
          duplicateItems.insert(13, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "17":
          String Name = "Inward Vege";
          duplicateItems.insert(14, new SearchModel(Name, "${book["FID"]}", book));
          break;
        case "18":
          String Name = "Dispose Item";
          duplicateItems.insert(16, new SearchModel(Name, "${book["FID"]}", book));
          break;
      }

      //  print(Name);
    });
  }

  //FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    UpdateData();
    subject.stream.listen(_textChanged);
    //_focusNode = FocusNode();
  }

  TextEditingController controller = new TextEditingController();
  @override
  void dispose() {
    // _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return products == null
        ? new Container(
            color: Colors.white,
          )
        : products.length == 0
            ? Text("No data found")
            : new Scaffold(
                body: new Container(
                  margin: EdgeInsets.only(top: 22.0),
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
                                            decoration:
                                                new InputDecoration(hintText: GlobalConstant.SearchHint, border: InputBorder.none),
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
                        child: new ListView.builder(
                          padding: new EdgeInsets.all(10.0),
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  new Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: new Text(items[index].title.toString()),
                                  ),
                                  Divider(
                                    thickness: 2.0,
                                  )
                                ],
                              ),
                              onTap: () {
                                Utility.setStringPreference(GlobalConstant.COCO_CITY_ID, items[index].data['CityId'].toString());
                                Utility.setStringPreference(GlobalConstant.COCO_CITY, items[index].data['CityLbl'].toString());
                                Utility.setStringPreference(GlobalConstant.COCO_CITY_CODE, items[index].data['CityLbl'].toString());
                                Utility.setStringPreference(GlobalConstant.COCO_ADDRESS, items[index].data['Address'].toString());

                                String idValue = ": \"" + "${items[index].data['CityId'].toString()}" + "\"";
                                String Name_Value = ": \"" + "${items[index].data['CityLbl'].toString()}" + "\"";

                                String id = "\"id\"";
                                String name = "\"name\"";
                                var json = "{" + id + idValue + "," + name + Name_Value + "}";
                                Navigator.pop(context, json);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}
