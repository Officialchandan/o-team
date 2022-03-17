import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/CityModel.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/DateModel.dart';
import 'package:ondoprationapp/Report/ModelClassReportDetail/GrpModel.dart';
import 'package:ondoprationapp/SacnBill/ZoomPhotoActivity.dart';

import 'Utility.dart';

class GlobalConstant {
  static var key = '123654789@12589741#abedf\$ond852341';
  static const String BASE_URL = "https://webapp.nsbbpo.in/OndRestServer/";

  // static const String BASE_URL = "https://webapptest.nsbbpo.in/OndRestServer/";
  // Live environment url
  //  static const String BASE_URL = "https://cocoapi.ondoor.com/v1/";

  static const String SignUp = BASE_URL + "data/getds";
  static const String SIGNIN = BASE_URL + "data/getds";
  static String dockNumber = "dockNumber";
  static String isVisibleField = "isVisibleField";

  static var host = 'OperationApp';
  static var OS = 'Android';
  static var PROCName = 'Cntr_ShowCounter';
  static var PROCName_Retrival_ODR = 'Mapp_Ortv_RddList';
  static var PO_OrderItems = 'PO_OrderItems';
  static var POList_Save = 'POList_Save';
  static var Mapp_rpt_GetProcs = 'Mapp_rpt_GetProcs';
  static var Mapp_FillLoc = 'Mapp_FillLoc';
  static var Mapp_Whrtv_IndLck = 'Mapp_Whrtv_IndLck';
  static var rpt_ord_SlotSumm = 'rpt_ord_SlotSumm';
  static var Mapp_StkTrf_IndSumm = 'Mapp_StkTrf_IndSumm';
  static var Mapp_Whrtv_Itemlist = 'Mapp_Whrtv_Itemlist';
  static var Mapp_Whrtv_Save_Blk = 'Mapp_Whrtv_Save_Blk';
  static var Mapp_Whrtv_Itemlist_Blk = 'Mapp_Whrtv_Itemlist_Blk';
  static var CntrDmgExp_OtpVerify = 'CntrDmgExp_OtpVerify';
  static var PoRcv_List = 'PoRcv_List';
  static var Mapp_Whrtv_Save = 'Mapp_Whrtv_Save';
  static var PInw_Combo = 'PInw_Combo';
  static var PROCName_Login = 'Mapp_OndOPPLogin';
  static var Map_AmbiAudit = 'Map_AmbiAudit';
  static var CntrExcp_Save = 'CntrExcp_Save';
  static var Mapp_SelectCity = 'Mapp_SelectCity';
  static var Mapp_StoreAudit = 'Mapp_StoreAudit';
  static var MappMktRate_Save = 'MappMktRate_Save';
  static var lib_ItemSyncRates_stk = 'lib_ItemSyncRates_stk';
  static var Mapp_GetStoreList = 'Mapp_GetStoreList';
  static var StkTkngBlk_GetList = 'StkTkngBlk_GetList';
  static var StkTkngBlk_Close = 'StkTkngBlk_Close';
  static var Mapp_getItemInfo = 'Mapp_getItemInfo';
  static var MApp_getItemInfoForApp = 'MApp_getItemInfoForApp';
  static var WhrCntr_save = 'WhrCntr_save';
  static var DocScan_SaveScanDoc_II = 'DocScan_SaveScanDoc_II';
  static var Inward_SaveTrans = 'Inward_SaveTrans';
  static var Inward_new = 'Inward_new';
  static var Inward_Save = 'Inward_Save';
  static var Scr_ReviewList = 'Scr_ReviewList';
  static var Scr_History = 'Scr_History';
  static var Scr_GetParams = 'Scr_GetParams';
  static var Scr_RvSave = 'Scr_RvSave';
  static var Scr_Save = 'Scr_Save';
  static var StkTrf_NewSave = 'StkTrf_NewSave';
  static var Mapp_SaveAttNew = 'Mapp_SaveAttNew';
  static var BadStock_GetList = 'BadStock_GetList';
  static var Inw_ScanPending = 'Inw_ScanPending';
  static var Inward_FillInward = 'Inward_FillInward';
  static var CntrDmgExp_SendOTP = 'CntrDmgExp_SendOTP';
  static var InwardGrc_POParty = 'InwardGrc_POParty';
  static var BillToDC_List = 'BillToDC_List';
  static var BillToDC_Send = 'BillToDC_Send';
  static var BillToDC_History = 'BillToDC_History';
  static var Inward_DeleteInward = 'Inward_DeleteInward';
  static var MApp_GetScanDocType = 'MApp_GetScanDocType';
  static var SrvID = 100;
  static var TimeOut = 6000;
  static String USER_ID = "user_id";
  static String IS_LOGIN = "is_login";
  static String ITEM_ID = "item_id";
  static String USER_PIN = "user_pin";
  static String USER_PASSWORD = "user_pass";
  static String Role = "Role";
  static String AppUpd = "AppUpd";
  static String Empname = "Empname";
  static String AllCityIds = "AllCityIds";
  static var Mapp_StkTrf_BulkIndSumm = 'Mapp_StkTrf_BulkIndSumm';
  static String Appversion = "Appversion";
  static String Menu_Data = "menudata";
  static String COCO_ID = "coco_id";
  static String COCO_NAME = "coco_name";
  static String COCO_CITY_ID = "coco_city_id";
  static String COCO_CITY = "coco_city";
  static String COCO_CITY_CODE = "coco_city_code";
  static String COCO_ADDRESS = "coco_address";
  static String FROM_DATE_Report = "r_f_date";
  static String TO_DATE_Report = "r_to_date";
  static String LAST_TS = "last_ts";
  static var SearchHint = "Type here";
  static String ItemList = "ItemList";
  static String ItemError = "Please Select Item";
  static String PhotoUrl = "https://d1s2zprapij148.cloudfront.net/image/cache/catalog/products/";

