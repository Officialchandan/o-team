import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'DBConstant.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper db = DatabaseHelper._();
  Database _database;

  Future<Database> dataBaseInstance() async {
    if (_database == null) {
      _database = await initDB();
    }

    return _database;
  }

  //init data base
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DBConstant.DATA_BASE_NAME);
    return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute(DBConstant.CREATE_All_PRODUCT_TABLE);
    });
  }

  //Clear database
  clearDatabase() async {
    debugPrint("clearDatabase-->");
    try {
      final db = await dataBaseInstance();
      //here we execute a query to drop the table if exists which is called "tableName"
      //and could be given as method's input parameter too
      await db.execute("DROP TABLE IF EXISTS " + DBConstant.TABLE_ALL_PRODUCT);

      await db.execute(DBConstant.CREATE_All_PRODUCT_TABLE);
    } catch (error) {
      throw Exception('DatabaseHelper.clearDatabase: ' + error.toString());
    }
  }

  //Add product in table
  Future<int> addProductInAllTable(String productId, String barcode, String productData) async {
    print("addProductInAllTable--->");

    int id = 0;
    print("Db-id--> $id");

    try {
      print("Db-Id");
      final db = await dataBaseInstance();

      // row to insert
      Map<String, dynamic> row = {
        DBConstant.PRODUCT_ID: productId,
        DBConstant.BAR_CODE: barcode,
        DBConstant.PRODUCT_DATA: productData,
      };
      // print("db.insert ${await db.insert(DBConstant.TABLE_ALL_PRODUCT, row)}");
      id = await db.insert(DBConstant.TABLE_ALL_PRODUCT, row);
      // print("Db-id--23> $id");

      /* db.transaction((txn) async {
      await txn.rawInsert('INSERT INTO ${DBConstant.TABLE_ALL_PRODUCT}(${DBConstant.PRODUCT_ID}, ${DBConstant.PRODUCT_DATA}) VALUES($productId, $ProductData)');
    });*/
      /**
       * close database
       */
      // db.close();
    } catch (error) {
      print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
    }
    return id;
  }

  //check product if already exist in pending table
  Future<bool> checkOrderIfAlreadyExist(String productId) async {
    bool isExist = false;
    try {
      final db = await dataBaseInstance();

      //String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.ORDER_ID + " = '" + order_id + "' AND " + DBConstant.CUSTOM_PRODUCT_ID + "='" + custom_product_id + "' AND " + DBConstant.IS_OFFER_PRODUCT + "='" + isOfferProduct + "'";
      String selectQuery =
          "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.PRODUCT_ID + " = '" + productId + "'";
      List<Map> result = await db.rawQuery(selectQuery);
      if (result.length > 0) {
        isExist = true;
      }
      // db.close();
    } catch (error) {
      print('DatabaseHelper.checkProductIfAlreadyExist: ' + error.toString());
    }
    return isExist;
  }

  //Get Single ItmDetail
  Future<dynamic> getSingleItemDetail(String productId) async {
    Utility.log("DbDAta", productId);
    var data;
    try {
      final db = await dataBaseInstance();
      //String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.ORDER_ID + " = '" + order_id + "' AND " + DBConstant.CUSTOM_PRODUCT_ID + "='" + custom_product_id + "' AND " + DBConstant.IS_OFFER_PRODUCT + "='" + isOfferProduct + "'";
      String selectQuery =
          "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.PRODUCT_ID + " = '" + productId + "'";
      // List<Map> result = await db.rawQuery(selectQuery);
      List<Map> result = await db.rawQuery(selectQuery);
      // looping through all rows and adding to list
      if (result.length > 0) {
        for (int i = 0; i < result.length; i++) {
          data = result[i][DBConstant.PRODUCT_DATA];

          Utility.log("DbDAta", result[i][DBConstant.PRODUCT_DATA]);
          return data;
        }
      }
      // db.close();
    } catch (error) {
      print('DatabaseHelper.checkProductIfAlreadyExist: ' + error.toString());
    }
    return data;
  }

  //Get Single ItmDetail
  Future<dynamic> getSingleItemDetailBarCode(String barcode, BuildContext context) async {
    debugPrint("getSingleItemDetailBarCode--->$barcode");
    var data;
    try {
      final db = await dataBaseInstance();
      //String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.ORDER_ID + " = '" + order_id + "' AND " + DBConstant.CUSTOM_PRODUCT_ID + "='" + custom_product_id + "' AND " + DBConstant.IS_OFFER_PRODUCT + "='" + isOfferProduct + "'";
      // String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.BAR_CODE + " LIKE %" + Barcode  + "%";
      String selectQuery = "SELECT  * FROM All_Product WHERE " + DBConstant.BAR_CODE + " LIKE '%" + barcode + "%'";
      // List<Map> result = await db.rawQuery(selectQuery);
      List<Map> result = await db.rawQuery(selectQuery);
      // looping through all rows and adding to list
      Utility.log("DbDAtalen", result.length);

      if (result.length > 0) {
        for (int i = 0; i < result.length; i++) {
          data = result[i][DBConstant.PRODUCT_DATA];
          Utility.log("DbDAta", result[i][DBConstant.PRODUCT_DATA]);
          return data;
        }
      } else {
        GlobalWidget.showMyDialog(context, "", "Product not found ...$barcode");
      }
      // db.close();
    } catch (error) {
      print('DatabaseHelper.checkProductIfAlreadyExist: ' + error.toString());
    }
    return data;
  }

  //Delete product from pending table
  Future<int> deleteProductFromAllTable(String productId) async {
    int deleteId = 0;
    try {
      final db = await dataBaseInstance();

      //db.close();
      return await db.delete(DBConstant.TABLE_ALL_PRODUCT, where: DBConstant.PRODUCT_ID + ' = ?', whereArgs: [productId]);
    } catch (error) {
      throw Exception('DbBase.deleteProductFromPending: ' + error.toString());
    }
    return deleteId;
  }

  //get retrieved product and update on server
  Future<List> getAllPendingProducts() async {
    print("getAllPendingProducts---->");
    List arrayList = new List();
    try {
      final db = await dataBaseInstance();

      //  String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " Where " + DBConstant.ORDER_ID + "='" + order_id + "' ORDER BY " + DBConstant.CREATED_TIMESTAMP + " DESC";
      String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT;

      List<Map> result = await db.rawQuery(selectQuery);

      // looping through all rows and adding to list
      if (result.length > 0) {
        for (int i = 0; i < result.length; i++) {
          //arrayList.add( result[i][DBConstant.PRODUCT_DATA]);
          arrayList.add(result[i]);
        }
      }
      // close db connection
      try {
        db.close();
      } catch (e) {}
    } catch (error) {
      print('DbBase.getProductAndUpdateOnServer: ' + error.toString());
    }

    return arrayList;
  }

  //get retrieved product and update on server
  Future getAllPendingProducts1() async {
    List arrayList = [];
    // try {
    final db = await dataBaseInstance().catchError((onError) {
      print("onError$onError");
    });

    print("db.isOpen" + db.isOpen.toString());

    //  String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " Where " + DBConstant.ORDER_ID + "='" + order_id + "' ORDER BY " + DBConstant.CREATED_TIMESTAMP + " DESC";
    String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT;

    List<Map> result = await db.rawQuery(selectQuery);

    // looping through all rows and adding to list
    if (result.length > 0) {
      debugPrint("arrayList-->${result.length}");
      for (int i = 0; i < result.length; i++) {
        arrayList.add(result[i][DBConstant.PRODUCT_DATA]);
        //print(result[i][DBConstant.PRODUCT_DATA]);
        // arrayList.add( result[i]);

      }
    }
    try {
      // db.close();
    } catch (e) {}
    // close db connection
    //db.close();
    // } catch(error){
    //   print('DbBase.getProductAndUpdateOnServer: ' + error.toString());
    // }

    return arrayList;
  }

  Future<int> updateData(String itemId, String productData, String barcode) async {
    try {
      final db = await dataBaseInstance();
      Map<String, dynamic> values = {
        DBConstant.PRODUCT_DATA: productData,
        DBConstant.BAR_CODE: barcode,
      };

      int updateCount =
          await db.update(DBConstant.TABLE_ALL_PRODUCT, values, where: DBConstant.PRODUCT_ID + " = ?", whereArgs: [itemId]);

      Utility.log("TAG", "Apiupdatecount " + updateCount.toString());
      return updateCount;
    } catch (error) {
      print('DbBase.updateShortQuantityInSRTTable: ' + error.toString());
      return 0;
    }
  }

  Future<int> addProduct(String productId, String barcode, String productData) async {
    debugPrint("addProduct-->");
    int i = 0;

    try {
      final db = await dataBaseInstance();

      // Map<String, dynamic> product = await getProductById(productId);
      Map<String, dynamic> row = {
        DBConstant.PRODUCT_ID: productId,
        DBConstant.BAR_CODE: barcode,
        DBConstant.PRODUCT_DATA: productData,
      };
      i = await db.insert(DBConstant.TABLE_ALL_PRODUCT, row);
      debugPrint("product inserted -->$i");
      // if (product.isEmpty) {
      //   i = await db.insert(DBConstant.TABLE_ALL_PRODUCT, row);
      //   debugPrint("product inserted -->$i");
      // } else {
      //   i = await db.update(DBConstant.TABLE_ALL_PRODUCT, row, where: DBConstant.PRODUCT_ID + " = ?", whereArgs: [productId]);
      //   debugPrint("product updated -->$i");
      // }
    } catch (exception) {
      debugPrint("exception-->$exception");
    }

    return i;
  }

  Future<Map<String, dynamic>> getProductById(String pId) async {
    debugPrint("getProductById-->");
    Map<String, dynamic> product = {};

    try {
      final db = await dataBaseInstance();

      List<Map<String, dynamic>> result =
          await db.query(DBConstant.TABLE_ALL_PRODUCT, where: DBConstant.PRODUCT_ID + " = ?", whereArgs: [pId]);

      debugPrint("result-->$result");

      if (result.isNotEmpty) {
        product = result.first;
      }
    } catch (exception) {
      debugPrint("exception-->$exception");
    }

    return product;
  }
}
