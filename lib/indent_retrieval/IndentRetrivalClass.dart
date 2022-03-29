import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/indent_retrieval/new_indent_class.dart';

class IndentRetrivalActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return orderRetriveView();
    //You missed initialization part of state object.
  }
}

class orderRetriveView extends State<IndentRetrivalActivity> {
  List<RetriveModel> litems = [];
  List itemList = [];

  var data;
  String TAG = "IndentRetrivalActivity";

  int current_index = 0;
  bool valueTrue = false;
  bool _refreshing = false;
  bool isOpenDrop = false;
  bool lockStatus = false;
  @override
  void initState() {
    updateData();
    super.initState();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  String valuesend = GlobalConstant.Loading;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: new Scaffold(
          appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
          bottomNavigationBar: getBottomSheet(),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            // onRefresh: _refresh,
            onRefresh: () {
              _refresh();
              setState(() {
                _refreshing = true;
              });
              return new Future.delayed(const Duration(milliseconds: 10), () {});
            },
            child: litems.length > 0
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: new ListView.builder(
                        itemCount: litems.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new InkWell(
                            onTap: () async {
                              await Navigator.of(context)
                                  .push(
                                MaterialPageRoute(builder: (_) => NewIndentClass(litems[index].data)),
                              )
                                  .then((val) {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                if (val != null) {
                                  print("litems---->$litems");
                                  updateData();
                                }
                              });
                            },
                            child: selected_Type == "All" ? getRowData(index, "All") : getRowData(index, selected_Type),
                          );
                        }),
                  )
                : GlobalWidget.getNoRecords(context, valuesend),
          )),
    );
  }

  Future<void> updateData() async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    var data = GlobalConstant.GetMapForIndent(COCO_ID);
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_StkTrf_IndSumm,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      // Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.post(url: GlobalConstant.SignUp, input: map2());
        var data1 = data;
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var list = data1['ds']['tables'][0]['rowsList'];
            setListInItem(list);
          } else {
            debugPrint("No record->0");
            valuesend = GlobalConstant.noRecord;
            valueTrue = true;
            setState(() {});
          }
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            debugPrint("No record->1");
            valuesend = GlobalConstant.noRecord;
            GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        debugPrint("No record->2");
        print("e-------------$e");
        valuesend = GlobalConstant.noRecord;
        Dialogs.hideProgressDialog(context);
        setState(() {});
      }
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  void setListInItem(list) {
    spinnerItems.clear();
    spinnerItems.add("All");
    litems.clear();
    for (int i = 0; i < list.length; i++) {
      litems.add(new RetriveModel(list[i]['cols'], list[i]['cols']['Section'].toString()));
      print("litems-->>>$litems");
      spinnerItems.add(list[i]['cols']['Section'].toString());
      if (list[i]["cols"]["Lockst"] == "Lock") {
        lockStatus = true;
        print("lockStatus--$lockStatus");
        setState(() {});
      }
    }
    itemList = spinnerItems.toSet().toList();
    print("itemList--$itemList");

    _dropDownMenuItems = getDropDownMenuItems();
    _currentStatus = _dropDownMenuItems[0].value;
    setState(() {
      try {
        //   getCount();
        // _refreshIndicatorKey.currentState.deactivate();

      } catch (e) {}
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<String> dataval = [];
    List<String> dataValue = [];
    Utility.log(TAG, selected_Type);
    for (int i = 0; i < litems.length; i++) {
      if (selected_Type == litems[i].type) {
        dataval.add(litems[i].data['TCounter'].toString());
        dataValue = dataval.toSet().toList();
      } else if (selected_Type == "All") {
        dataval.add(litems[i].data['TCounter'].toString());
        dataValue = dataval.toSet().toList();
      }
    }
    List<DropdownMenuItem<String>> items = [];
    for (String status in dataValue) {
      if (!items.contains(status)) {
        items.add(new DropdownMenuItem(value: status, child: new Text(status)));
      }
    }
    return items;
  }

  getRowData(int index, String type) {
    if (type == "All") {
      return getRowDataContainer(index);
    } else if (type == litems[index].type) {
      return getRowDataContainer(index);
    } else {
      return new Container();
    }
  }

  Future<void> createDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * .450,
                child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Text(
                    'Select Section',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 19,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * .410,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: itemList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            selected_Type = itemList[index];
                            _dropDownMenuItems = getDropDownMenuItems();
                            _currentStatus = _dropDownMenuItems[0].value;
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          child: new Column(
                            children: [
                              new Container(
                                padding: EdgeInsets.all(2.0),
                                child: Text(
                                  itemList[index].toString(),
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ),
                              Divider(
                                thickness: 1.0,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
  }

  Future<void> _refresh() {
    _refreshIndicatorKey.currentState?.show()?.then((_) {
      if (litems.length > 0) {
        setState(() {
          _refreshing = false;
        });
      }
    });
    updateData();
  }

  String selected_Type = "All";
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
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2),
      margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(),
          gradient: litems[index].data['Lockst'] == "Lock"
              ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.3, 0.7, 0.9],
                  colors: [
                    Colors.red[500],
                    Colors.red[300],
                    Colors.red[100],
                    Colors.red[50],
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.3, 0.7, 0.9],
                  colors: [
                    Colors.grey[500],
                    Colors.grey[400],
                    Colors.grey[300],
                    Colors.grey[200],
                  ],
                )),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalWidget.getRowInsideDevide(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: new Text("Dt: " + litems[index].data['Indentdt'].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 11.0)),
              ),
              Expanded(
                flex: 8,
                child: new Text(
                  "V. Till: " + litems[index].data['ValidTill'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 11.0),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 3,
                child: new Text(
                  "Ty:" + litems[index].data['Ty'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 11.0),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                flex: 4,
                child: new Text("Frm : " + litems[index].data['FCounter'].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 12.0)),
              ),
              Expanded(
                flex: 6,
                child: new Text(
                  "To : " + litems[index].data['TCounter'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                flex: 4,
                child: new Text(litems[index].data['Section'].toString(),
                    style: TextStyle(color: colorPrimary, fontSize: 12.0, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 3,
                child: new Text("Ttl Item : " + litems[index].data['TTlItems'].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 3,
                child: new Text(
                  "Ttl Qty : " + litems[index].data['TTlQty'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          GlobalWidget.getRowInsideDevide(),

          // Divider(
          //   thickness: 2.0,
          // )
        ],
      ),
    );
  }

  String dropdownValue = 'One';
  List spinnerItems = [];
  List<String> categories = [];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentStatus = "";

  getBottomSheet() {
    return new Container(
      height: 40.0,
      alignment: Alignment.center,
      color: Colors.grey,
      child: new Row(
        children: [
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            flex: 3,
            child: new InkWell(
              onTap: () {
                if (litems.length > 0) {
                  createDialog();
                }
              },
              child: new Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Sec : "),
                  ),
                  Expanded(
                    flex: 7,
                    child: new Row(
                      children: [
                        Text(
                          selected_Type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          //SizedBox(width: 20.0,),
          Expanded(
            flex: 2,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("COCO"),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 85.0,
                  child: DropdownButton(
                    //    value: _currentStatus,
                    isExpanded: true,
                    // itemHeight: 250,
                    hint: Text(
                      _dropDownMenuItems == null ? "All" : _currentStatus,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: _dropDownMenuItems,
                    onChanged: changedDropDownItem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  changedDropDownItem(String value) {
    setState(() {
      _currentStatus = value;
      Utility.log(TAG, value);
      setState(() {});
    });
  }
}

class RetriveModel {
  var data;
  RetriveModel(this.data, this.type);
  String type;
}
