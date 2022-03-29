import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/SearchStoreAutoComplete/GlobalSearchStore.dart';

import '../ApiController.dart';
import '../Dialogs.dart';
import '../GlobalConstant.dart';
import '../GlobalWidget.dart';
import '../NetworkCheck.dart';
import '../Utility.dart';
import 'SearchCityModel.dart';

class GlobalSearchCity {
  static List<ModelSearchCity> loadSearchCity(var jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed.map<ModelSearchCity>((json) => ModelSearchCity.fromJson(json)).toList();
  }

  static void getSearchItems(Function(List<ModelSearchCity> DataLoad) FunctionCityLoad, BuildContext context) async {
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_SelectCity,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
        };

    print("datatval2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        Utility.log("tag", data.body);

        if (data1['status'] == 0) {
          var products = data1['ds']['tables'][0]['rowsList'];
          List a1 = new List();
          for (int i = 0; i < products.length; i++) {
            a1.add(json.encode(products[i]['cols']));
          }
          Utility.log('Howdy', "${a1.toString()}");
          var SearchItems = GlobalSearchCity.loadSearchCity(a1.toString());
          print('Users: ${SearchItems.length}');
          return FunctionCityLoad(SearchItems);
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

  static getAutoSelectionfeild(var key, var SearchItems, var searchTextField, Function(ModelSearchCity item) onSelectItemCity) {
    return AutoCompleteTextField<ModelSearchCity>(
      key: key,
      clearOnSubmit: false,
      suggestions: SearchItems,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
        hintText: "Search City",
        hintStyle: TextStyle(color: Colors.grey),
      ),
      suggestionsAmount: 10,
      itemFilter: (item, query) {
        return item.name.toLowerCase().contains(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.name.compareTo(b.name);
      },
      itemSubmitted: (item) {
        onSelectItemCity(item);
      },
      itemBuilder: (context, item) {
        // ui for the autocompelete row
        return row(item);
      },
    );
  }

  static Widget row(ModelSearchCity SearchItem) {
    return GlobalSearchStore.getTextValue(SearchItem.name);
  }
}
