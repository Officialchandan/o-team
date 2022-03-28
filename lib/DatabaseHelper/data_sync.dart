import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/DashBoard/DashBoard.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalFile.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

import 'DatabaseHelper.dart';

class DataSync extends StatefulWidget {
  DataSync({Key key}) : super(key: key);

  @override
  _DataSyncState createState() => _DataSyncState();
}

class _DataSyncState extends State<DataSync> {
  bool next = false;

  @override
  void initState() {
    print("adfasdf");
    updateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _onBackPressed(),
      child: new Scaffold(
        body: new Container(
          color: Colors.white,
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image(
                    image: AssetImage('drawable/logo_small.png'),
                    width: 120,
                    height: 120,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      //margin: EdgeInsets.only(top: 150),
                      child: Text(
                        "Please wait until data is sync ",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    next == true
                        ? GestureDetector(
                            onTap: () {
                              print("ONTap-next");
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Dashboard()),
                              );
                            },
                            child: new Container(
                              alignment: Alignment.center,
                              // color: colorPrimary,
                              child: Text(
                                "...",
                                style: TextStyle(color: Colors.black, fontSize: 16.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                    alignment: Alignment.center,
                    // margin: EdgeInsets.only(top: 450),
                    child: Image.asset("drawable/loader.gif")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var listdata;
  var products;

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text("Don't Press Back"),
            content: new Text("If you press back so data will not sync properly"),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("OK"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> updateData() async {
    print("updateData---->");

    // List l1 = await DatabaseHelper.db.getAllPendingProducts();
    // print("dblength ${l1.length}");
    List a1 = [];
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    String LAST_TS = (await Utility.getStringPreference(GlobalConstant.LAST_TS));

    if (LAST_TS.toString() == "0") {
      await DatabaseHelper.db.clearDatabase();
    }

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
          'timeout': GlobalConstant.TimeOut,
          "param": map1()
        };

    //print("datatval2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();
    GlobalFile globalFile = new GlobalFile();

    if (await NetworkCheck.check()) {
      print("My App status");

      //Dialogs.showProgressDialog(context);

      try {
        // var value = await  apiController.PostsNew(GlobalConstant.SignUp, json.encode(map2()));

        Map<String, dynamic> data1 = await apiController.post(url: GlobalConstant.SignUp, input: map2());
        print("status-->${data1['status']}");

        next = true;

        setState(() {});
        print("data1['status']-> ${data1['status']}");
        if (data1['status'] == 0) {
          print("MyData");
          products = data1['ds']['tables'][0]['rowsList'];
          // List l1 = await DatabaseHelper.db.getAllPendingProducts();

          print("totalitemserver ${products.length}");
          // print("totalitemserver ${l1.length}");
          // int start = l1.length;

          for (int i = 0; i < products.length; i++) {
            try {
              await globalFile.addBook1(products[i]['cols']);
            } catch (e) {
              print("myerrro $e");
            }
          }

          // DatabaseHelper.db.getAllPendingProducts();
          DateTime now = new DateTime.now();
          print("dateval ${now.millisecondsSinceEpoch}");
          Utility.setStringPreference(GlobalConstant.LAST_TS, "${now.millisecondsSinceEpoch}");
          print("Navigator");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
            ModalRoute.withName('/'),
          );
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            print("e---1");

            GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            print("e====2");

            GlobalWidget.showMyDialog(context, "", "Please try again");
          }
        }
      } catch (e) {
        print("e--->$e");
        GlobalWidget.showMyDialog(context, "Error", "" + e.toString());
      }
    } else {
      print("e====");
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }
}
