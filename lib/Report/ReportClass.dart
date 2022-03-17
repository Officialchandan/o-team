import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

import 'HoulyReportClass.dart';
import 'ReportIndCocoTransferClass.dart';
import 'Report_SaleOverall_Class.dart';
import 'VehicleNotOutDetail.dart';

class MyReportSubClass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReportsData();
  }
}

class ReportsData extends State<MyReportSubClass> {
  List<String> dateFilter = [
    "Today",
    "Tomorrow",
    "Yesterday",
    "Last TwoDays",
    "Last ThreeDays",
    "Last SevenDays",
    "LastTenDays",
    "CurrentWeek",
    "Last Week",
    "Last 15Days",
    "Current Month",
    "Last Month",
    "Custom"
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentDate;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: GlobalWidget.getAppbar("Report"),
        body: /*new Column(
        children: [
          Expanded(
            flex: 3,
            child: getAboveRow(),
          ),
          Expanded(
            flex: 7,
            child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new ExpandableListView(Retrived_Item_List[index].Title, Retrived_Item_List[index].Sublist);
              },
              itemCount: Retrived_Item_List.length,
            ),
          )
        ],
      ),*/
            new ListView(
          shrinkWrap: true,
          children: [
            getAboveRow(),
            SizedBox(
              height: 20.0,
            ),
            new ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return new ExpandableListView(Retrived_Item_List[index].Title,
                    Retrived_Item_List[index].Sublist);
              },
              itemCount: Retrived_Item_List.length,
            ),
          ],
        ));
  }

  String _frdate = "";
  String _trdate = "";

  List litems = new List();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  @override
  void initState() {
    String s = dateFormat.format(selectedDateTime);
    _frdate = s;
    _trdate = s;

    _dropDownMenuItems = getDropDownMenuItems();
    _currentDate = _dropDownMenuItems[0].value;

    Utility.setStringPreference(GlobalConstant.FROM_DATE_Report, _frdate);
    Utility.setStringPreference(GlobalConstant.TO_DATE_Report, _trdate);

    fromDateController.text = _frdate;
    toDateController.text = _trdate;
    UpdateData();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String date in dateFilter) {
      items.add(new DropdownMenuItem(value: date, child: new Text(date)));
    }
    return items;
  }

  String TAG = "ReoportActivity";

  Future<void> UpdateData() async {
    litems = new List();
    String COCO_ID =
        (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    //  var data = GlobalConstant.GetMapForRetrival(COCO_ID);

    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_rpt_GetProcs,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
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
              var list = data1['ds']['tables'][0]['rowsList'];
              SetListInItem(list);
            }
          } else {
            if (data1['msg'].toString() == "Login failed for user") {
              GlobalWidget.showMyDialog(context, "Error",
                  "Invalid id or password. Please enter correct id psw or contact HR/IT");
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

  void SetListInItem(list) {
    for (int i = 0; i < list.length; i++) {
      litems.add(list[i]['cols']['Category']);
    }

    try {
      Set<String> set = new Set<String>.from(litems);
      print("this is #0 ${list[0]}");
      set.forEach((f) {
        print("set: $f");

        TitleList.add(f.toString());
      });
    } catch (e) {
      Utility.log(TAG, "message $e");
    }

    for (int i = 0; i < TitleList.length; i++) {
      String Title = TitleList[i].toString();

      List<RetriveSubModel> SubList = new List();

      for (int i = 0; i < list.length; i++) {
        if (list[i]['cols']['Category'] == Title) {
          try {
            SubList.add(new RetriveSubModel(list[i]['cols']));
          } catch (e) {
            Utility.log(TAG, "MyTitle " + e.toString());
          }
        }
      }

      Retrived_Item_List.add(new RetriveModel(SubList, Title));
    }

    for (int i = 0; i < Retrived_Item_List.length; i++) {
      try {
        for (int j = 0; j < Retrived_Item_List[i].Sublist.length; j++) {
          var data = Retrived_Item_List[i].Sublist[j].data['ProcName'];
          Utility.log(TAG, Retrived_Item_List[i].Title + "Process : " + data);
        }
      } catch (e) {
        Utility.log(TAG, "mydataval error : " + e.toString());
      }
    }

    setState(() {});
  }

  List<RetriveModel> Retrived_Item_List = new List();
  List TitleList = new List();
  final dateFormat = DateFormat("yyyy-MM-dd");

  DateTime selectedDateTime = DateTime.now();

  getAboveRow() {
    return new Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Date Range",
                style: TextStyle(fontSize: 16.0, color: colorPrimary),
                textAlign: TextAlign.left,
              ),
              new DropdownButton(
                value: _currentDate,
                items: _dropDownMenuItems,
                onChanged: changedDropDownItem,
              )
            ],
          ),
          new Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  padding: EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.grey[500],
                    ),
                  ),
                  child: DateTimeField(
                    controller: fromDateController,
                    onShowPicker: (context, currentValue) async {
                      return showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: selectedDateTime
                            .subtract(new Duration(days: 365 * 20)),
                        lastDate: selectedDateTime,
                        builder: (BuildContext context, Widget child) {
                          return Theme(
                            data: ThemeData.light(),
                            child: child,
                          );
                        },
                      );
                    },
                    decoration: InputDecoration(labelText: 'From Date'),
                    format: dateFormat,
                    onChanged: (val) {
                      _frdate = dateFormat.format(val);
                      Utility.setStringPreference(
                          GlobalConstant.FROM_DATE_Report, _frdate);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  padding: EdgeInsets.only(left: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.grey[500],
                    ),
                  ),
                  child: DateTimeField(
                    controller: toDateController,
                    onShowPicker: (context, currentValue) async {
                      return showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: selectedDateTime
                            .subtract(new Duration(days: 365 * 20)),
                        lastDate: selectedDateTime,
                        builder: (BuildContext context, Widget child) {
                          return Theme(
                            data: ThemeData.light(),
                            child: child,
                          );
                        },
                      );
                    },
                    decoration: InputDecoration(labelText: 'To Date'),
                    format: dateFormat,
                    onChanged: (val) {
                      _trdate = dateFormat.format(val);
                      Utility.setStringPreference(
                          GlobalConstant.FROM_DATE_Report, _trdate);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void changedDropDownItem(String selectedDate) {
    final now = DateTime.now();

    if (selectedDate == "Tomorrow") {
      final fromDate = DateTime(now.year, now.month, now.day + 1);
      final toDate = DateTime(now.year, now.month, now.day + 2);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Today") {
      final fromDate = DateTime(now.year, now.month, now.day);
      final toDate = DateTime(now.year, now.month, now.day + 1);
      _frdate = dateFormat.format(fromDate);
      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Yesterday") {
      final fromDate = DateTime(now.year, now.month, now.day - 1);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Last TwoDays") {
      final fromDate = DateTime(now.year, now.month, now.day - 2);
      final toDate = DateTime(now.year, now.month, now.day);
      _frdate = dateFormat.format(fromDate);
      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Last ThreeDays") {
      final fromDate = DateTime(now.year, now.month, now.day - 3);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "LastTenDays") {
      final fromDate = DateTime(now.year, now.month, now.day - 10);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Last SevenDays") {
      final fromDate = DateTime(now.year, now.month, now.day - 3);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "CurrentWeek") {
      final fromDate = DateTime(now.year, now.month, now.day - 6);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Last Week") {
      final fromDate = DateTime(now.year, now.month, now.day - 15);
      final toDate = DateTime(now.year, now.month, now.day - 7);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Last 15Days") {
      final fromDate = DateTime(now.year, now.month, now.day - 15);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Current Month") {
      final fromDate = DateTime(now.year, now.month, now.day - 30);
      final toDate = DateTime(now.year, now.month, now.day);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Last Month") {
      final fromDate = DateTime(now.year, now.month, now.day - 60);
      final toDate = DateTime(now.year, now.month, now.day - 30);

      _frdate = dateFormat.format(fromDate);

      _trdate = dateFormat.format(toDate);
    } else if (selectedDate == "Custom") {
      final fromDate = DateTime(now.year, now.month, now.day);
      final toDate = DateTime(now.year, now.month, now.day);
      _frdate = dateFormat.format(fromDate);
      _trdate = dateFormat.format(toDate);
    }

    Utility.setStringPreference(GlobalConstant.FROM_DATE_Report, _frdate);
    Utility.setStringPreference(GlobalConstant.TO_DATE_Report, _trdate);

    fromDateController.text = _frdate.toString();
    toDateController.text = _trdate.toString();

    setState(() {
      _currentDate = selectedDate;
    });
  }
}

