import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/Attendence/AttendanceClass.dart';
import 'package:ondoprationapp/BulkIndent/BulkIndentSecActivity.dart';
import 'package:ondoprationapp/CounterPackage/CounterActivity.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/DatabaseHelper/data_sync.dart';
import 'package:ondoprationapp/GRC_Inward/Grc_InwardClass.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalFile.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/ItemDespose/ItemDesposeClass.dart';
import 'package:ondoprationapp/ItemInfo/ItemInfoClass.dart';
import 'package:ondoprationapp/ListBasedStockAudit/ListBasedStockAuditClass.dart';
import 'package:ondoprationapp/ListBasedStockAudit/StockAuditClass.dart';
import 'package:ondoprationapp/MarketSurvey/MarketSurveyActivity.dart';
import 'package:ondoprationapp/OrderRetrival/OrderRetrival.dart';
import 'package:ondoprationapp/POReciving/PORecivingClass.dart';
import 'package:ondoprationapp/Report/ReportClass.dart';
import 'package:ondoprationapp/ReturnBill/ReturnBillClass.dart';
import 'package:ondoprationapp/ReviewAudit/FillStoreReviewAuditClass.dart';
import 'package:ondoprationapp/ReviewAudit/ReviewAuditActivity.dart';
import 'package:ondoprationapp/SacnBill/ScanBillClass.dart';
import 'package:ondoprationapp/SearchModel/PublishResult.dart';
import 'package:ondoprationapp/SearchModel/SearchModel.dart';
import 'package:ondoprationapp/SearchModel/SearchStore.dart';
import 'package:ondoprationapp/SendBillToHo/SendBillToHoActivity.dart';
import 'package:ondoprationapp/SentBillHistory/SentBillHistoryActivity.dart';
import 'package:ondoprationapp/Splash.dart';
import 'package:ondoprationapp/StoreAudit/StoreAuditClass.dart';
import 'package:ondoprationapp/StoreAuditHistory/StoreAuditHistoryActivity.dart';
import 'package:ondoprationapp/VegInwardPackage/VegInwardClass.dart';
import 'package:ondoprationapp/indent_retrieval/IndentRetrivalClass.dart';
import 'package:ondoprationapp/transfer_validation/ond_op_app.dart';
import 'package:ondoprationapp/transfer_validation/transfer_validation_screen.dart';

import '../transfer_validation/ond_op_app.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DashView();
  }
}

class DashView extends State<Dashboard> {
  TextEditingController controller = new TextEditingController();
  String empName = "";
  String COCO_NAME = "";
  String COCO_ID;
  final subject = new PublishSubject<String>();
  String TAG = "Dashboard";
  String appVersion = '';
  String versionCode = '';
  String sync_product = "";
  var list_data;
  String lastsyncdate = "";
  List<SearchModel> duplicateItems = [];

  @override
  void initState() {
    subject.stream.listen(_textChanged);
    getData();
    initPlatformState();
    // updateData();
    super.initState();
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    subject.close();
    super.dispose();
  }

