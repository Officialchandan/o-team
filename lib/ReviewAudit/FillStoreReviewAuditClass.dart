import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalFile.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'DetailEntryActivity.dart';
class StoreReviewAudit extends StatefulWidget
{
  var ReviewData;
  StoreReviewAudit(this.ReviewData);
  @override
  State<StatefulWidget> createState() {
    return AuditView();
  }
}


class AuditView extends State<StoreReviewAudit>
{
  String AuditId="0";
  final staffCountController = TextEditingController();
  final remarkController = TextEditingController();
  final cocoController = TextEditingController();
  final managerController = TextEditingController();
  final customerCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: GlobalWidget.getAppbar(Empname),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          SizedBox(height: 20.0,),

          CocoFeild(),
          SizedBox(height: 20.0,),
          durationIntItems.length>0?getDurationInt():new Container(),
          SizedBox(height: 20.0,),
          ManagerFeild(),
          SizedBox(height: 20.0,),
          staffCountFeild(),
          SizedBox(height: 20.0,),
          customerCountFeild(),
          RemarkFeild(),
          GestureDetector(



            onTap: ()
            {

              List str = new List();
              List str_name = new List();

              str.add(managerController.text.toString());
              str_name.add("Select Manager");

              str.add(staffCountController.text.toString());
              str_name.add("Enter Staff Count");

              str.add(customerCountController.text.toString());
              str_name.add("Enter Custoemr Count");


              bool val = GlobalFile.ValidateString(context, str, str_name);
              if (val == true)
              {
                Map<String, dynamic> map() => {
                  'AudBy': Empname,
                  'CocoPID': COCO_ID,
                  'Coco': COCO_NAME,
                  'AudType': durationInt,
                  'Manager': managerController.text.toString(),
                  "EmpCount": staffCountController.text.toString(),
                  "from": "edit",
                  "CustCount": customerCountController.text.toString(),
                  "Remark": remarkController.text.toString(),
                  "audid": AuditId,
                };
                Utility.log("tag", map());
                var data=map();
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailEntryActivity(AuditId,data)));
              }

              /*  if(Store_id=="")
              {
                GlobalWidget.GetToast(context, "Please Select Store");
              }else
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StoreAmbiance_Audit(City_id,Store_id)));
              }*/
            },
            child: new Container(
              alignment: Alignment.center,
              height: 50.0,
              color: colorPrimary,
              child: Text("NEXT",style: TextStyle(color: Colors.white,fontSize: 16.0),textAlign: TextAlign.center,),
            ),
          ),
        ],
      ),
    );
  }


  RemarkFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      maxLength: 150,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: remarkController,
      decoration: GlobalWidget.TextFeildDecoration2("Enter Remark","Remark"),
      validator: (value) {

        if (value.isEmpty) {
          return 'Please enter remark';
        }
        return null;
      },
    );
  }
  CocoFeild() {
    return TextFormField(
      keyboardType: TextInputType.text,
      readOnly: true,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: cocoController,
      decoration: GlobalWidget.TextFeildDecoration2("Coco Name","Coco Name"),

    );
  }

  staffCountFeild() {
    return   TextFormField(
     // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,
      
      maxLength: 10,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: staffCountController,
      decoration   : GlobalWidget.TextFeildDecoration2("Staff Count","Staff Count"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please Enter ';
        }
        return null;
      },
    );
  }

  customerCountFeild() {
    return   TextFormField(
     // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,
      
      maxLength: 10,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: customerCountController,
      decoration   : GlobalWidget.TextFeildDecoration2("Customer Count","Customer Count"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please Enter ';
        }
        return null;
      },
    );
  }



  ManagerFeild() {
    return   TextFormField(
      keyboardType: TextInputType.text,
      maxLength: 200,
      //textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: managerController,
      decoration   : GlobalWidget.TextFeildDecoration2("Manager","Manager"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please Enter ';
        }
        return null;
      },
    );
  }


  List <String> durationIntItems =  new List();

  String durationInt ="Visit";
  getDurationInt() {
   // durationInt="Visit";
    Utility.log("Itemlen",widget.ReviewData);
    return DropdownButton<String>(
     // value: durationInt,

      hint: Text(durationInt,style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.bold),),
     // icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      isExpanded: true,
      style: TextStyle(color: colorPrimary),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      onChanged: (String newValue) {
        setState(() {
          durationInt = newValue;
        });
      },
      items: durationIntItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
    return
       new Theme(
          data: GlobalConstant.getSpinnerTheme(context),
          child: DropdownButton<String>(
            value: durationInt,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: GlobalConstant.getTextStyle(),
            underline:GlobalConstant.getUnderline(),
            onChanged: (String data) {
              setState(() {
                durationInt = data;
              });
            },
            items: durationIntItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ));
  }

  @override
  void initState() {

      getData();

  }


  String Empname="";
  String USER_ID,COCO_NAME,COCO_ID;
  getData() async {

    durationIntItems.add("Visit");
    durationIntItems.add("Compalint");
    durationIntItems.add("Account");
    durationInt="Visit";

    Empname = (await Utility.getStringPreference(GlobalConstant.Empname));
    USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    COCO_NAME = (await Utility.getStringPreference(GlobalConstant.COCO_NAME));
    cocoController.text=COCO_NAME;
    COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));


    if(widget.ReviewData!=null)
      {
        Utility.log("TAg", widget.ReviewData);
        cocoController.text =widget.ReviewData["Coco"];
        managerController.text = widget.ReviewData["Manager"];
        Empname=widget.ReviewData["AudBy"];
        AuditId=widget.ReviewData["AudId"];
        durationInt=widget.ReviewData["AudType"];

      }

    setState(() {

    });
  }
}
