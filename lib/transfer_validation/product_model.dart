class Product {
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

  Product(
      String docDate,
      String hyper,
      String productId,
      String validateQuantity,
      String imagePath,
      String quantity,
      String docketNumber,
      String dId,
      String tId,
      String productName,
      String barCode) {
    this.docDate = docDate;
    this.hyper = hyper;
    this.productId = productId;
    this.validateQuantity = validateQuantity;
    this.imagePath = imagePath;
    this.quantity = quantity;
    this.docketNumber = docketNumber;
    this.dId = dId;
    this.tId = tId;
    this.productName = productName;
    this.barCode = barCode;
  }

  String getDocDate() {
    return docDate;
  }

  String getHyper() {
    return hyper;
  }

  String getProductId() {
    return productId;
  }

  String getValidateQuantity() {
    return validateQuantity;
  }

  String getImagePath() {
    return imagePath;
  }

  String getQuantity() {
    return quantity;
  }

  String getDocketNumber() {
    return docketNumber;
  }

  String getdId() {
    return dId;
  }

  String gettId() {
    return tId;
  }

  String getProductName() {
    return productName;
  }

  String getBarCode() {
    return barCode;
  }
}
