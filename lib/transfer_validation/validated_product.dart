import 'package:ondoprationapp/transfer_validation/product_model.dart';


import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'package:ondoprationapp/transfer_validation/product_model.dart';

class ValidatedProduct {
  String docDate;
  String hyper;
  String productId;
  String validateQuantity;
  String imagePath;
  String quantity;
  String docketNumber;
  String dId;
  String tId;
  String productName;
  String barCode;
  ValidatedProduct({
    this.docDate,
    this.hyper,
    this.productId,
    this.validateQuantity,
    this.imagePath,
    this.quantity,
    this.docketNumber,
    this.dId,
    this.tId,
    this.productName,
    this.barCode,
  });

  factory ValidatedProduct.fromJson(Map<String, dynamic> json) {
    return ValidatedProduct(
        docDate: json["DocDate"],
        hyper: json["Hyper"],
        productId: json["ItId"],
        validateQuantity: json["vldQty"],
        imagePath: json["imgpath"],
        quantity: json["Qty"],
        docketNumber: json["DocNo"],
        dId: json["did"],
        tId: json["tid"],
        productName: json["ItName"],
        barCode: json["Barcode"]);
  }
}
