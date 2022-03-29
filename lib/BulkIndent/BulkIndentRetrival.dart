import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/BulkIndent/model/BulkIndentRetrivalModel.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/PublishResult.dart';

import 'DistributeIndentDetailClass.dart';
import 'TrnDoc.dart';

class BulkIndentRetrival extends StatefulWidget {
  final secId, secName;
  BulkIndentRetrival(this.secId, this.secName) {
    print("SecId = $secId SecName = $secName");
  }

  @override
  State<StatefulWidget> createState() {
    return BulkIndentView();
  }
}

class BulkIndentView extends State<BulkIndentRetrival> {
  bool isChecked = false;
  String userID = "";
  var TAG = "BulkIndentView";

  bool isDone = false;

  List<String> categories = [];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentStatus;

  List<BulkIndentRetrivalModel> duplicateItems = List<BulkIndentRetrivalModel>();
  List<BulkIndentRetrivalModel> items = List<BulkIndentRetrivalModel>();

  @override
  void initState() {
    super.initState();
    UpdateData();
    subject.stream.listen(_textChanged);
  }

  final subject = new PublishSubject<String>();
  bool _isLoading = false;
  Future _textChanged(String text) async {
    List<BulkIndentRetrivalModel> dummySearchList = List<BulkIndentRetrivalModel>();
    dummySearchList.addAll(duplicateItems);
    if (text.isNotEmpty) {
      List<BulkIndentRetrivalModel> dummyListData = List<BulkIndentRetrivalModel>();
      dummySearchList.forEach((item) {
        if (item.itemName.toLowerCase().contains(text.toLowerCase())) {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GlobalWidget.getAppbar("Bulk Indent Retrieval"),
        body: getWidget(),
        bottomNavigationBar: getBottomSheet(),
      ),
    );
  }

  TextEditingController controller = new TextEditingController();
  getWidget() {
    print(items.length);
    return new ListView(
      padding: EdgeInsets.all(8.0),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [
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
        ListView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return SetDataOnConditionBase(index);
          },
        ),
      ],
    );
  }

  getBottomSheet() {
    return new Container(
      height: 40.0,
      alignment: Alignment.center,
      child: new Row(
        children: [
          Expanded(
            flex: 4,
            child: new InkWell(
              onTap: () {},
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("cat"),
                  DropdownButton(
                    value: _currentStatus,
                    items: _dropDownMenuItems,
                    onChanged: changedDropDownItem,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: new Row(
              children: [
                Checkbox(
                  value: isDone,
                  onChanged: (newValue) {
                    isDone = newValue;
                    if (newValue == true) {
                      Type = "done_action";
                    } else {
                      Type = "All";
                    }

                    setState(() {});
                  },
                ),
                Text("Done")
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TrnDOCActivity(widget.secId)));
            },
            child: Expanded(
              flex: 3,
              child: Text("Retrive"),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  changedDropDownItem(String value) {
    setState(() {
      _currentStatus = value;
      Type = value;
      Utility.log(TAG, value);
      setState(() {});
    });
  }

  Future<void> UpdateData() async {
    duplicateItems = new List();
    items = new List();
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    var data = GlobalConstant.GetMapBulkIndentRetrival(COCO_ID, 2, widget.secId);
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_StkTrf_BulkIndSumm,
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
          var products = data1['ds']['tables'][0]['rowsList'];
          Utility.log(TAG, data1['status']);

          for (int i = 0; i < products.length; i++) {
            _addBook(products[i]['cols']);
          }
          items.addAll(duplicateItems);
          initDropdown();
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

  void _addBook(dynamic book) {
    var img = book["ImgPath"];
    var showImage = "";
    try {
      showImage = GlobalConstant.PhotoUrl + img.toString().substring(img.lastIndexOf('\\') + 1, img.lastIndexOf('.')) + "-100x100.jpg";
    } catch (e) {}

    setState(() {
      duplicateItems.add(new BulkIndentRetrivalModel(
          book["MainCat"],
          book["ItId"],
          book["ItemName"],
          showImage,
          book["Stock"],
          book["Qty"],
          book["SQty"],
          book["RQty"],
          book["Status"],
          book["PackSize"],
          book["SecId"],
          book["IndentDt"],
          book["Barcode"],
          book["tCoco"],
          book["LockSt"],
          book,
          false));
    });
  }

  void initDropdown() {
    categories.clear();
    categories.add("All");
    for (int i = 0; i < items.length; i++) {
      if (!categories.contains(items[i].mainCat.toString())) {
        categories.add(items[i].mainCat.toString());
      }
    }

    _dropDownMenuItems = getDropDownMenuItems();
    _currentStatus = _dropDownMenuItems[0].value;

    setState(() {
      print("categories => " + categories.length.toString());
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();

    for (String status in categories) {
      items.add(new DropdownMenuItem(value: status, child: new Text(status)));
    }
    return items;
  }

  getData(int index) {
    return Container(
        width: MediaQuery.of(context).size.width,
        //  height: 200,
        child: Card(
          elevation: 3.0,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Image(
                        image: NetworkImage(items[index].imgPath),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      flex: 8,
                      //width: MediaQuery.of(context).size.width - 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(items[index].itemName),
                          Text("BCode : " + items[index].barCode),
                          new Row(
                            children: [
                              Expanded(
                                child: Text("Qty : " + items[index].qty),
                              ),
                              Expanded(
                                child: Text(
                                  "Stk : " + items[index].stock,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          new Row(
                            children: [
                              Expanded(
                                child: Text("PackSz : " + items[index].packSize),
                              ),
                              Expanded(
                                child: Text(
                                  "Cat : " + items[index].data["MainCat"],
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        items[index].done_flag = !items[index].done_flag;
                        setState(() {});
                      },
                      child: new Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(items[index].done_flag == false ? Icons.check_box_outline_blank : Icons.check_box),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Done",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Text(items[index].tCoco, style: TextStyle(color: greenColor)),
                    Text("RT"),
                    Text("NF"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        shape: GlobalWidget.getButtonThemeDisabeled(),
                        color: GlobalWidget.getDisableColor(),
                        textColor: GlobalWidget.getBtnTextColor(),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DistributeActivity(items[index].data)));
                        },
                        child: Text(
                          'Distribute',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  String Type = "All";
  SetDataOnConditionBase(index) {
    Utility.log(TAG, Type + "  " + index.toString());
    if (Type == "All") {
      return getData(index);
    } else if (Type == items[index].data["MainCat"].toString()) {
      return getData(index);
    } else if (Type == "done_action") {
      if (items[index].done_flag == true) {
        return getData(index);
      } else {
        return new Container();
      }
    } else {
      return new Container();
    }
  }
}
