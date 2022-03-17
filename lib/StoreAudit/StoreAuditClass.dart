import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalFile.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/SearchCityAutoComplete/GlobalSearchCity.dart';
import 'package:ondoprationapp/GlobalData/SearchCityAutoComplete/SearchCityModel.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/SearchStoreAutoComplete/GlobalSearchStoreAudit.dart';
import 'package:ondoprationapp/GlobalData/SearchStoreAutoComplete/SearchStoreModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/SearchCity.dart';
import 'package:ondoprationapp/SearchModel/SearchCityWiseStore.dart';

import 'Store_Ambiance_Audit_Class.dart';

class StoreAuditActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuditeView();
  }
}

class AuditeView extends State<StoreAuditActivity> {
  int price_active = 1;
  final _formKey = GlobalKey<FormState>();
  final CityClick = TextEditingController();
  String City_id = "";
  String Audit_Type_Val = "Rate";
  String Store_id = "";
  String Item_id = "";
  final StoreClick = TextEditingController();
//final ItemNameController = TextEditingController();
  final priceController = TextEditingController();
  final remarkController = TextEditingController();

  var data1;
  getData(var data) {
    data1 = data;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: GlobalWidget.getAppbar("Store Audit"),
      bottomNavigationBar: getBottomButtons(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: GlobalWidget.getpadding(),
          children: [
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("City", style: TextStyle(fontSize: 16.0, color: Colors.black)),
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(flex: 8, child: cityClickField())
            ]),
            SizedBox(
              height: 20.0,
            ),
            City_id != ""
                ? new Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text("Store", style: TextStyle(fontSize: 16.0, color: Colors.black)),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(flex: 8, child: storeClickField())
                  ])
                : new Container(),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Audit Type", style: TextStyle(fontSize: 16.0, color: Colors.black)),
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                flex: 8,
                child: selectAuditType(),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Item", style: TextStyle(fontSize: 16.0, color: Colors.black)),
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                flex: 8,
                child: itemNameFeild(),
              )
            ]),
            Item_name == ""
                ? new Container()
                : InkWell(
                    child: GlobalWidget.showItemName(Item_name),
                    onTap: () {
                      GlobalConstant.OpenZoomImage(data1, context);
                    },
                  ),
            SizedBox(
              height: 20.0,
            ),
            price_active == 1
                ? new Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text(Audit_Type == 1 ? "Price" : "Stock", style: TextStyle(fontSize: 16.0, color: Colors.black)),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      flex: 8,
                      child: priceFeild(),
                    )
                  ])
                : new Container(),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Remark", style: TextStyle(fontSize: 16.0, color: Colors.black)),
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                flex: 8,
                child: remarkFeild(),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            Audit_Type == 3
                ? new Column(
                    children: [
                      new Row(children: [
                        Expanded(
                          flex: 2,
                          child: Text("Photo", style: TextStyle(fontSize: 16.0, color: Colors.black)),
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Expanded(flex: 8, child: photoClickField())
                      ]),
                      SizedBox(
                        height: 20.0,
                      ),
                      path != ""
                          ? new Container(
                              height: 100,
                              width: 400,
                              child: new Image.file(
                                File(path),
                              ),
                            )
                          : new Container(),
                    ],
                  )
                : new Container()
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    fetchItemData();
    GlobalSearchCity.getSearchItems(functionCityLoad, context);
    getSearchItems();
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchItem>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  static List<ModelSearchItem> SearchItems = new List<ModelSearchItem>();
  bool loading = true;
  void getSearchItems() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts1();
    if (l1.length < 0) {
      GlobalWidget.GetToast(context, "Please wait untill data is sync");
    } else {
      //SearchItems = loadSearchItems(l1);
      SearchItems = GlobalSearchItem.loadSearchItems(l1.toString());
      // print('SearchItems: ${SearchItems[0].name}');
      setState(() {
        loading = false;
      });
    }
  }

  String Unit_Val = "";
  String Item_name = "";
  void onSelectItem(ModelSearchItem item) {
    Utility.log("tag", item.Unit);
    Unit_Val = item.Unit;
    Item_id = item.id;

    Item_name = item.id + "  " + item.name;
    //GetItemDetail();
    setState(() {
      searchTextField.textField.controller.text = "";
    });
    GlobalWidget.getItemDetail(context, Item_id, getData);
  }

  itemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(key, SearchItems, searchTextField, onSelectItem);
  }

  String TAG = "AllendenceClasss";

  _toggle1() {
    Navigator.of(context)
        .push(
      new MaterialPageRoute(builder: (_) => new SearchCity()),
    )
        .then((val) {
      FocusScope.of(context).requestFocus(new FocusNode());
      if (val != null) {
        setState(() {
          var data = json.decode(val);
          String name = "${data['name']}";
          String Id = "${data['id']}";
          CityClick.text = name;
          City_id = Id;
          setState(() {
            StoreClick.text = "";
            Store_id = "";
          });
        });
      }
    });
  }
