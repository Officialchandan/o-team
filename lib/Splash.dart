import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ondoprationapp/DashBoard/DashBoard.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/transfer_validation/db_model/db_model.dart';
import 'package:ondoprationapp/ui/login/login_screen.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'GlobalData/GlobalConstant.dart';
import 'GlobalData/Utility.dart';
import 'transfer_validation/data_table.dart';
import 'transfer_validation/my_data_row.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashView();
  }
}

class SplashView extends State<SplashScreen> {
  // PackageInfo packageInfo = PackageInfo();

  @override
  Widget build(Object context) {
    // TODO: implement build
    return new Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:
            BoxDecoration(image: DecorationImage(image: AssetImage("drawable/splash_background_720.png"), fit: BoxFit.fill)),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Center(
              child: Image(
                image: AssetImage('drawable/logo_small.png'),
                width: 120,
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    if (await NetworkCheck.check()) {
      try {
        PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
          String version = packageInfo.version;
          continueSplashExecution(version: version);
          print("version->$version");
        });
      } catch (e) {
        print("e--->$e");
      }
    } else {
      GlobalWidget.GetToast(context, "No internet connection...Refresh and try again!!");
    }
  }

  void continueSplashExecution({String version}) async {
    try {
      DBRequestModel dbr = new DBRequestModel();
      dbr.setDbUser("webuser");
      dbr.setDbPassword("nsb@363");
      dbr.setProcName("GetAppVer");
      dbr.setTimeout(30);
      MyDataTable dt = MyDataTable("param");
      MyDataRow r1 = MyDataRow();
      r1.add("pname", "Version ");
      r1.add("value", version);
      // r1.add("value", "1.0");
      print("version-->>>>>>$version");

      dt.addRow(r1);
      dbr.setParam(dt);
      Map<String, dynamic> json = dbr.toJson();
      print("input: ${json.toString()}");

      ApiController apiController = ApiController.internal();

      Map<String, dynamic> response = await apiController.post(url: GlobalConstant.SignUp, input: json);

      print("response-->$response");

      try {
        if (response['status'] == 0) {
          String status = response['ds']['tables'][0]['rowsList'][0]['cols']['status'].toString();

          print("status-->$status");

          if (status.contains('0')) {
            Future.delayed(const Duration(seconds: 1), () {
              getLoginStatus();
            });
          } else {
            showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Update Alert!!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    content: Text("${response['ds']['tables'][0]['rowsList'][0]['cols']['msg'].toString()}"),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            child: Text('NO'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          MaterialButton(
                            child: Text('YES'),
                            onPressed: () async {
                              PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                                String packageName = packageInfo.packageName;
                                print("packageName-->$packageName");
                                try {
                                  launch("market://details?id=" + packageName);
                                } on PlatformException catch (e) {
                                  launch("https://play.google.com/store/apps/details?id=" + packageName);
                                } finally {
                                  launch("https://play.google.com/store/apps/details?id=" + packageName);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                });
          }
        }
      } catch (exception) {
        GlobalWidget.showMyDialog(context, "Error:", exception.getMessage());
      }
    } catch (exception) {
      GlobalWidget.showMyDialog(context, "Error", exception.toString());
    }
  }

  Future<void> getLoginStatus() async {
    String login = (await Utility.getStringPreference(GlobalConstant.IS_LOGIN));
    if (login == "1") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }
}
