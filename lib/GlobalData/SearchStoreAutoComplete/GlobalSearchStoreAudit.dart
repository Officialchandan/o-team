import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import '../ApiController.dart';
import '../Dialogs.dart';
import '../GlobalConstant.dart';
import '../GlobalWidget.dart';
import '../NetworkCheck.dart';
import '../Utility.dart';
import 'SearchStoreModel.dart';

class GlobalSearchStoreAudit {
  static List<ModelSearchStore> loadSearchCity(var jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed
        .map<ModelSearchStore>((json) => ModelSearchStore.fromJson(json))
        .toList();
  }

  static void getSearchItems(
      Function(List<ModelSearchStore> DataLoad) FunctionCityStoreLoad,
      BuildContext context,
      String Cityid) async {
    Map<String, dynamic> map() => {
          'pname': 'CityId',
          'value': Cityid,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Mapp_GetStoreList,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': map1(),
        };

    print("datatval2 ${json.encode(map2())}");
    ApiController apiController = new ApiController.internal();

    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map2()));
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
          var SearchItems =
              GlobalSearchStoreAudit.loadSearchCity(a1.toString());
          print('Users: ${SearchItems.length}');
          return FunctionCityStoreLoad(SearchItems);
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

  static getAutoSelectionfeild(var key, var SearchItems, var searchTextField,
      Function(ModelSearchStore item) onSelectItem) {
    return AutoCompleteTextField<ModelSearchStore>(
      key: key,
      clearOnSubmit: false,
      suggestions: SearchItems,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
        hintText: "Search Store",
        hintStyle: TextStyle(color: Colors.grey),
      ),
      suggestionsAmount: 10,
      itemFilter: (item, query) {
        return item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.id == (query);
      },
      itemSorter: (a, b) {
        return a.name.compareTo(b.name);
      },
      itemSubmitted: (item) {
        onSelectItem(item);
      },
      itemBuilder: (context, item) {
        // ui for the autocompelete row
        return row(item);
      },
    );
  }

  static Widget row(ModelSearchStore SearchItem) {
    return GetTextValue(SearchItem.name);
  }

  static Widget GetTextValue(String name) {
    return new Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Divider(),
          Text(
            name,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
