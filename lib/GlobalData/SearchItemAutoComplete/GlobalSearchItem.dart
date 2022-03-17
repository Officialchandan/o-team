import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/SearchStoreAutoComplete/GlobalSearchStore.dart';
import 'package:ondoprationapp/transfer_validation/search_product.dart';

class GlobalSearchItem {
  static List<ModelSearchItem> loadSearchItems(var jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed
        .map<ModelSearchItem>((json) => ModelSearchItem.fromJson(json))
        .toList();
  }

  static getAutoSelectionField(var key, var searchItems, var searchTextField,
      Function(ModelSearchItem item) onSelectItem) {
    return AutoCompleteTextField<ModelSearchItem>(
      key: key,
      clearOnSubmit: false,
      suggestions: searchItems,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
        hintText: "Search Item",
        hintStyle: TextStyle(color: Colors.grey),
      ),
      suggestionsAmount: 50,
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

  static Widget row(ModelSearchItem searchItem) {
    return GlobalSearchStore.getTextValue(searchItem.name);
  }
}

class GlobalSearchItem1 {
  static List<SearchProduct> loadSearchItems(var jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed
        .map<SearchProduct>((json) => SearchProduct.fromJson(json))
        .toList();
  }

  static getAutoSelectionField1(var key, var searchItems, var searchTextField,
      Function(SearchProduct item) onSelectItem) {
    print("itemNameField");

    return AutoCompleteTextField<SearchProduct>(
      key: key,
      clearOnSubmit: false,
      suggestions: searchItems,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
        hintText: "itName/barCode",
        // hintStyle: TextStyle(color: Colors.grey),
      ),
      suggestionsAmount: 50,
      itemFilter: (item, query) {
        return item.productName.toLowerCase().contains(query.toLowerCase()) ||
            item.productId == (query);
      },
      itemSorter: (a, b) {
        return a.productName.compareTo(b.productName);
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

  static Widget row(SearchProduct searchItem) {
    return GlobalSearchStore.getTextValue(searchItem.productName);
  }
}
