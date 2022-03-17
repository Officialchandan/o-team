class DBConstant
{
  static final String DATA_BASE_NAME = "retrieval_db";


  static   final String TABLE_ALL_PRODUCT = "All_Product";
  static final String PRODUCT_DATA = "PRODUCT_DATA";
  static final String PRODUCT_ID = "PRODUCT_ID";
  static final String BAR_CODE = "BARCODE";
  static final String ID = "id";


  static final String CREATE_All_PRODUCT_TABLE = "CREATE TABLE " +
      TABLE_ALL_PRODUCT +
      "(" +
      ID+" INTEGER PRIMARY KEY AUTOINCREMENT , " +
      PRODUCT_ID +
      " TEXT," +
      BAR_CODE +
      " TEXT," +
      PRODUCT_DATA +
      " TEXT )";


}

// work by gaurav
/*
* on 24 Dec
*
* In ReportClass
*
* Header part with dorpdown and changing date according to selected type from dropdown.
*
*
* 29 Dec
*
* working on data and filtering like android in reports.
*
*
* 30 Dec
*
* Applied 2 Api's one for POID textfield search and other for Save button.
*
*
* 4 Jan created image compress layout like android and working on image compression.
*
* 5 Jan no data found in bill scan. Data is not coming in bill scan module.
*
* 5 Jan Inward Grc Rcv Status Missing  Done.
*
* 5 Jan Update Image after image compression.
*
* 5 Jan added new items in Main Dashboard List.
*
* 6 Jan Review Audit List Done.
* Sent Bill History Done.
* Send Bill To ho.
*
* */

