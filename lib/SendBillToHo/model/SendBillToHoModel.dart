class SendBillToHoModel {
  String pgiNo, inwDt, inwBy, poId, supplier, invoiceDt, invoiceNo, invoiceAmt,iwId;

  SendBillToHoModel(String pgiNo, String inwDt, String inwBy, String poId, String supplier, String invoiceDt,
      String invoiceNo, String invoiceAmt, String iwId) {
    this.pgiNo = pgiNo;
    this.inwDt = inwDt;
    this.inwBy = inwBy;
    this.poId = poId;
    this.supplier = supplier;
    this.invoiceDt = invoiceDt;
    this.invoiceNo = invoiceNo;
    this.invoiceAmt = invoiceAmt;
    this.iwId = iwId;
  }
}
