import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';

class GlobalFile
{


  static bool ValidateString(BuildContext ctx, List str, List str_name) {
    bool val = true;
    for (int i = 0; i < str.length; i++) {
      if (str[i].toString().trim()
          .length == 0) {
        //GlobalFile.ShowError(str_name[i].toString(), ctx);
        GlobalWidget.GetToast(ctx,str_name[i].toString());

        val = false;
        break;
      }
    }
    return val;
  }


  Future<int> addBook(product) async {

    print("addBook-->$product");

    var map=getmap(product);
    String result = jsonEncode(map);
    int id=0;
    print(result);

    id = await DatabaseHelper.db.addProductInAllTable(
        product['ItId'].toString(), product['Barcode'].toString(), result);
   /* if (!await DatabaseHelper.db.checkOrderIfAlreadyExist(product['ItId'].toString()))
    {

      id = await DatabaseHelper.db.addProductInAllTable(
          product['ItId'].toString(), result);
    }else
    {
      id = await DatabaseHelper.db.UpdateData(
          product['ItId'].toString(), result);
    }
*/
    print("id--->$id");
    return id;
    /*int id = await DatabaseHelper.db.addProductInAllTable(
      product['ItId'].toString(), result);
*/
  }



  Future<int> addBook1(product) async {

    var map=getmap(product);
    String result = jsonEncode(map);
    int id=0;
    print(result);
    if (!await DatabaseHelper.db.checkOrderIfAlreadyExist(product['ItId'].toString()))
    {
      id = await DatabaseHelper.db.addProductInAllTable(
          product['ItId'].toString(),product['Barcode'].toString(), result);
    }else
    {
      id = await DatabaseHelper.db.updateData(
          product['ItId'].toString(), result,product['Barcode'].toString());
    }
    print(id);
    return id;
    /*int id = await DatabaseHelper.db.addProductInAllTable(
      product['ItId'].toString(), result);
*/
  }


  getmap(var products) {

    Map<String, dynamic> map() => {
      'ItName': products['ItName'].toString(),
      'Price': products['Price'].toString(),
      'ItId': products['ItId'].toString(),
      'Unit': products['Unit'].toString(),
      'DiscountDef': products['DiscountDef'].toString(),
      'PrdSch': products['PrdSch'].toString(),
      "Star": products['Star'].toString(),
      "BID": products['BID'].toString(),
      "ForPur": products['ForPur'].toString(),
      "HSN": products['HSN'].toString(),
      "CmbItemGrp": products['CmbItemGrp'].toString(),
      "VG": products['VG'].toString(),
      "Barcode": products['Barcode'].toString(),
    };
    return map();
  }


}