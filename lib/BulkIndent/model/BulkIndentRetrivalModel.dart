class BulkIndentRetrivalModel {
  String rqty,
      itId,
      sqty,
      secId,
      tCoco,
      packSize,
      imgPath,
      barCode,
      indentDt,
      qty,
      lockSt,
      itemName,
      status,
      kg,
      mainCat,
      stock;
  var data;
  bool done_flag;

  BulkIndentRetrivalModel(String mainCat,
      String itId,
      String itemName,
      String imgPath,
      String stock,
      String qty,
      String sqty,
      String rqty,
      String status,
      String packSize,
      String secId,
      String indentDt,
      String barCode,
      String tCoco,
      String lockSt,
      var data,
      bool flag) {
    this.mainCat = mainCat;
    this.itId = itId;
    this.itemName = itemName;
    this.imgPath = imgPath;
    this.stock = stock;
    this.qty = qty;
    this.sqty = sqty;
    this.rqty = rqty;
    this.status = status;
    this.packSize = packSize;
    this.secId = secId;
    this.indentDt = indentDt;
    this.barCode = barCode;
    this.tCoco = tCoco;
    this.lockSt = lockSt;
    this.data=data;
    this.done_flag=flag;
  }
}