/*

  _toggle4() {
    if(getValid())
      {
        Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>SearchItem()),).then((val)
        {
          FocusScope.of(context).requestFocus(new FocusNode());
          if(val!=null)
          {
            setState(()
            {
              var data=json.decode(val);
              String name="${data['name']}";
              String Id="${data['id']}";
              ItemNameController.text=name;
              Item_id=Id;
              setState(() {
              });
            });
          }
        });
      }

  }

*/

  Future<void> updateData() async {
    List a1 = [];

    Map<String, dynamic> map() => {
          'pname': 'Dpid',
          'value': Store_id,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'AuditType',
          'value': Audit_Type_Val,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };
    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'itid',
          'value': Item_id.toString(),
        };
    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());
    //2 for stock
    //1 for rate
    String typePriceId;
    if (Audit_Type == 2) {
      typePriceId = "Qty";
    } else {
      typePriceId = "Rate";
    }
    Map<String, dynamic> map3() => {
          'pname': typePriceId,
          'value': priceController.text.toString(),
        };
    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'Remark',
          'value': "${remarkController.text.toString()}",
        };
    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };
    a1.add(mapobj4());
    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USERID = (await Utility.getStringPreference(GlobalConstant.USER_ID));

    Map<String, dynamic> map_submit() => {
          'dbPassword': userPass,
          'dbUser': USERID.toString(),
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_StoreAudit,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': map_final(),
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);

      apiController.postsNew(GlobalConstant.SignUp, json.encode(map_submit())).then((value) {
        try {
          Dialogs.hideProgressDialog(context);
          var data = value;
          var data1 = json.decode(data.body);
          Utility.log(TAG, data1);
          if (data1['status'] == 0) {
            GlobalWidget.showMyDialog(context, "", "Saved successfully");
            refreshData();
            //Navigator.of(context).pop();
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
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  var _image;
  String path = "";
  Future loadImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      path = image.path;
    });
  }

  _toggle3() async {
    Utility.log(TAG, "clicked");
    bool data = await GlobalPermission.checkPermissionsCamera(context);
    if (data == true) {
      loadImageFromGallery();
    }
  }

  _toggle2() {
    if (City_id == "") {
      GlobalWidget.GetToast(context, "Please Select City First.");
      return;
    }

    Navigator.of(context)
        .push(
      new MaterialPageRoute(builder: (_) => new SearchCityWiseStore(City_id)),
    )
        .then((val) {
      FocusScope.of(context).requestFocus(new FocusNode());
      if (val != null) {
        setState(() {
          var data = json.decode(val);
          String name = "${data['name']}";
          String Id = "${data['id']}";
          StoreClick.text = name;
          Store_id = Id;
          setState(() {});
        });
      }
    });
  }

  getBottomButtons() {
    return new Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (Store_id == "") {
                GlobalWidget.GetToast(context, "Please Select Store");
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StoreAmbiance_Audit(City_id, Store_id)));
              }
            },
            child: new Container(
              alignment: Alignment.center,
              height: 50.0,
              color: colorPrimary,
              child: Text(
                "GEN AUDIT",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 2.0,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              List str = new List();
              List strName = new List();

              str.add(Store_id);
              strName.add("Select Store");

              str.add(Item_id);
              strName.add("Select Item");

              str.add(remarkController.text.toString());
              strName.add("Enter Remark");

              bool val = GlobalFile.ValidateString(context, str, strName);
              if (val == true) {
                if (Audit_Type == 3) {
                  _asyncFileUpload();
                } else {
                  if (priceController.text.toString().length > 0) {
                    updateData();
                  } else {
                    GlobalWidget.GetToast(context, "Enter Price");
                  }
                }
              }
            },
            child: new Container(
              alignment: Alignment.center,
              height: 50.0,
              color: colorPrimary,
              child: Text(
                "SAVE",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchCity>> keyCity = new GlobalKey();

  AutoCompleteTextField searchCityField;
  static List<ModelSearchCity> SearchCityItems = new List<ModelSearchCity>();
  bool loading_city = true;
  void onSelectItemCity(ModelSearchCity item) {
    setState(() {
      searchCityField.textField.controller.text = item.name;
      City_id = item.id;
      GlobalSearchStoreAudit.getSearchItems(functionCityStoreLoad, context, City_id);
      setState(() {
        Store_id = "";
      });
    });
  }

  void functionCityLoad(List<ModelSearchCity> item) {
    SearchCityItems = item;
    setState(() {
      loading_city = false;
    });
  }

  cityClickField() {
    return loading_city
        ? new Container()
        : searchCityField = GlobalSearchCity.getAutoSelectionfeild(keyCity, SearchCityItems, searchCityField, onSelectItemCity);
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchStore>> keyCityStore = new GlobalKey();

  AutoCompleteTextField searchCityStoreField;
  static List<ModelSearchStore> SearchCityStoreItems = new List<ModelSearchStore>();
  bool loading_citystore = true;
  void onSelectItemCityStore(ModelSearchStore item) {
    Utility.log("tag", item.name);
    StoreClick.text = item.name;
    Store_id = item.id;
    setState(() {
      searchCityStoreField.textField.controller.text = item.name;
    });
  }

  void functionCityStoreLoad(List<ModelSearchStore> item) {
    SearchCityStoreItems = item;
    setState(() {
      loading_citystore = false;
    });
  }

  storeClickField() {
    /*return GestureDetector(
      child: TextFormField(
      readOnly: true,
        onTap: ()
        {
         _toggle2();
        },
      controller: StoreClick,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      decoration: InputDecoration(
        contentPadding:GlobalWidget.getContentPadding(),
        hintText: "Select Store",
        suffixIcon: IconButton(
          padding: EdgeInsets.only(left: 20.0),
          //onPressed: () => _toggle2(),
          icon: Icon(Icons.arrow_drop_down),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Select Store';
        }
        return null;
      },
    ),
    onTap: ()
      {
        _toggle2();
      },
    );*/

    return loading_citystore
        ? new Container()
        : searchCityStoreField = GlobalSearchStoreAudit.getAutoSelectionfeild(
            keyCityStore, SearchCityStoreItems, searchCityStoreField, onSelectItemCityStore);
  }

  photoClickField() {
    return GestureDetector(
      child: TextFormField(
        readOnly: true,
        onTap: () {
          _toggle3();
        },
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

        decoration: InputDecoration(
          contentPadding: GlobalWidget.getContentPadding(),
          hintText: "Select Photo",
          suffixIcon: IconButton(
            padding: EdgeInsets.only(left: 20.0),
            // onPressed: () => _toggle3(),
            icon: Icon(Icons.camera),
          ),
        ),
      ),
      onTap: () {
        _toggle3();
      },
    );
  }

  remarkFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      minLines: 1,
      maxLines: 5,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: remarkController,
      decoration: GlobalWidget.TextFeildDecoration("Enter Remark"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter remark';
        }
        return null;
      },
    );
  }

  priceFeild() {
    return new Row(
      children: [
        Expanded(
          flex: 8,
          child: TextFormField(
            // keyboardType: TextInputType.number,
            keyboardType: TextInputType.text,

            maxLength: 10,
            //textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            controller: priceController,
            decoration: GlobalWidget.TextFeildDecoration("Enter"),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please Enter ';
              }
              return null;
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Text("/" + Unit_Val),
        )
      ],
    );
  }

  int Audit_Type = 1;

  selectAuditType() {
    return new Row(
      children: [
        Expanded(
            child: InkWell(
                onTap: () {
                  setState(() {
                    Audit_Type = 1;
                    price_active = 1;
                    Audit_Type_Val = "Rate";
                  });
                },
                child: new Row(
                  children: [
                    Icon(
                      Audit_Type == 1 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: Audit_Type == 1 ? colorPrimary : Colors.grey,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Rate",
                      style: TextStyle(color: Audit_Type == 1 ? colorPrimary : Colors.grey, fontSize: 14),
                    )
                  ],
                ))),
        Expanded(
            child: InkWell(
                onTap: () {
                  setState(() {
                    Audit_Type = 2;
                    price_active = 1;
                    Audit_Type_Val = "Stock";
                  });
                },
                child: new Row(
                  children: [
                    Icon(
                      Audit_Type == 2 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: Audit_Type == 2 ? colorPrimary : Colors.grey,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Stock",
                      style: TextStyle(color: Audit_Type == 2 ? colorPrimary : Colors.grey, fontSize: 14),
                    )
                  ],
                ))),
        Expanded(
            child: InkWell(
                onTap: () {
                  setState(() {
                    Audit_Type = 3;
                    price_active = 2;
                  });
                },
                child: new Row(
                  children: [
                    Icon(
                      Audit_Type == 3 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: Audit_Type == 3 ? colorPrimary : Colors.grey,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Photo",
                      style: TextStyle(color: Audit_Type == 3 ? colorPrimary : Colors.grey, fontSize: 14),
                    )
                  ],
                ))),
      ],
    );
  }

  /*multipart.addFormField("itid",""+itid);
  multipart.addFormField("pid", ""+storeId);
  multipart.addFormField("remark",remark );
  multipart.addFormField("dbUser",OndOpApp.dbUser );
  multipart.addFormField("dbPsw",OndOpApp.dbPassword);
  multipart.addFormField("key","123654789@12589741#abedf$ond852341");
  */

  _asyncFileUpload() async {
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USERID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    //create multipart request for POST or PATCH method
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'charset': 'UTF-8',
    };

    var request = http.MultipartRequest("POST", Uri.parse(GlobalConstant.BASE_URL + "data/SaveImageFile"));
    request.headers.addAll(requestHeaders);
    //add text fields
    request.fields["itid"] = "${Item_id}";
    request.fields["pid"] = "${Store_id}";
    request.fields["remark"] = "${remarkController.text.toString()}";
    request.fields["dbUser"] = "${USERID}";
    request.fields["key"] = "${GlobalConstant.key}";
    request.fields["dbPsw"] = "${userPass}";

    if ("${_image.toString()}" != "null") {
      var gumastaupload = await http.MultipartFile.fromPath("fileUpload", _image.path);
      request.files.add(gumastaupload);
    }

    print(request.files);
    print(request.toString());

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    //GlobalFile.Showsnackbar(_globalKey, "Document Uploaded");

    print(responseString);
    if (responseString.contains(":1")) {
      refreshData();
    }
    /*
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommonMenuDashBoard("shop","home1"),
      ),
    );
*/
  }

  Future<void> fetchItemData() async {}

  bool getValid() {
    return true;
/*
    if(Store_id=="")
    {
      GlobalWidget.GetToast(context, "Select Store First");
      return false;
    }else if(Item_Data == null)
    {
      GlobalWidget.GetToast(context, "Please wait for open");
      return false;
    }else
    {
      GlobalWidget.GetToast(context, "Please wait for open");
      return true;
    }*/
  }

  void refreshData() {
    remarkController.clear();
    priceController.clear();
  }
}
