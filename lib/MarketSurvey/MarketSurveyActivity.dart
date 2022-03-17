import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalFile.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/SearchCityAutoComplete/GlobalSearchCity.dart';
import 'package:ondoprationapp/GlobalData/SearchCityAutoComplete/SearchCityModel.dart';
import 'package:ondoprationapp/GlobalData/SearchCity_StoreAutoComplete/GlobalSearchCityStore.dart';
import 'package:ondoprationapp/GlobalData/SearchCity_StoreAutoComplete/SearchCityStoreModel.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/SearchCityWiseLocation.dart';

class MarketSurveyClass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MarketSurveyView();
  }
}

class MarketSurveyView extends State<MarketSurveyClass> {
  final FocusNode _FMRPFocus = FocusNode();
  final FocusNode _FMKTPriceFocus = FocusNode();
  final FocusNode _FRemarkFocus = FocusNode();

  int price_active = 1;
  final _formKey = GlobalKey<FormState>();
  // final CityClick = TextEditingController();
  String City_id = "";
  String Audit_Type_Val = "Rate";
  String Store_id = "";
  String Item_id = "";

  // final ItemNameController = TextEditingController();
  final priceController = TextEditingController();
  final mrpController = TextEditingController();
  final remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSearchItems();
    GlobalSearchCity.getSearchItems(FunctionCityLoad, context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: GlobalWidget.getAppbar("Market Survey"),
      //bottomNavigationBar: GetBottomButtons(),
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
                child: Text("City",
                    style: TextStyle(fontSize: 12.0, color: Colors.black)),
              ),
              SizedBox(
                width: 14.0,
              ),
              Expanded(flex: 8, child: CityClickFeild())
            ]),
            SizedBox(
              height: 20.0,
            ),

            /* new Row(
                children: [
                  Expanded(flex: 2, child: Text("Store",style: TextStyle(fontSize: 12.0,color: Colors.black)),),
                  SizedBox(width: 14.0,),
                  Expanded(flex: 8, child:StoreClickFeild())]
            ),*/

            City_id != ""
                ? new Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text("M. Loc",
                          style:
                              TextStyle(fontSize: 12.0, color: Colors.black)),
                    ),
                    SizedBox(
                      width: 14.0,
                    ),
                    Expanded(flex: 8, child: StoreClickFeild())
                  ])
                : new Container(),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Item",
                    style: TextStyle(fontSize: 12.0, color: Colors.black)),
              ),
              SizedBox(
                width: 14.0,
              ),
              Expanded(
                flex: 8,
                child: ItemNameFeild(),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Mkt. Price",
                    style: TextStyle(fontSize: 12.0, color: Colors.black)),
              ),
              SizedBox(
                width: 14.0,
              ),
              Expanded(
                flex: 8,
                child: PriceFeild(),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Mkt. MRP",
                    style: TextStyle(fontSize: 12.0, color: Colors.black)),
              ),
              SizedBox(
                width: 14.0,
              ),
              Expanded(
                flex: 8,
                child: MRPFeild(),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            new Row(children: [
              Expanded(
                flex: 2,
                child: Text("Remark",
                    style: TextStyle(fontSize: 12.0, color: Colors.black)),
              ),
              SizedBox(
                width: 14.0,
              ),
              Expanded(
                flex: 8,
                child: RemarkFeild(),
              )
            ]),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                List str = new List();
                List str_name = new List();

                str.add(City_id);
                str_name.add("Select City");

                str.add(Store_id);
                str_name.add("Select Store");

                str.add(Item_id);
                str_name.add("Select Item");

                str.add(remarkController.text.toString());
                str_name.add("Enter Remark");

                str.add(priceController.text.toString());
                str_name.add("Enter Price");

                bool val = GlobalFile.ValidateString(context, str, str_name);
                if (val == true) {
                  if (mrpController.text.toString().length > 0) {
                    UpdateData();
                  } else {
                    GlobalWidget.GetToast(context, "Enter MRP");
                  }
                }
              },
              child: new Container(
                alignment: Alignment.center,
                height: 50.0,
                color: colorPrimary,
                child: Text(
                  "SAVE",
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
/*
  void desposeFocus() {

    _FRemarkFocus.unfocus();
    _FMRPFocus.unfocus();
    _FMKTPriceFocus.unfocus();
     Navigator.of(context).pop();

  }
*/

  Future<void> UpdateData() async {
    List a1 = new List();

    Map<String, dynamic> map() => {
          'pname': 'CityId',
          'value': City_id,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'pname': 'LocId',
          'value': Store_id,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };
    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'ItId',
          'value': Item_id.toString(),
        };
    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());
    //2 for stock
    //1 for rate

    Map<String, dynamic> map3() => {
          'pname': "Rate",
          'value': priceController.text.toString(),
        };
    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };
    a1.add(mapobj3());
    Map<String, dynamic> map30() => {
          'pname': "MktMrp",
          'value': mrpController.text.toString(),
        };
    var dmap30 = map30();
    Map<String, dynamic> mapobj30() => {
          'cols': dmap30,
        };
    a1.add(mapobj30());

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

    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map_submit() => {
          'dbPassword': userPass,
          'dbUser': USER_ID.toString(),
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.MappMktRate_Save,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': map_final(),
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map_submit()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log(TAG, data1);
        if (data1['status'] == 0) {
          GlobalWidget.showMyDialog(context, "Success", "Saved successfully");
          mrpController.clear();
          priceController.clear();
          remarkController.clear();
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error",
                "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(
                context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(
            context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.GetToast(context, "No Internet Connection");
    }
  }

  RemarkFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      minLines: 1,
      maxLines: 5,
      focusNode: _FRemarkFocus,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) =>
          GlobalWidget.fieldFocusChangeOnlyUnfouc(context, _FRemarkFocus),
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

  String Unit_Val = "";
  PriceFeild() {
    return new Row(
      children: [
        Expanded(
          flex: 8,
          child: TextFormField(
            // keyboardType: TextInputType.number,
            keyboardType: TextInputType.text,

            maxLength: 10,
            focusNode: _FMKTPriceFocus,
            //textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => GlobalWidget.fieldFocusChange(
                context, _FMKTPriceFocus, _FMRPFocus),
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

  MRPFeild() {
    return new Row(
      children: [
        Expanded(
          flex: 8,
          child: TextFormField(
            // keyboardType: TextInputType.number,
            keyboardType: TextInputType.text,

            maxLength: 10,
            //textInputAction: TextInputAction.done,
            focusNode: _FMRPFocus,
            onFieldSubmitted: (_) => GlobalWidget.fieldFocusChange(
                context, _FMRPFocus, _FRemarkFocus),
            controller: mrpController,
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

  _toggle2() {
    if (City_id == "") {
      GlobalWidget.GetToast(context, "Please Select City First.");
      return;
    }
    Navigator.of(context)
        .push(
      new MaterialPageRoute(builder: (_) => new SearchCityWiseLoc(City_id)),
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

  final StoreClick = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<ModelSearchCity>> keyCity =
      new GlobalKey();
  AutoCompleteTextField searchCityField;
  static List<ModelSearchCity> SearchCityItems = new List<ModelSearchCity>();
  bool loading_city = true;

  void onSelectItemCity(ModelSearchCity item) {
    setState(() {
      searchCityField.textField.controller.text = item.name;
      City_id = item.id;
      GlobalSearchCityStore.getSearchItems(
          FunctionCityStoreLoad, context, City_id);
      setState(() {
        Store_id = "";
      });
    });
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchCityStore>> keyCityStore =
      new GlobalKey();
  AutoCompleteTextField searchCityStoreField;
  static List<ModelSearchCityStore> SearchCityStoreItems =
      new List<ModelSearchCityStore>();
  bool loading_citystore = true;
  void onSelectItemCityStore(ModelSearchCityStore item) {
    Utility.log("tag", item.name);
    StoreClick.text = item.name;
    Store_id = item.id;
    setState(() {
      searchCityStoreField.textField.controller.text = item.name;
    });
  }

  void FunctionCityStoreLoad(List<ModelSearchCityStore> item) {
    SearchCityStoreItems = item;
    setState(() {
      loading_citystore = false;
    });
  }

  void FunctionCityLoad(List<ModelSearchCity> item) {
    SearchCityItems = item;
    setState(() {
      loading_city = false;
    });
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

  void onSelectItem(ModelSearchItem item) {
    Utility.log("tag", item.name);
    //SelectedListId=item.id;
    // GetItemDetail();
    Unit_Val = item.Unit;
    Item_id = item.id;
    Item_name = item.id + "  " + item.name;
    GlobalWidget.getItemDetail(context, Item_id, getData);
    setState(() {
      searchTextField.textField.controller.text = "";
    });
  }

  var data1;
  getData(var data) {
    data1 = data;
    setState(() {});
  }

  String Item_name = "";
  ItemNameFeild() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        loading
            ? new Container()
            : searchTextField = GlobalSearchItem.getAutoSelectionField(
                key, SearchItems, searchTextField, onSelectItem),
        Item_name == ""
            ? new Container()
            : InkWell(
                child: GlobalWidget.showItemName(Item_name),
                onTap: () {
                  GlobalConstant.OpenZoomImage(data1, context);
                },
              ),
      ],
    );
  }

  StoreClickFeild() {
    /* return GestureDetector(
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
            //   onPressed: () => _toggle2(),
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
        : searchCityStoreField = GlobalSearchCityStore.getAutoSelectionfeild(
            keyCityStore,
            SearchCityStoreItems,
            searchCityStoreField,
            onSelectItemCityStore);
  }

  CityClickFeild() {
    /*
    return GestureDetector(

      child: TextFormField(
        readOnly: true,
        onTap: () {
          _toggle1();
        },
        controller: CityClick,
        //textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

        decoration: InputDecoration(

          contentPadding:GlobalWidget.getContentPadding(),
          hintText: "Select City",
          suffixIcon: IconButton(
            padding: EdgeInsets.only(left: 20.0),
            // onPressed: () => _toggle1(),
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
      onTap: ()
      {
        _toggle1();
      },);*/

    return loading_city
        ? new Container()
        : searchCityField = GlobalSearchCity.getAutoSelectionfeild(
            keyCity, SearchCityItems, searchCityField, onSelectItemCity);
  }

  String TAG = "AllendenceClasss";
  /*
  _toggle1()
  {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new SearchCity()),).then((val)
    {
      FocusScope.of(context).requestFocus(new FocusNode());
      if(val!=null)
      {
        setState(()
        {
          var data=json.decode(val);
          String name="${data['name']}";
          String Id="${data['id']}";
          CityClick.text=name;
          City_id=Id;
          setState(() {
            Store_id="";
          });
        });
      }
    });
  }*/

}
