import 'dart:convert';
import 'dart:io' show Platform;

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/SearchStoreAutoComplete/GlobalSearchStore.dart';
import 'package:ondoprationapp/GlobalData/SearchStoreAutoComplete/SearchStoreModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:place_picker/place_picker.dart';

class AttendanceActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AttendanceView();
  }
}

class AttendanceView extends State<AttendanceActivity> {
  int attd_type = 1;
  String Name = "";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return new Scaffold(
      appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
      body: new ListView(
        padding: EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 40.0,
          ),
          new Container(
            alignment: Alignment.center,
            child: Text(
              "WELCOME : " + Name,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Divider(
            thickness: 1.0,
          ),
          SizedBox(
            height: 20.0,
          ),
          new Row(
            children: [
              Expanded(
                flex: 3,
                child: Text("Attd. Type", style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ),
              Expanded(
                flex: 7,
                child: new Row(
                  children: [
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            attd_type = 1;
                            Att_Type = "Sign In";
                          });
                        },
                        child: new Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              color: attd_type == 1 ? colorPrimary : Colors.grey,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Sign IN",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: attd_type == 1 ? colorPrimary : Colors.grey,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: new InkWell(
                        child: new Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              color: attd_type == 2 ? colorPrimary : Colors.grey,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Sign Out",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: attd_type == 2 ? colorPrimary : Colors.grey,
                                )),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            attd_type = 2;
                            Att_Type = "Sign Out";
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          new Row(children: [
            Expanded(
              flex: 3,
              child: Text("Location", style: TextStyle(fontSize: 14.0, color: Colors.black)),
            ),
            SizedBox(
              width: 40.0,
            ),
            Expanded(flex: 7, child: LocationClickFeild())
          ]),
          SizedBox(
            height: 20.0,
          ),
          new Row(children: [
            Expanded(
              flex: 3,
              child: Text("GPS CORD", style: TextStyle(fontSize: 14.0, color: Colors.black)),
            ),
            SizedBox(
              width: 40.0,
            ),
            Expanded(flex: 7, child: GPSClickFeild())
          ]),
          SizedBox(
            height: 20.0,
          ),
          GetSubmitButton(),
        ],
      ),
    );
  }

  // final LocationClick = TextEditingController(text: "Select");
  final GPSCORDSClick = TextEditingController();