class RetriveModel {
  List<RetriveSubModel> Sublist;
  String Title;

  RetriveModel(List<RetriveSubModel> Sublist, String Title) {
    this.Sublist = Sublist;
    this.Title = Title;
  }
}

class RetriveSubModel {
  var data;

  RetriveSubModel(this.data);
}

class ExpandableListView extends StatefulWidget {
  String title;
  List<RetriveSubModel> datalist = new List();

  ExpandableListView(this.title, this.datalist);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 1.0),
      child: new Column(
        children: <Widget>[
          new Container(
            color: Colors.grey[200],
            padding: new EdgeInsets.symmetric(horizontal: 5.0),
            child: new Row(
              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new IconButton(
                    icon: new Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: new BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: new Center(
                        child: new Icon(
                          expandFlag
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        expandFlag = !expandFlag;
                      });
                    }),
                new Text(
                  widget.title,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16.0),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
          new ExpandableContainer(
              expanded: expandFlag,
              expandedHeight: widget.datalist.length * 55.0,
              child: new ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      String city_id =
                          "${widget.datalist[index].data['CItyParam']}";
                      //   String Title_Value = "${widget.datalist[index].data['Descr']}";
                      String Title_Value =
                          "${widget.datalist[index].data['ProcName']}";
                      String Pro = "${widget.datalist[index].data['Pro']}";
                      String Param = "${widget.datalist[index].data['Param']}";
                      Pro = Pro.replaceAll("[", "");
                      Pro = Pro.replaceAll("]", "");
                      Utility.log("Tag", Pro.toString());
                      Utility.log("Tag", city_id.toString());
                      Utility.log("Tag", Title_Value.toString());

                      switch (Pro.toString()) {
                        case "rpt_ord_SlotSumm":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InterCocoDetailActivity(
                                      city_id, Pro, Title_Value, Param)));
                          break;
                        case "rpt_SaleOverall":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HorlyReprtDetailActivity(
                                          city_id, Pro, Title_Value, Param)));
                          break;
                        case "rpt_CocoIndTrfSumm":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InterCocoDetailActivity(
                                      city_id, Pro, Title_Value, Param)));
                          break;
                        case "rpt_ord_HrlyData":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HorlyReprtDetailActivity(
                                          city_id, Pro, Title_Value, Param)));
                          break;
                        case "Rpt_OfferItem":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InterCocoDetailActivity(
                                      city_id, Pro, Title_Value, Param)));
                          break;
                        case "rpt_SaleOverall_Mapp":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReportOverAllSaleDetailActivity(
                                          city_id, Pro, Title_Value, Param)));
                          break;
                        case "Rpt_VechicleOutStatus":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VehicleNotOutActivity(
                                      city_id, Pro, Title_Value, Param)));
                          break;
                        case "rpt_ord_TAT":
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InterCocoDetailActivity(
                                      city_id, Pro, Title_Value, Param)));
                          break;
                        case "rpt_DlvAppInfo":
                          GlobalWidget.GetToast(context, "Sorry not working");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HorlyReprtDetailActivity(
                                          city_id, Pro, Title_Value, Param)));
                          break;
                        default:
                          break;
                      }
                    },
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 65.0, top: 10.0, bottom: 10.0),
                          child: new Text(
                            "${widget.datalist[index].data['ProcName']}",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                fontSize: 14.0),
                          ),
                        ),
                        Divider(
                          thickness: 1.0,
                        )
                      ],
                    ),
                  );
                },
                itemCount: widget.datalist.length,
              ))
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    @required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
        decoration: new BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.grey, width: 1),
              bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
      ),
    );
  }
}
