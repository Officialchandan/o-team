import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

class StoreAmbiance_Audit extends StatefulWidget {
  String City_Id, Store_Id;

  StoreAmbiance_Audit(this.City_Id, this.Store_Id);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AmbianceView();
  }
}

class AmbianceView extends State<StoreAmbiance_Audit> {
  String TAG = "AmbianceView";

  final remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: GlobalWidget.getAppbar("Store Ambience Audit"),
        bottomNavigationBar: getBottomButton(),
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  keyboardType: TextInputType.text,
                  maxLength: 150,
                  //textInputAction: TextInputAction.done,
                  controller: remarkController,
                  decoration: GlobalWidget.TextFeildDecoration("Enter Remark"),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: new ListView.builder(
                  itemCount: listdata.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return InkWell(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Container(
                            padding: EdgeInsets.all(10.0),
                            child: new Text(listdata[index].Title.toString()),
                          ),
                          new Container(
                            child: RatingBar(
                              initialRating: listdata[index].star,
                              minRating: 1,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              ratingWidget: RatingWidget(
                                  full: Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                  ),
                                  half: null,
                                  empty: Icon(
                                    Icons.star,
                                    color: Colors.grey,
                                  )),
                              onRatingUpdate: (rating) {
                                print(index);
                                print(rating);
                              },
                            ),
                          ),
                          Divider(
                            thickness: 2.0,
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
        ));
  }

  List<DataCount> listdata = new List();

  @override
  void initState() {
    listdata.add(new DataCount(0.0, "1. Floor Hygiene ?"));
    listdata.add(new DataCount(0.0, "2. Store Glass Front Cleanliness ?"));
    listdata.add(new DataCount(0.0, "3. Shelf and Products Cleanliness ?"));
    listdata.add(new DataCount(0.0, "4. Clear Entrance  ?"));
    listdata.add(new DataCount(0.0, "5. Staff Dress Up ?"));
    listdata.add(new DataCount(0.0, "6. Staff Behavior ?"));
    setState(() {});
  }

  Future<void> UpdateData() async {
    List a1 = new List();

    Map<String, dynamic> map() => {
          'pname': 'CityId',
          'value': widget.City_Id,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'CocoPId',
          'value': widget.Store_Id,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };
    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'pa',
          'value': listdata[0].star.toInt().toString(),
        };
    try {
      Utility.log(TAG, listdata[0].star.toString());
    } catch (e) {
      Utility.log(TAG, "call" + e);
    }
    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'pname': 'pb',
          'value': listdata[1].star.toInt().toString(),
        };
    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'pc',
          'value': "${listdata[2].star.toInt().toString()}",
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };
    a1.add(mapobj4());

    Map<String, dynamic> map5() => {
          'pname': 'pd',
          'value': "${listdata[3].star.toInt().toString()}",
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };
    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'pe',
          'value': "${listdata[4].star.toInt().toString()}",
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };
    a1.add(mapobj6());

    Map<String, dynamic> map_6() => {
          'pname': 'pf',
          'value': "${listdata[5].star.toInt().toString()}",
        };

    var dmap_6 = map_6();
    Map<String, dynamic> mapobj_6() => {
          'cols': dmap_6,
        };
    a1.add(mapobj_6());

    Map<String, dynamic> map7() => {
          'pname': 'Rmk',
          'value': remarkController.text.toString(),
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };
    a1.add(mapobj7());

    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map_submit() => {
          'dbPassword': userPass,
          'dbUser': USER_ID.toString(),
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Map_AmbiAudit,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': map_final(),
        };
    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map_submit()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, data1);
        if (data1['status'] == 0) {
          GlobalWidget.showToast(context, "Saved successfully");

          Navigator.of(context).pop();
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

  getBottomButton() {
    return InkWell(
      onTap: () {
        int val = 0;
        for (int i = 0; i < listdata.length; i++) {
          if (listdata[i].star <= 0) {
            val = 1;
            int index = i + 1;
            GlobalWidget.showMyDialog(context, GlobalWidget.GetAppName, "Please mark star for point $index  ");
            break;
          }
        }
        if (val == 0) {
          if (remarkController.text.toString().length > 0) {
            UpdateData();
          } else {
            GlobalWidget.showMyDialog(context, GlobalWidget.GetAppName, "Please Enter Remark");
          }
        }
      },
      child: new Container(
        alignment: Alignment.center,
        height: 50,
        color: colorPrimary,
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white, fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class DataCount {
  double star;
  String Title;

  DataCount(this.star, this.Title);
}