  Future<void> updateData() async {
    // List l1 = await DatabaseHelper.db.getAllPendingProducts();
    // print("dblength ${l1.length}");
    List a1 = [];
    String cocoId = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String LAST_TS = (await Utility.getStringPreference(GlobalConstant.LAST_TS));
    log("LAST_TS-->$LAST_TS");
    LAST_TS = "0";
    if (LAST_TS == "0") {
      await DatabaseHelper.db.clearDatabase();
    }

    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': cocoId,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    a1.add(mapobj());
    Map<String, dynamic> map_l() => {
          'pname': 'LastTs',
          'value': LAST_TS,
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
          'timeout': 600,
          "param": map1()
        };

    print("datatval2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();
    GlobalFile globalFile = new GlobalFile();
    if (await NetworkCheck.check()) {
      apiController.postsNew(GlobalConstant.SignUp, json.encode(map2())).then((value) async {
        print("value-->$value");
        try {
          var data1 = json.decode(value.body);
          if (data1['status'] == 0) {
            var products = data1['ds']['tables'][0]['rowsList'];
            print("products.length--->${products.length}");

            for (int i = 0; i < products.length; i++) {
              try {
                await globalFile.addBook1(products[i]['cols']);
              } catch (e) {
                print("myerrro $e");
              }
            }
            DateTime now = new DateTime.now();
            print("dateval ${now.millisecondsSinceEpoch}");
            Utility.setStringPreference(GlobalConstant.LAST_TS, "${now.millisecondsSinceEpoch}");
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

  void initPlatformState() async {
    String projectVersion;
    try {
      projectVersion = await GetVersion.projectVersion;
      Utility.log(TAG, "projectVersion: " + projectVersion);
    } on PlatformException {
      projectVersion = 'Failed to get project version.';
    }

    if (!mounted) return;
    setState(() {
      appVersion = projectVersion;
    });
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

  List<SearchModel> items = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    empName,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    COCO_NAME,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    "App Ver : ($appVersion)",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    "LastTS : $lastsyncdate",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.green,
              ),
            ),
            new Container(
              padding: EdgeInsets.all(10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      await changeCoco();
                    },
                    child: Text("Change COCO"),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () async {
                      String LAST_TS = (await Utility.getStringPreference(GlobalConstant.LAST_TS));
                      print("Last ts $LAST_TS");
                      if (LAST_TS == "0") {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) => DataSync()),
                        );
                      }
                    },
                    child: Text("Reset Item Sync"),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
      body: new ListView(
        padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: [
          items.length > 0
              ? new ListView.builder(
                  itemCount: items.length,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        String fid = items[index].id.toString();
                        getLinks(fid);
                      },
                      child: GlobalWidget.CreateDashContain(context, items[index].title.toString()),
                    );
                  })
              : new Container(),
        ],
      ),
    );
  }

  //final FocusNode _SearchPFocus = FocusNode();

  void openActivity(orderRetrivalActivity) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => orderRetrivalActivity));

    // _SearchPFocus.unfocus();
  }

  void _addBook(dynamic book) {
    setState(() {
      String FID = book['FID'].toString();
      print("FID---->$FID");
      // Utility.log("tag", FID);
      String name = "";
      switch (FID) {
        case "1":
          name = "Order Retrieval";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "2":
          name = "Indent Retrieval";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "3":
          name = "Bulk Indent Retrieval";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "4":
          name = "Mark Attendance";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "5":
          name = "Market Survey";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "6":
          name = "Stock Audit";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "7":
          name = "Report";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "8":
          name = "Exception Mobile";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "9":
          name = "New Order Retrieval";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "10":
          name = "Store Audit";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "11":
          name = "Short Item Purchase";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "12":
          name = "Item Info";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "13":
          name = "List Based Stock Audit";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "14":
          name = "Bill Scan";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "15":
          name = "Inward GRC";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "16":
          name = "PO RECEIVING";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "17":
          name = "Inward Vege";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "18":
          name = "Dispose Item";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "19":
          name = "Store Audit";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "20":
          name = "Store Audit History";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "21":
          name = "Review Audit";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "22":
          name = "Send Bill To HO";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        case "23":
          name = "Sent Bill History";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
        // case "24":
        //   name = "Transfer Validation ";
        //   duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
        //   break;
        case "25":
          name = "Transfer Validation ";
          duplicateItems.add(new SearchModel(name, "${book["FID"]}", book));
          break;
      }
    });
  }

  String get_Dateval(int string) {
    int timeInMillis = string;
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    var formattedDate = DateFormat.yMMMMd().addPattern(DateFormat.HOUR_MINUTE_SECOND).format(date); // Apr 8, 2020
    // var formattedDate1 = DateFormat.yMMMMEEEEd().format(date); // Apr 8, 2020
    //var formattedDate1 = DateFormat.HOUR24().format(date); // Apr 8, 2020
    //  Utility.log(TAG, formattedDate);
    return formattedDate;
  }

  Future<void> getData() async {
    String LAST_TS = (await Utility.getStringPreference(GlobalConstant.LAST_TS));
    // Utility.log(TAG, "LAstts $LAST_TS");
    try {
      lastsyncdate = get_Dateval(int.parse(LAST_TS));
    } catch (e) {}

    empName = (await Utility.getStringPreference(GlobalConstant.Empname));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    COCO_NAME = (await Utility.getStringPreference(GlobalConstant.COCO_NAME));
    COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String Menu_Data = (await Utility.getStringPreference(GlobalConstant.Menu_Data));

    list_data = json.decode(Menu_Data);
    Utility.log(TAG, list_data.toString());
    for (int i = 0; i < list_data.length; i++) {
      print("list_data--${list_data[i]}");
      _addBook(list_data[i]);
    }

    duplicateItems.add(new SearchModel("Exit", "exit", ""));

    items.addAll(duplicateItems);

    duplicateItems.add(new SearchModel("Counter Activity", "counter", null));
    setState(() {});
  }

  Future<void> changeCoco() async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    Navigator.of(context)
        .push(
      new MaterialPageRoute(builder: (_) => new SearchStore()),
    )
        .then((val) {
      FocusScope.of(context).requestFocus(new FocusNode());
      if (val != null) {
        setState(() {
          var data = val;
          String name = "${data['Pname']}";
          String Id = "${data['PID']}";
          Utility.log("Coco IDs ", COCO_ID + "  " + Id);

          Utility.setStringPreference(GlobalConstant.COCO_CITY_ID, data['CityId'].toString());
          Utility.setStringPreference(GlobalConstant.COCO_CITY, data['CityLbl'].toString());
          Utility.setStringPreference(GlobalConstant.COCO_CITY_CODE, data['CityName'].toString());
          Utility.setStringPreference(GlobalConstant.COCO_ADDRESS, data['Address'].toString());
          Utility.setStringPreference(GlobalConstant.COCO_ID, Id.toString());

          PartyInfo(cityId: data['CityId'], cityLbl: data['CityLbl'], cityName: data['CityName'], pid: Id, pname: name);

          Utility.setStringPreference(GlobalConstant.COCO_NAME, name.toString());

          if (COCO_ID != Id) {
            Utility.setStringPreference(GlobalConstant.LAST_TS, "0");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => DataSync()),
            );
          } /* else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
              ModalRoute.withName('/'),
            );
          }*/

          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
          //   ModalRoute.withName('/'),
          // );
        });
      }
    });

    String cocoID = await Utility.getStringPreference(GlobalConstant.COCO_ID);
    print("cocoID0--$cocoID");
  }

  Future<void> getLinks(String fid) async {
    Utility.log("tag", fid);

    switch (fid) {
      case "1":
        if (COCO_ID == 0) {
          GlobalWidget.showToast(context, "Please Seelct a Store/WH to Use this Option");
          return;
        }
        openActivity(OrderRetrivalActivity());
        break;
      case "2":
        openActivity(IndentRetrivalActivity());
        break;
      case "3":
        // OpenActivity(IndentRetrivalActivity());
        openActivity(BulkIndentSecActivity());
        break;
      case "4":
        bool data = await GlobalPermission.checkPermissions(context);
        if (data == true) {
          openActivity(AttendanceActivity());
        }

        break;
      case "5":
        //market survey
        openActivity(MarketSurveyClass());
        break;
      case "6":
        //stock audit
        openActivity(StockAuditActivity());
        break;
      case "7":
        //Reports
        openActivity(MyReportSubClass());
        break;
      case "8":
        //SriException
        openActivity(ReturnBillData());
        break;
      case "9":
        //Order Retrivakl new
        //OpenActivity(MyReportSubClass());
        break;
      case "10":
        //StoreAudit
        openActivity(StoreAuditActivity());
        break;
      case "11":
        //Market Purchases For Online Order
        // OpenActivity(StoreAuditActivity);
        break;
      case "12":
        //App Item Info
        openActivity(ItemInfoActivity());
        break;
      case "13":
        //App Item Info
        openActivity(ListBasedStockAuditActivity());
        break;
      case "14":
        //PO SCAN INVOICE
        openActivity(ScanBillActivity());
        break;
      case "15":
        //GRC INWARD
        openActivity(GrcInwardActivity());
        break;
      case "16":
        //PO RECEIVING
        openActivity(POReciving());
        break;
      case "17":
        //veg Inward
        openActivity(VegInwardActivity());
        break;
      case "18":
        //Item Despose
        openActivity(ItemDesposeActivity());
        break;
      case "19":
        //Item Despose
        openActivity(StoreReviewAudit(null));
        break;
      case "counter":
        //Item Despose
        openActivity(CounterActivity());
        break;
      case "20":
        //Item Despose

        Navigator.of(context)
            .push(
          new MaterialPageRoute(builder: (_) => new SearchStore()),
        )
            .then((data) {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (data != null) {
            setState(() {
              String Id = "${data['PID']}";
              String Name = "${data['Pname']}";
              openActivity(StoreAuditHistoryActivity(Id));
            });
          }
        });
        break;
      case "21":
        //Item Despose
        openActivity(ReviewAuditActivity());
        break;
      case "22":
        //Item Despose
        openActivity(SendBillToHoActivity());
        break;
      case "23":
        //Item Despose
        openActivity(SentBillHistoryActivity());
        break;
      // case "24":
      //   //Item Despose
      //   openActivity(TransferValidationScreen());
      //   break;
      case "25":
        //Item Despose
        openActivity(TransferValidationScreen());
        break;

      case "exit":
        Utility.setStringPreference(GlobalConstant.IS_LOGIN, "");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => SplashScreen()),
          ModalRoute.withName('/'),
        );
        break;

      default:
        break;
    }
  }
}

class MenuItem {
  String Name;

  MenuItem(this.Name, this.Data);

  var Data;
}