  static String PhotoDimention = "-200x200.jpg";

  static String noRecord = "No Record";

  static String Loading = "1";

  static String InterNetException = "Try again slow internet connection";

  static const String VALIDATED_PRODUCT_LIST = "VALIDATED_PRODUCT_LIST";

  static GetMap() {
    Map<String, dynamic> map() => {
          'pname': 'ty',
          'value': 0,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };
    return map1();
  }

  static GetMapBulkIndentRetrival(String PID, int value, int secId) {
    List a1 = new List();
    Map<String, dynamic> map1() => {
          'pname': 'Pid',
          'value': PID,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };

    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'Ty',
          'value': value,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };

    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'pname': 'SecId',
          'value': secId,
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map4();
  }

  static GetMapForAuditId(String AuditId) {
    Map<String, dynamic> map() => {
          'pname': 'AudId',
          'value': AuditId,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForCPID(String CPID) {
    Map<String, dynamic> map() => {
          'pname': 'CPID',
          'value': CPID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForRetrival(String PID) {
    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForBillScan(String PID) {
    Map<String, dynamic> map() => {
          'pname': 'CocoPId',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForInwardGrc(String PID) {
    Map<String, dynamic> map() => {
          'pname': 'IWID',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapToSendBill(String IWID, String RMK) {
    List a1 = new List();

    Map<String, dynamic> map1() => {
          'pname': 'IwIds',
          'value': IWID,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };

    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'Rmk',
          'value': RMK,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };

    a1.add(mapobj2());

    Map<String, dynamic> map() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map();
  }

  static GetMapForInwardGrcPOParty(String PONO) {
    Map<String, dynamic> map() => {
          'pname': 'PoNo',
          'value': PONO,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForRePortDetail(String datef, String datet, String CityIds, String date_req) {
    List a1 = new List();

    if (date_req == "1") {
      Map<String, dynamic> map() => {
            'pname': 'datef',
            'value': datef,
          };

      var dmap = map();
      Map<String, dynamic> mapobj() => {
            'cols': dmap,
          };
      a1.add(mapobj());

      Map<String, dynamic> map1() => {
            'pname': 'datet',
            'value': datet,
          };

      var dmap1 = map1();
      Map<String, dynamic> mapobj1() => {
            'cols': dmap1,
          };
      a1.add(mapobj1());
    }
    Map<String, dynamic> map2() => {
          'pname': 'CityIds',
          'value': CityIds,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    if (CityIds != "") {
      a1.add(mapobj2());
    }
    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map_final();
  }

  static double ConvertDecimal(double val) {
    double mod = pow(10.0, 2);
    return ((val * mod).round().toDouble() / mod);
  }

  static double ConvertDecimal1(double val) {
    double mod = pow(10.0, 3);
    return ((val * mod).round().toDouble() / mod);
  }

  static GetMapForRePortDetailOverAll(String datef, String datet, String CityIds, String date_req) {
    List a1 = new List();

    if (date_req == "1") {
      Map<String, dynamic> map() => {
            'pname': 'datef',
            'value': datef,
          };

      var dmap = map();
      Map<String, dynamic> mapobj() => {
            'cols': dmap,
          };
      a1.add(mapobj());

      Map<String, dynamic> map1() => {
            'pname': 'datet',
            'value': datet,
          };

      var dmap1 = map1();
      Map<String, dynamic> mapobj1() => {
            'cols': dmap1,
          };
      a1.add(mapobj1());
    }

    Map<String, dynamic> map_final() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map_final();
  }

  static GetMapForListBasedStockAudit(String PID, String Type) {
    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map2() => {
          'pname': 'Ty',
          'value': Type,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };

    a1.add(mapobj2());

    if (Type == "ReView") {
      Map<String, dynamic> map3() => {
            'pname': 'ListId',
            'value': 0,
          };

      var dmap3 = map3();
      Map<String, dynamic> mapobj3() => {
            'cols': dmap3,
          };

      a1.add(mapobj3());
    }
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForStockAudit(String PID, String Empcode) {
    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map2() => {
          'pname': 'Empcode',
          'value': Empcode,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };

    a1.add(mapobj2());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForListBasedStockItemDetail(String PID, String ItemId) {
    Map<String, dynamic> map() => {
          'pname': 'Pid',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map3() => {
          'pname': 'itid',
          'value': ItemId,
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForListBasedStockAuditClose(String PID) {
    Map<String, dynamic> map() => {
          'pname': 'ListId',
          'value': PID,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForIndent(String PID) {
    Map<String, dynamic> map() => {
          'pname': 'ty',
          'value': 2,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map2() => {
          'pname': 'Pid',
          'value': PID,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapForIndentDetail(String PID, String CitiId, String SetionId) {
    Map<String, dynamic> map() => {
          'pname': 'Citid',
          'value': CitiId,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };

    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map2() => {
          'pname': 'Secid',
          'value': SetionId,
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());
    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static GetMapLogin() {
    Map<String, dynamic> map() => {
          'pname': 'ty',
          'value': 0,
        };

    var dmap = map();
    Map<String, dynamic> mapobj() => {
          'cols': dmap,
        };
    List a1 = new List();
    a1.add(mapobj());

    Map<String, dynamic> map_col2() => {
          'pname': 'AppVer',
          'value': '4.7',
        };

    var dmap_col2 = map_col2();
    Map<String, dynamic> mapobj_col2() => {
          'cols': dmap_col2,
        };
    a1.add(mapobj_col2());

    Map<String, dynamic> map_col3() => {
          'pname': 'devInfo',
          'value': '',
        };

    var dmap_col3 = map_col3();
    Map<String, dynamic> mapobj_col3() => {
          'cols': dmap_col3,
        };
    a1.add(mapobj_col3());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map1();
  }

  static getSpinnerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      canvasColor: Colors.grey,
    );
  }

  static getTextStyle() {
    return TextStyle(color: Colors.black54, fontSize: 18);
  }

  static getUnderline() {
    return Container(
      height: 2,
      color: Colors.grey,
    );
  }

  static getDurationString(String s) {
    return Text(
      s,
      style: TextStyle(fontSize: 20),
    );
  }

  static getDurationStringText(String s) {
    return Text(
      s,
      style: TextStyle(fontSize: 12),
    );
  }

  static String getamtCount(var headname, items) {
    if (headname["type"] == "varchar") {
      return "-";
    } else {
      double d = 0.0;
      try {
        for (int i = 0; i < items.length; i++) {
          d = d + double.parse(items[i][headname]);
        }
        //   Utility.log("tagamt", d);
        d = GlobalConstant.ConvertDecimal(d);
      } catch (e) {}

      return d.toString();
    }
  }

  static Widget getDateWiseAmount(List<GrpModel> grp_modelList, int length, var head) {
    double amt = 0.0;

    try {
      for (var d1 in grp_modelList) {
        var items = d1.items;

        for (var itemsobj in items) {
          try {
            amt = amt + double.parse(itemsobj[head["name"]]);
          } catch (e) {}
        }
      }
      amt = GlobalConstant.ConvertDecimal(amt);
      return head["type"] != "varchar"
          ? Container(
              margin: EdgeInsets.all(1),
              width: 120,
              alignment: Alignment.center,
              color: Colors.deepOrange[400],
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    head["name"],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(amt.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            )
          : new Container();
    } catch (e) {}
    return new Container();
  }

  static Widget getCityWiseAmount(List<DateModel> dateList, int length, items_column_heading) {
    double amt = 0.0;

    try {
      for (var cityObj in dateList) {
        for (var d1 in cityObj.grp_modelList) {
          var items = d1.items;
          for (var itemsobj in items) {
            amt = amt + double.parse(itemsobj[items_column_heading["name"]]);
          }
        }
      }
      amt = GlobalConstant.ConvertDecimal(amt);
      return Container(
        margin: EdgeInsets.all(1),
        width: 120,
        alignment: Alignment.center,
        color: Colors.green[400],
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              items_column_heading["name"],
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 2.0,
            ),
            Text(amt.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ))
          ],
        ),
      );
    } catch (e) {}
    return new Container();
  }

  static Widget getAllAmount(List<CityModel> city_modelList, items_column_heading) {
    double amt = 0.0;

    try {
      for (int i = 0; i < city_modelList.length; i++) {
        var dateList = city_modelList[i].DateList;

        for (var cityObj in dateList) {
          for (var d1 in cityObj.grp_modelList) {
            var items = d1.items;
            for (var itemsobj in items) {
              amt = amt + double.parse(itemsobj[items_column_heading["name"]]);
            }
          }
        }
      }

      amt = GlobalConstant.ConvertDecimal(amt);

      return items_column_heading["type"].toString() != "varchar"
          ? getContainer(amt, items_column_heading["name"])
          : new Container();
    } catch (e) {}

    return new Container();
  }

  //colum 1
  static List<Widget> buildCellsHeding(int count, items_first_column, String name, BuildContext context) {
    //  Utility.log("Lengthcar", name.length);
    return List.generate(
      count,
      (index) => index == 0
          ? new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10.0),
                  width: GlobalWidget.getCharacterlen(items_first_column[0].toString()),
                  color: colorPrimary,
                  //margin: EdgeInsets.all(4.0),
                  child: Text(
                    "${name}\n",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () {
                    GlobalWidget.showMyDialog(context, "", items_first_column[index].toString());
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(10.0),
                    width: GlobalWidget.getCharacterlen(items_first_column[0].toString()),
                    color: Colors.white,
                    //margin: EdgeInsets.all(4.0),
                    child: Text(
                      items_first_column[index].toString(),
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: () {
                GlobalWidget.showMyDialog(context, "", items_first_column[index].toString());
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10.0),
                width: GlobalWidget.getCharacterlen(items_first_column[0].toString()),
                color: Colors.white,
                //margin: EdgeInsets.all(4.0),
                child: Text(
                  items_first_column[index].toString(),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
    );
  }

  static String GetAmountVal(List<CityModel> city_modelList, String type, header_name) {
    double amt = 0.0;

    try {
      for (int i = 0; i < city_modelList.length; i++) {
        var dateList = city_modelList[i].DateList;

        for (var cityObj in dateList) {
          for (var d1 in cityObj.grp_modelList) {
            var items = d1.items;
            for (var itemsobj in items) {
              if (itemsobj["grp2"] == type) {
                amt = amt + double.parse(itemsobj[header_name]);
              }
              if (itemsobj["grp1"] == type) {
                amt = amt + double.parse(itemsobj[header_name]);
              }
              if (itemsobj["Grp"] == type) {
                amt = amt + double.parse(itemsobj[header_name]);
              }
            }
          }
        }
      }

      amt = GlobalConstant.ConvertDecimal(amt);
      return amt.toString();
    } catch (e) {}
    return "";
  }

  static Widget getContainer(double amt, String head) {
    return Container(
      margin: EdgeInsets.all(1),
      width: 120,
      alignment: Alignment.center,
      color: Colors.brown[400],
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            head,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 2.0,
          ),
          Text(amt.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ))
        ],
      ),
    );
  }

  static String interNetException(String string) {
    return string + "\n" + GlobalConstant.InterNetException;
  }

  static String OpenZoomImage(var data1, BuildContext context) {
    var filename2 = "";
    try {
      String string = data1['ds']['tables'][0]['rowsList'][0]['cols']['ImgPath'].toString();
      var filename = string.split("\\").last;
      filename2 = filename.split(".").first;
      filename2 = "https://d1s2zprapij148.cloudfront.net/image/cache/catalog/products/" + filename2 + "-786x1000.jpg";

      Utility.log("tag1", filename2);
    } catch (e) {}
    if (filename2 == "" || filename2 == null) {
      GlobalWidget.GetToast(context, "Image Not Available ");
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ZoomPhotoActivity(filename2)));
    }
  }
  /*

  static Widget getCityWiseAmount(List<DateM> dateList, int length, items_column_heading) {
    double amt=0.0;

    try
    {

      for(var grp_modelList in dateList)
        {

          for(var d1 in grp_modelList)
          {
            var items= d1.items;
            for(var itemsobj in items)
            {
              amt=amt+double.parse(itemsobj[items_column_heading["name"]]);
            }
          }
        }
      amt =GlobalConstant.ConvertDecimal(amt);
      return Container(
        margin: EdgeInsets.all(1),
        width: 120,
        alignment: Alignment.center,
        color: colorPrimary,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(items_column_heading["name"],textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
            SizedBox(height: 2.0,),
            Text(amt.toString(),style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold,))
          ],
        ),
      );
    }catch(e)
    {

    }
    return new Container();
  }
*/
}
