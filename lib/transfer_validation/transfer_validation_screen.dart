import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/api/api_service.dart';
import 'package:ondoprationapp/model/response_model.dart';
import 'package:ondoprationapp/transfer_validation/search_product.dart';

import 'data_table.dart';
import 'db_model/db_model.dart';
import 'my_data_row.dart';
import 'ond_op_app.dart';

class TransferValidationScreen extends StatefulWidget {
  TransferValidationScreen({Key key}) : super(key: key);

  @override
  State<TransferValidationScreen> createState() => _TransferValidationScreenState();
}

class _TransferValidationScreenState extends State<TransferValidationScreen> {
  TextEditingController docketController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  GlobalKey<AutoCompleteTextFieldState<SearchProduct>> key = new GlobalKey();
  static List<SearchProduct> searchItems = [];
  SearchProduct product;
  List<SearchProduct> validatedProductList = [];
  String codeIdName = "Barcode-item id-Name";

  String productId = "";
  String selectedListId = "";
  String auditTypeVal = "Rate";
  String _scanBarcode = 'Unknown';
  bool getStock = false;
  String borSearch = "";

  String itemName = "";

  @override
  void initState() {
    getCode();
    super.initState();
  }

  getCode() async {
    getStock = await Utility.getBoolPreference(GlobalConstant.isVisibleField);
    docketController.text = await Utility.getStringPreference(GlobalConstant.dockNumber);

    if (docketController.text.isNotEmpty) {
      await EasyLoading.show(status: 'loading...');
      await getDocketItemCount(docketController.text.trim());

      List<String> validatedProducts = await Utility.getStringListPreference(GlobalConstant.VALIDATED_PRODUCT_LIST);

      await Future.forEach(validatedProducts, (product) async {
        SearchProduct searchProduct = SearchProduct.fromString(product);

        validatedProductList.add(searchProduct);
      });
      print("a");
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Transfer Validation"),
        backgroundColor: colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: GestureDetector(
              onTap: () {
                saveProduct();
              },
              child: Icon(
                Icons.check_circle_outline_outlined,
                size: 35,
                color: Colors.cyan[800],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          height: appHeight,
          width: appWidth,
          padding: EdgeInsets.fromLTRB(10, 16, 15, MediaQuery.of(context).size.height * 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 38,
                    width: appWidth * 0.63,
                    child: TextFormField(
                      controller: docketController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        hintText: "Enter Docket Number",
                      ),
                    ),
                  ),
                  MaterialButton(
                    color: colorPrimary,
                    onPressed: () async {
                      String docketNo = docketController.text.trim();
                      if (docketController.text.isEmpty) {
                        showAlertDialog(buttonText: 'ok', title: "Docket number should not be blank");
                      } else if (docketNo.length < 10 || docketNo.length > 20) {
                        showAlertDialog(title: 'Invalid Docket number', buttonText: 'ok');
                      } else {
                        print("docketNo--> $docketNo");
                        await EasyLoading.show(
                          status: 'loading...',
                        );
                        await getDocketItemCount(docketNo);

                        if (searchItems.isNotEmpty) {
                          await Utility.setStringPreference(GlobalConstant.dockNumber, docketController.text);

                          getStock = true;
                          await Utility.setBoolPreference(GlobalConstant.isVisibleField, true);
                        }
                        setState(() {});
                      }
                    },
                    child: Text(
                      searchItems.isEmpty ? "FETCH" : "FETCH" + "(${searchItems.length})",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              getStock
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 38,
                              width: appWidth * 0.73,
                              child: itemNameField(),
                            ),
                            GestureDetector(
                              onTap: () {
                                scanBarcode();
                                debugPrint("_scanBarcode--> $_scanBarcode");
                              },
                              child: Container(
                                height: 33,
                                width: 33,
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                child: Image.asset("assets/scanbtn.png"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          codeIdName,
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Item Quantity:",
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 38,
                              width: appWidth * 0.40,
                              child: TextFormField(
                                controller: quantityController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 11.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              minWidth: appWidth * 0.45,
                              color: colorPrimary,
                              onPressed: () async {
                                updateProduct();
                              },
                              child: Text(
                                "update".toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            MaterialButton(
                              minWidth: appWidth * 0.45,
                              color: colorPrimary,
                              onPressed: () {
                                resetButton();
                              },
                              child: Text(
                                "reset".toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                      ],
                    )
                  : Container(),
              Expanded(
                child: ListView.builder(
                    itemCount: validatedProductList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            child: ListTile(
                              leading: Container(
                                width: appWidth * 0.20,
                                child: CachedNetworkImage(
                                  imageUrl: validatedProductList[index].imagePath,
                                  errorWidget: (context, url, error) => Image.asset("assets/loading.png"),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              title: Text(
                                "${validatedProductList[index].productId}" + "-" + "${validatedProductList[index].productName}",
                                maxLines: 2,
                                style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
                              ),
                              subtitle: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: appWidth * 0.43,
                                    child: Text(
                                      "${validatedProductList[index].barCode}",
                                      maxLines: 2,
                                      style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                  Text(
                                    "${validatedProductList[index].quantity}",
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black54,
                            thickness: 0.7,
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getDocketItemCount(String docketNo) async {
    String oldDocNumber = await Utility.getStringPreference(GlobalConstant.dockNumber);

    if (oldDocNumber != docketController.text.trim()) {
      validatedProductList.clear();
      List<String> validProductList = [];
      validatedProductList.forEach((element) {
        String productString = json.encode(element.toMap());
        print("st---->$productString");
        validProductList.clear();
      });

      Utility.setStringListPreference(GlobalConstant.VALIDATED_PRODUCT_LIST, validProductList);
    }

    try {
      DBRequestModel dbr = new DBRequestModel();

      OndOpApp.dbUser = await Utility.getStringPreference(GlobalConstant.USER_ID);
      OndOpApp.dbPassword = await Utility.getStringPreference(GlobalConstant.USER_PASSWORD);

      dbr.setDbUser(OndOpApp.dbUser);
      dbr.setDbPassword(OndOpApp.dbPassword);
      dbr.setSrvId(OndOpApp.srvId);
      dbr.setProcName("DocValid_Items");
      print("srvId-->${OndOpApp.srvId.bitLength}");

      dbr.setTimeout(30);
      MyDataTable dt = new MyDataTable("param");

      MyDataRow r1 = new MyDataRow();
      r1.add("pname", "COCOPID");
//    r1.add("value", OndOpApp.selectedCoco.getPid());
      r1.add("value", "1580"); //JK Road coco
      dt.addRow(r1);

      MyDataRow r2 = new MyDataRow();
      r2.add("pname", "RefNo");
      r2.add("value", docketNo);
      dt.addRow(r2);
      dbr.setParam(dt);
      Map input = dbr.toJson();
      ResponseModel response = await ApiService().getItems(input: input);
      // if(itemList.length <= 0) {
      //   Dialogs.showProgressDialog(context);
      // }
      if (response.status == 0) {
        searchItems.clear();
        response.dataTable.tables.first.rowsList.forEach((element) async {
          SearchProduct product = SearchProduct.fromJson(element.cols);
          searchItems.add(product);
          getStock = true;
          await EasyLoading.dismiss();
          print("product--> ${product.toString()}");

          setState(() {});
        });
      } else {
        showAlertDialog(buttonText: "ok".toUpperCase(), title: response.msg);
        await EasyLoading.dismiss();
      }
    } catch (e) {
      showAlertDialog(buttonText: "OK", title: "Oops!" + " " + e.toString());
      print("e---->$e");
    }
  }

  Future<void> showAlertDialog({String title, String buttonText}) async {
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Container(
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  buttonText.toUpperCase(),
                  style: TextStyle(color: borderColor, fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);

      SearchProduct scanProduct;
      searchItems.forEach((product) {
        List<String> barcodes = product.barCode.trim().split(",");

        bool find = false;
        barcodes.forEach((barcode) {
          if (barcode == barcodeScanRes) {
            find = true;
            return;
          }
        });

        if (find) {
          scanProduct = product;
          return;
        }
      });

      print("scanProduct--->$scanProduct");
      if (scanProduct != null) {
        itemNameController.text = barcodeScanRes;
        codeIdName = barcodeScanRes + "-" + scanProduct.productId + "-" + scanProduct.productName;
        print("codeIdName-->$codeIdName");
        product = scanProduct;
        setState(() {});
      } else {
        showAlertDialog(title: "Oops! No Product found in docket: $barcodeScanRes", buttonText: "OK");
      }

      print("barcodeScanRes--> $barcodeScanRes");
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> getSearchItems() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts1();

    if (l1.length < 0) {
      GlobalWidget.showToast(context, "Please wait untill data is sync");
    } else {
      searchItems = GlobalSearchItem1.loadSearchItems(l1.toString());
      setState(() {});
    }
  }

  itemNameField() {
    return AutoCompleteTextField<SearchProduct>(
      key: key,
      clearOnSubmit: false,
      controller: itemNameController,
      suggestions: searchItems,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
        hintText: "itName/barCode",
      ),
      suggestionsAmount: 50,
      itemFilter: (item, query) {
        return item.productName.toLowerCase().contains(query.toLowerCase()) ||
            item.productId.toLowerCase().contains(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.productName.compareTo(b.productName);
      },
      itemSubmitted: (item) {
        product = item;
        itemNameController.text = item.productName;
        codeIdName = item.barCode + "-" + item.productId + "-" + item.productName;
        print("codeIdName-->$codeIdName");
        setState(() {});
      },
      textSubmitted: (val) {
        print("textSubmitted");
        String itemBarCode = val.trim();

        if (val.trim().isEmpty) {
          showAlertDialog(buttonText: 'ok', title: "BarCode should not be blank");
        } else {
          SearchProduct scanProduct;

          searchItems.forEach((product) {
            List<String> barcodes = product.barCode.trim().split(",");

            bool find = false;
            barcodes.forEach((barcode) {
              if (barcode == itemBarCode) {
                find = true;
                return;
              }
            });

            if (find) {
              scanProduct = product;
              return;
            }
          });

          // SearchProduct scanProduct = searchItems.singleWhere((element) {
          //   List<String> multiBarCode = element.barCode.trim().split(",");
          //   print("multiBarCode-->$multiBarCode");
          //
          //   multiBarCode.forEach((item) {
          //     if (item.trim() == val.trim()) {
          //       itemSearch = item;
          //     }
          //     print("element--$item");
          //     return multiBarCode;
          //   });
          //
          //   return itemSearch.trim() == val.trim();
          // }, orElse: () {
          //   return null;
          // });

          if (scanProduct == null) {
            showAlertDialog(title: "Oops! No Product found in docket: $itemBarCode", buttonText: "OK");
          } else {
            codeIdName = itemBarCode + "-" + scanProduct.productId + "-" + scanProduct.productName;
            product = scanProduct;
            itemNameController.text = itemBarCode;

            setState(() {});
          }
        }
      },
      itemBuilder: (context, item) {
        print("item---$item");

        return item.bcGunStrict == "0"
            ? ListTile(
                title: Text(item.productName, style: TextStyle(fontSize: 14.0, color: Colors.black)),
                visualDensity: VisualDensity.compact,
              )
            : Container();
      },
    );
  }

  void updateProduct() async {
    if (quantityController.text.isEmpty) {
      showToast(msg: "Please enter quantity");
    } else {
      try {
        double qty = double.parse(quantityController.text.trim().toString());
        double availQty = double.parse(product.quantity);

        if (qty == availQty) {
          int i = validatedProductList.indexWhere((element) => element.productId.trim() == product.productId.trim());
          print("index--->$i");

          if (i > -1) {
            showToast(msg: "Item already validated...!!");
            await EasyLoading.dismiss();
          } else {
            validatedProductList.add(product);
            showToast(msg: product.productName + " Validated!!");

            product = null;
            codeIdName = "Barcode-item id-Name";
            itemNameController.clear();
            quantityController.clear();

            List<String> validProductList = [];
            validatedProductList.forEach((element) {
              String productString = json.encode(element.toMap());
              print("st---->$productString");
              validProductList.add(productString);
            });

            Utility.setStringListPreference(GlobalConstant.VALIDATED_PRODUCT_LIST, validProductList);

            // SearchProduct prod = SearchProduct.fromString(st);
            // print("prod-->${prod.toString()}");

            setState(() {});
          }
        } else {
          showAlertDialog(
              title: "Product quantity mismatch!!\nInput Quantity: " + qty.toString() + "\nRequired Quantity: " + availQty.toString(),
              buttonText: "OK");
        }
      } catch (e) {
        print("e--------->$e");
        showToast(msg: "please check barcode and quantity");
      }
    }
  }

  void resetButton() async {
    if (validatedProductList.isNotEmpty) {
      itemNameController.clear();
      quantityController.clear();
      codeIdName = "Barcode-Item id-Name";
      setState(() {});
    } else {
      getStock = false;
      await EasyLoading.dismiss();

      await Utility.setBoolPreference(GlobalConstant.isVisibleField, false);
      setState(() {});
    }
  }

  showToast({String msg}) {
    Fluttertoast.showToast(
        msg: msg, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, fontSize: 16.0);
  }

  void saveProduct() async {
    if (searchItems.isNotEmpty) {
      if (validatedProductList.length == searchItems.length) {
        showProductTypeDialog(
          docketId: validatedProductList.first.dId,
        );

        print("searchItems-->${searchItems.length}");
      } else {
        String remainProductName = "";

        List<SearchProduct> allProduct = [];
        allProduct.addAll(searchItems);

        validatedProductList.forEach((p) {
          allProduct.removeWhere((element) => element.productId.trim() == p.productId.trim());
        });

        await Future.forEach(allProduct, (SearchProduct product) {
          remainProductName = remainProductName + product.productName + "\n";
        });

        print("allProduct========>${allProduct.length}");
        print("remainProductName-->$remainProductName");

        showAlertDialog(
            title: "${(allProduct.length)}" + "-" + "Item remain to validate!!\n" + "$remainProductName", buttonText: "OK");
      }
    } else {
      showAlertDialog(title: 'Enter docket number and fetch item count before submit!!', buttonText: 'OK');
    }
  }

  Future<void> showProductTypeDialog({
    String docketId,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ValidateProductDialog(
          onOk: (String caret, String bori, String cartoon, String box) {
            print("ValidateProductDialog--onOK");
            String xmlData = "<DocumentElement>";
            for (SearchProduct model in validatedProductList) {
              xmlData = xmlData + "<INV><ItId>" + model.productId + "</ItId><Qty>" + model.quantity + "</Qty></INV>";
            }
            xmlData = xmlData + "</DocumentElement>";
            saveDocketItem(
              boriCount: caret,
              boxCount: bori,
              caretQuantity: cartoon,
              cartoonCount: box,
              docketID: docketId,
              xmlData: xmlData,
            );
            print("ValidateProductDialog----");
          },
          onCancel: () {},
        );
      },
    );
  }

  void saveDocketItem(
      {String docketID, String caretQuantity, String boriCount, String cartoonCount, String boxCount, String xmlData}) async {
    print("saveDocketItem");
    try {
      OndOpApp.dbUser = await Utility.getStringPreference(GlobalConstant.USER_ID);
      OndOpApp.dbPassword = await Utility.getStringPreference(GlobalConstant.USER_PASSWORD);

      DBRequestModel dbr = new DBRequestModel();
      dbr.setDbUser(OndOpApp.dbUser);
      dbr.setDbPassword(OndOpApp.dbPassword);
      dbr.setSrvId(OndOpApp.srvId);
      dbr.setProcName("DocValid_Save");
      dbr.setTimeout(20);
      MyDataTable dataTable = MyDataTable("param");
      MyDataRow row1 = MyDataRow();
      row1.add("pname", "DID");
      row1.add("value", docketID);
      dataTable.addRow(row1);
      MyDataRow row2 = MyDataRow();
      row2.add("pname", "CrateQty");
      row2.add("value", (caretQuantity).contains("") ? "0" : caretQuantity);
      dataTable.addRow(row2);
      MyDataRow row3 = MyDataRow();
      row3.add("pname", "Cartoon");
      row3.add("value", (cartoonCount).contains("") ? "0" : cartoonCount);
      dataTable.addRow(row3);
      MyDataRow row4 = MyDataRow();
      row4.add("pname", "Bori");
      row4.add("value", (boriCount).contains("") ? "0" : boriCount);
      dataTable.addRow(row4);
      MyDataRow row5 = MyDataRow();
      row5.add("pname", "Box");
      row5.add("value", (boxCount).contains("") ? "0" : boxCount);
      dataTable.addRow(row5);
      MyDataRow row6 = MyDataRow();
      row6.add("pname", "Invxml");
      row6.add("value", xmlData);
      dataTable.addRow(row6);
      dbr.setParam(dataTable);
      Map saveProduct = dbr.toJson();
      print("saveProduct-->$saveProduct");
      EasyLoading.show();
      ResponseModel response = await ApiService().postJson(input: saveProduct);
      EasyLoading.dismiss();
      if (response.status == 0) {
        Utility.setStringListPreference(GlobalConstant.VALIDATED_PRODUCT_LIST, []);
        validatedProductList.clear();
        searchItems.clear();
        Utility.setStringPreference(GlobalConstant.dockNumber, "");
        docketController.clear();
        quantityController.clear();
        itemNameController.clear();
        getStock = false;
        setState(() {});

        showAlertDialog(buttonText: "ok".toUpperCase(), title: "");
      } else {
        showAlertDialog(buttonText: "ok".toUpperCase(), title: response.msg);
      }
    } catch (expiation) {
      showAlertDialog(buttonText: "ok".toUpperCase(), title: expiation.toString());
    }
  }
}

class ValidateProductDialog extends StatefulWidget {
  final Function onCancel;
  final Function(String caret, String bori, String cartoon, String box) onOk;

  const ValidateProductDialog({this.onOk, this.onCancel});

  @override
  _ValidateProductDialogState createState() => _ValidateProductDialogState();
}

class _ValidateProductDialogState extends State<ValidateProductDialog> {
  TextEditingController caretTypeController = TextEditingController();
  TextEditingController boriTypeController = TextEditingController();
  TextEditingController cartoonTypeController = TextEditingController();
  TextEditingController boxTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: IntrinsicHeight(
        child: Container(
          margin: EdgeInsets.only(
            top: 15,
            right: 16,
            left: 16,
          ),
          child: Column(
            children: [
              TextFormField(
                controller: caretTypeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintText: "Enter Caret Type Quantity",
                ),
              ),
              TextFormField(
                controller: boriTypeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintText: "Enter Bori Quantity",
                ),
              ),
              TextFormField(
                controller: cartoonTypeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintText: "Enter Cartoon Quantity",
                ),
              ),
              TextFormField(
                controller: boxTypeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintText: "Enter Box Quantity",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100,
              child: MaterialButton(
                color: colorPrimary,
                child: Center(
                  child: Text(
                    "SAVE",
                    style: TextStyle(color: colorAccent, fontSize: 13),
                  ),
                ),
                onPressed: () {
                  widget.onOk(caretTypeController.text.trim(), boriTypeController.text.trim(), cartoonTypeController.text.trim(),
                      boxTypeController.text.trim());
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              width: 100,
              child: MaterialButton(
                color: colorPrimary,
                child: Center(
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: colorAccent, fontSize: 13),
                  ),
                ),
                onPressed: () {
                  widget.onCancel();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
