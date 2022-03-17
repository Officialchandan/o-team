import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SearchModel/SearchModel.dart';
import 'ApiController.dart';
import 'Dialogs.dart';
import 'GlobalWidget.dart';
import 'NetworkCheck.dart';
import 'SearchCity_StoreAutoComplete/GlobalSearchCityStore.dart';
import 'SearchCity_StoreAutoComplete/SearchCityStoreModel.dart';
import 'SearchItemAutoComplete/SearchItemModel.dart';
import 'SearchCityAutoComplete/SearchCityModel.dart';

class AutoCompleteDemo extends StatefulWidget {
  AutoCompleteDemo() : super();

  final String title = "AutoComplete Demo";

  @override
  _AutoCompleteDemoState createState() => _AutoCompleteDemoState();
}

class _AutoCompleteDemoState extends State<AutoCompleteDemo>
{

  @override
  void initState() {
    super.initState();
    GlobalSearchCityStore.getSearchItems(FunctionCityStoreLoad,context,"2");
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchCityStore>> keyCityStore = new GlobalKey();

  AutoCompleteTextField searchCityStoreField;
  static List<ModelSearchCityStore> SearchCityStoreItems = new List<ModelSearchCityStore>();
  bool loading_citystore = true;
  void onSelectItemCityStore(ModelSearchCityStore item){
    Utility.log("tag", item.name);
    setState(()
    {
      searchCityStoreField.textField.controller.text = item.name;
    });
  }

  void FunctionCityStoreLoad(List<ModelSearchCityStore> item)
  {
    SearchCityStoreItems = item;
    setState(()
    {
      loading_citystore = false;
    });
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
         loading_citystore ? new Container() : searchCityStoreField = GlobalSearchCityStore.getAutoSelectionfeild(keyCityStore,SearchCityStoreItems,searchCityStoreField,onSelectItemCityStore)
        ],
      ),
    );
  }
}
