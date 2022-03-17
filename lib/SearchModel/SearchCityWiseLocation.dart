import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:rxdart/rxdart.dart';

import 'SearchModel.dart';

class SearchCityWiseLoc extends StatefulWidget {
  static String tag = 'SearchCityWiseLoc';
  String City_Id;

  SearchCityWiseLoc(this.City_Id);

  @override
  _SearchCityWiseLocState createState() => new _SearchCityWiseLocState();
}

class _SearchCityWiseLocState extends State<SearchCityWiseLoc> {
//  List<SearchModel> _items = new List();
  final subject = new PublishSubject<String>();
  bool _isLoading = false;
  List<SearchModel> duplicateItems = List<SearchModel>();
  List<SearchModel> items = List<SearchModel>();
  var products;

  var listdata;

  Future<void> UpdateData() async {
    Map<String, dynamic> map() => {
          'pname': 'CityId',
          'value': widget.City_Id,
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
          'procName': GlobalConstant.Mapp_FillLoc,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': map1(),
        };

    print("datatval2 ${json.encode(map2())}");
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
          if (data1['status'] == 0) {
            products = data1['ds']['tables'][0]['rowsList'];
            for (int i = 0; i < products.length; i++) {
              _addBook(products[i]['cols']);
            }

            items.addAll(duplicateItems);
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
          GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
        }
      });
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
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
      String Name = book['Location'].toString();
      print(Name);
      duplicateItems
          .add(new SearchModel(Name.trim(), "${book["LocId"]}", book));
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
                                          child: new Icon(Icons.search,
                                              color: Colors.black),
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
                                            decoration: new InputDecoration(
                                                hintText:
                                                    GlobalConstant.SearchHint,
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
                                    child:
                                        new Text(items[index].title.toString()),
                                  ),
                                  Divider(
                                    thickness: 2.0,
                                  )
                                ],
                              ),
                              onTap: () {
                                /*    Utility.setStringPreference(GlobalConstant.COCO_CITY_ID, items[index].data['PID'].toString());
                      Utility.setStringPreference(GlobalConstant.COCO_CITY, items[index].data['Pname'].toString());
                      Utility.setStringPreference(GlobalConstant.COCO_CITY_CODE, items[index].data['Pname'].toString());
                      Utility.setStringPreference(GlobalConstant.COCO_ADDRESS, items[index].data['Address'].toString());

*/

                                String idValue = ": \"" +
                                    "${items[index].data['LocId'].toString()}" +
                                    "\"";
                                String Name_Value = ": \"" +
                                    "${items[index].data['Location'].toString()}" +
                                    "\"";

                                String id = "\"id\"";
                                String name = "\"name\"";
                                var json = "{" +
                                    id +
                                    idValue +
                                    "," +
                                    name +
                                    Name_Value +
                                    "}";
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