  String LOC_ID;
  String LOC_NAME = "";
  String Att_Type = "Sign IN";
  Position position;
  String geocords;
  Future<String> _getId() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      GPSCORDSClick.text = position.latitude.toString() + "," + position.longitude.toString();
      geocords = position.latitude.toString() + "," + position.longitude.toString();
    });
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      Deviceid = iosDeviceInfo.identifierForVendor.toString() +
          "|" +
          iosDeviceInfo.model.toString() +
          "|" +
          iosDeviceInfo.systemName.toString() +
          "|" +
          iosDeviceInfo.systemVersion.toString();
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      Deviceid =
          androidDeviceInfo.androidId.toString() + "|" + androidDeviceInfo.brand.toString() + "|" + androidDeviceInfo.id.toString();
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future<void> SubmitAttendenceDetail() async {
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map() => {
          'pname': 'EmpId',
          'value': USER_ID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map3() => {
          'pname': 'StrId',
          'value': LOC_ID,
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'StoreName',
          'value': LOC_NAME,
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());

    Map<String, dynamic> map5() => {
          'pname': 'AttTy',
          'value': Att_Type,
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };

    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'GPS',
          'value': geocords.toString(),
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };

    a1.add(mapobj6());

    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(now);

    Map<String, dynamic> map7() => {
          'pname': 'DevDt',
          'value': formatted,
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };

    a1.add(mapobj7());

    Map<String, dynamic> map8() => {
          'pname': 'DeviceInfo',
          'value': Deviceid,
        };

    var dmap8 = map8();
    Map<String, dynamic> mapobj8() => {
          'cols': dmap8,
        };

    a1.add(mapobj8());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    var data = map1();
    Utility.log(TAG, map1());
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String Item_Id = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map2_final() => {
          'dbPassword': userPass,
          'dbUser': Item_Id,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_SaveAttNew,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2_final()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, "Response: " + data1.toString());
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var list = data1['ds']['tables'][0]['rowsList'][0]["cols"];
            String Status = list["Status"].toString();
            String Msg = list["Msg"].toString();
            GlobalWidget.showMyDialog(context, "Success", Msg);
            if (Status == 0) {
              Navigator.of(context).pop();
            }
          }
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

  getDeviceInfo() async {
    String devId = "";
    return "dsjklghkdfshg";
  }

  LocationClickFeild() {
    /*return InkWell(
      onTap: (){
        print("clicked");
      },
      child: TextFormField(
        readOnly: true,
        controller: LocationClick,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

        decoration: InputDecoration(

          contentPadding:GlobalWidget.getContentPadding(),
          hintText: "Select Location",
          suffixIcon: IconButton(
            onPressed: () => _toggle1(),
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),

        validator: (value) {
          if (value.isEmpty) {
            return 'Select';
          }
          return null;
        },
      ),
    );*/
    return loading
        ? new Container()
        : searchTextField = GlobalSearchStore.getAutoSelectionfeild(key, SearchItems, searchTextField, onSelectItem);
  }

  GPSClickFeild() {
    //  GPSCORDSClick.text=position.latitude.toString()+","+position.longitude.toString();
    return TextFormField(
      readOnly: true,
      controller: GPSCORDSClick,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

      decoration: InputDecoration(
        contentPadding: GlobalWidget.getContentPadding(),
        hintText: "Select",
        suffixIcon: IconButton(
          onPressed: () => _toggle2(),
          icon: Icon(Icons.location_on),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Select';
        }
        return null;
      },
    );
  }

  GetSubmitButton() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.

        if (LOC_NAME.toString().length > 0) {
          SubmitAttendenceDetail();
        } else {
          GlobalWidget.showMyDialog(context, GlobalWidget.GetAppName, "Please Select Location.");
        }
      },
      child: Text(
        'Submit',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  String Deviceid = "";
  @override
  void initState() {
    getName();
    _getId();
    GlobalSearchStore.getSearchItems(FunctionCityLoad, context);
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchStore>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;
  static List<ModelSearchStore> SearchItems = new List<ModelSearchStore>();
  bool loading = true;

  void onSelectItem(ModelSearchStore item) {
    Utility.log("tag", item.name);
    setState(() {
      searchTextField.textField.controller.text = item.name;
      LOC_NAME = item.name;
    });
  }

  void FunctionCityLoad(List<ModelSearchStore> item) {
    SearchItems = item;
    setState(() {
      loading = false;
    });
  }

  Future<void> getName() async {
    Name = (await Utility.getStringPreference(GlobalConstant.Empname));
    setState(() {});
  }

  String TAG = "AllendenceClasss";

  _toggle2() async {
    try {
      LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PlacePicker(
                "AIzaSyDBkO85LxHsC9NCNZJviJhQd2inA2MTG9A",
                displayLocation: LatLng(position.latitude, position.longitude),
              )));

      if (result != null) {
        GPSCORDSClick.text = result.latLng.latitude.toString() + "," + result.latLng.longitude.toString();
        geocords = result.latLng.latitude.toString() + "," + result.latLng.longitude.toString();
        setState(() {
          print(geocords);
        });
      }
    } catch (exception) {
      print("exception--->$exception");
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PlacePicker(
    //       apiKey: "AIzaSyDBkO85LxHsC9NCNZJviJhQd2inA2MTG9A", // Put YOUR OWN KEY here.
    //       onPlacePicked: (result) {
    //         print(result.geometry.location.lat);
    //         print(result.geometry.location.lng);
    //
    //         Navigator.of(context).pop();
    //       },
    //       initialPosition: new LatLng(position.latitude, position.longitude),
    //       useCurrentLocation: true,
    //     ),
    //   ),
    // );

    /*
    Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new SelectMapLocation()),).then((val)
    {
      FocusScope.of(context).requestFocus(new FocusNode());
      if(val!=null)
      {
        setState(()
        {
          var data=json.decode(val);
          String name="${data['name']}";
          String Id="${data['id']}";


        });
      }
    });*/
  }

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
}
