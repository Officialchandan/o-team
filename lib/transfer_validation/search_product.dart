import 'dart:convert';

class SearchProduct {
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
  String bcGunStrict;

  SearchProduct({
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
    this.bcGunStrict,
  });

  @override
  String toString() {
    return 'SearchProduct{docDate: $docDate, hyper: $hyper, productId: $productId, validateQuantity: $validateQuantity, imagePath: $imagePath, quantity: $quantity, docketNumber: $docketNumber, dId: $dId, tId: $tId, productName: $productName, barCode: $barCode, bcgunstrict: $bcGunStrict}';
  }

  factory SearchProduct.fromJson(Map<String, dynamic> json) {
    return SearchProduct(
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
      barCode: json["Barcode"],
      bcGunStrict: json["bcgunstrict"],
    );
  }

  factory SearchProduct.fromString(String product) {
    return SearchProduct.fromJson(jsonDecode(product));
  }

  Map<String, dynamic> toMap() => {
        'DocDate': docDate,
        'Hyper': hyper,
        'ItId': productId,
        'vldQty': validateQuantity,
        'imgpath': imagePath,
        'Qty': quantity,
        'DocNo': docketNumber,
        'did': dId,
        'tid': tId,
        'ItName': productName,
        'Barcode': barCode,
        'bcgunstrict': bcGunStrict,
      };
}
