import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/DatabaseHelper/DBConstant.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:rxdart/rxdart.dart';

import 'SearchModel.dart';

class SearchItem extends StatefulWidget {
  static String tag = 'SearchItem';
  @override
  _SearchItemState createState() => new _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
//  List<SearchModel> _items = new List();
  final subject = new PublishSubject<String>();
  bool _isLoading = true;
  List<SearchModel> duplicateItems = [];
  List<SearchModel> items = [];
  var products;
  var listdata;

  Future<void> updateData() async {
    List a1 = [];
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': COCO_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map_l() => {
          'pname': 'LastTs',
          'value': "249809721",
        };

    var dmap_l = map_l();
    Map<String, dynamic> mapobj_l() => {
          'cols': dmap_l,
        };
    a1.add(mapobj_l());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.lib_ItemSyncRates_stk,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': 200,
          "param": map1()
        };

    print("datatval2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) {
        try {
          var data1 = json.decode(value.body);
          if (data1['status'] == 0) {
            products = data1['ds']['tables'][0]['rowsList'];
            for (int i = 0; i < products.length; i++) {
              _addBook(products[i]['cols']);
              setState(() {});
            }
            items.addAll(duplicateItems);
            setState(() {
              Dialogs.hideProgressDialog(context);
            });
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
      String Name = GlobalWidget.getDatafromJson(book[DBConstant.PRODUCT_DATA], "ItName");
      String id = GlobalWidget.getDatafromJson(book[DBConstant.PRODUCT_DATA], "ItId");
      var data = json.decode(book[DBConstant.PRODUCT_DATA]);
      //   print(Name);
      duplicateItems.add(new SearchModel(Name.trim(), "${id}", data));
    });
  }

  //FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    getDatafromLocal();
    //  UpdateData();
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
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: colorPrimary,
        title: new Container(
          height: 50.0,
          //color: Colors.grey[300],
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
                            child: new Icon(Icons.search, color: Colors.white),
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
                              cursorColor: Colors.white,
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
                                color: Colors.white,
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
      ),
      body: new Container(
        margin: EdgeInsets.only(top: 22.0),
        child: new Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _isLoading
                ? new Center(
                    child: new CircularProgressIndicator(),
                  )
                : new Expanded(
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
                            /*

                      Utility.setStringPreference(GlobalConstant.COCO_CITY_ID, items[index].data['ItId'].toString());
                      Utility.setStringPreference(GlobalConstant.COCO_CITY, items[index].data['ItName'].toString());
                      Utility.setStringPreference(GlobalConstant.COCO_CITY_CODE, items[index].data['ItName'].toString());
                      Utility.setStringPreference(GlobalConstant.COCO_ADDRESS, items[index].data['Address'].toString());
*/

                            String idValue = ": \"" + "${items[index].data['ItId'].toString()}" + "\"";
                            String Name_Value = ": \"" + "${items[index].data['ItName'].toString()}" + "\"";

                            String id = "\"id\"";
                            String name = "\"name\"";
                            var json = "{" + id + idValue + "," + name + Name_Value + "}";

                            print(json);
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

  void getDatafromLocal() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts();

    print("lengthdata  ${l1.length}");
    if (l1.length < 0) {
      GlobalWidget.showToast(context, "Please wait untill data is sync ");
    }
    print("dblength ${l1.length}");
    //12974
    for (int i = 0; i < l1.length; i++) {
      _addBook(l1[i]);
    }
    items.addAll(duplicateItems);
    setState(() {});
    if (items.length > 0) {
      _isLoading = false;
    }
  }
}
