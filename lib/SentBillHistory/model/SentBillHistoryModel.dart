class SentBillHistoryModel{
  String invoiceNo,iwId,inwBy,pgi,invoiceDt,inwDt,supplier,sendBy,poId,invoiceAmt,sendDt,sendRmk;

  SentBillHistoryModel(String invoiceNo, String iwId,String inwBy,String pgi,String invoiceDt,String inwDt,
      String supplier,String sendBy,String poId,String invoiceAmt,String sendDt,String sendRmk,){

    this.invoiceNo = invoiceNo;
    this.iwId = iwId;
    this.inwBy = inwBy;
    this.pgi = pgi;
    this.invoiceDt = invoiceDt;
    this.inwDt = inwDt;
    this.supplier = supplier;
    this.sendBy = sendBy;
    this.poId = poId;
    this.invoiceAmt = invoiceAmt;
    this.sendDt = sendDt;
    this.sendRmk = sendRmk;
  }
}