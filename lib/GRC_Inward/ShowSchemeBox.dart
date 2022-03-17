import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';

class ItemSchemeActivity extends StatefulWidget
{
  String Scheme,ItemId,ItemName;

  ItemSchemeActivity(this.Scheme, this.ItemId, this.ItemName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return SchemeView();
  }

}

class SchemeView extends State<ItemSchemeActivity>
{
  var RemarkComtroller = new TextEditingController();
  int Image_Flag=0,Scheme_Flag=0;
  String ImageStatus = "Not Changed";
  String schemeStatus = "Not Changed";
  String PrdSch = "";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return SafeArea(
     child: new Scaffold(
       body: new ListView(
         padding: EdgeInsets.all(10.0),
         children: [
           new Container(alignment: Alignment.topRight,
           child: InkWell(child: Icon(Icons.close,color: Colors.black,size: 30,),
           onTap: ()
           {
             Navigator.of(context).pop();
           },),),
           SizedBox(height: 20,),
           Container(
             width: MediaQuery.of(context).size.width,
             child: new Row(
               children: [
                 Expanded(flex: 2,
                   child: Text("Item Name",
                     style: TextStyle(color: Colors.black,),),
                 ),
                 SizedBox(width: 10,),
                 Expanded(flex: 8,
                   child: Text(widget.ItemName,
                     style: TextStyle(color: Colors.blue,),),
                 ),
               ],
             ),
           ),
           SizedBox(height: 20,),
           Container(
             width: MediaQuery.of(context).size.width,
             child: new Row(
               children: [
                 Expanded(flex: 2,
                   child: Text("Item Scheme",
                     style: TextStyle(color: Colors.black,),),
                 ),
                 SizedBox(width: 10,),
                 Expanded(flex: 8,
                   child: Text(widget.Scheme,
                     style: TextStyle(color: colorPrimary,),),
                 ),
               ],
             ),
           ),
           SizedBox(height: 20,),
           Container(
             width: MediaQuery.of(context).size.width,
             child: new Row(
               children: [
                 Expanded(flex: 2,
                   child: Text("Image",
                     style: TextStyle(color: Colors.black,),),
                 ),
                 SizedBox(width: 10,),
                 Expanded(flex: 8,
                   child: new Row(
                     children: [
                       InkWell(
                         onTap: (){
                            Image_Flag=1;
                            ImageStatus="Changed";
                            setState(() {
                            });
                         },
                         child: Row(
                           children: [
                             Icon(Image_Flag==1?Icons.radio_button_checked:Icons.radio_button_unchecked,color: Image_Flag==1?colorPrimary:Colors.grey,),
                             SizedBox(width: 4,),
                             Text("Changed",style: TextStyle(color: Image_Flag==1?colorPrimary:Colors.grey),)
                           ],
                         ),
                       ),

                        SizedBox(width: 10,),
                        InkWell(
                          onTap: (){
                            Image_Flag=0;
                            ImageStatus="Not Changed";
                            setState(() {

                            });
                          },
                          child: Row(
                           children: [
                             Icon(Image_Flag==0?Icons.radio_button_checked:Icons.radio_button_unchecked,color: Image_Flag==0?colorPrimary:Colors.grey,),
                             SizedBox(width: 4,),
                             Text("Not Changed",style: TextStyle(color: Image_Flag==0?colorPrimary:Colors.grey),)
                           ],
                       ),
                        ),

                     ],
                   ),
                 ),
               ],
             ),
           ),
           SizedBox(height: 20,),
           new Row(
             children: [
               Expanded(flex: 2,
                 child: Text("Scheme",
                   style: TextStyle(color: Colors.black,),),
               ),
               SizedBox(width: 10,),
               Expanded(flex: 8,
                 child: new Row(
                   children: [
                     InkWell(
                       onTap: (){
                         Scheme_Flag=1;
                         schemeStatus="Changed";
                         setState(() {
                         });
                       },
                       child: Row(
                         children: [
                           Icon(Scheme_Flag==1?Icons.radio_button_checked:Icons.radio_button_unchecked,color: Scheme_Flag==1?colorPrimary:Colors.grey,),
                           SizedBox(width: 4,),
                           Text("Changed",style: TextStyle(color: Scheme_Flag==1?colorPrimary:Colors.grey),)
                         ],
                       ),
                     ),

                     SizedBox(width: 10,),
                     InkWell(
                       onTap: (){
                         Scheme_Flag=0;
                         schemeStatus="Not Changed";
                         setState(() {

                         });
                       },
                       child: Row(
                         children: [
                           Icon(Scheme_Flag==0?Icons.radio_button_checked:Icons.radio_button_unchecked,color: Scheme_Flag==0?colorPrimary:Colors.grey,),
                           SizedBox(width: 4,),
                           Text("Not Changed",style: TextStyle(color: Scheme_Flag==0?colorPrimary:Colors.grey),)
                         ],
                       ),
                     ),

                     SizedBox(width: 10,),

                   ],
                 ),
               ),
             ],
           ),
       SizedBox(  height: 10,),
       new Row(
         children: [
           Expanded(flex: 2,
             child: new Container()
           ),

           SizedBox(width: 10,
         ),
           Expanded(flex: 8,
             child:  InkWell(
               onTap: (){
                 Scheme_Flag=2;
                 schemeStatus="Removed";
                 setState(() {

                 });
               },
               child: Row(
                 children: [
                   Icon(Scheme_Flag==2?Icons.radio_button_checked:Icons.radio_button_unchecked,color: Scheme_Flag==2?colorPrimary:Colors.grey,),
                   SizedBox(width: 4,),
                   Text("Removed",style: TextStyle(color: Scheme_Flag==2?colorPrimary:Colors.grey),)
                 ],
               ),
             ),

           ),
     ]),
           SizedBox(height: 20,),
           TextField(
             controller: RemarkComtroller,
             decoration: InputDecoration(hintText: "Remark"),
           ),

           SizedBox(height: 20,),
           getAddBtn(),
         ],
       ),
     ),
   );
  }

  getAddBtn()
  {

    return RaisedButton(

      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: ()
      {

        /*  if(MRPController.text.toString().length<0)
        {
          GlobalWidget.GetToast(context, "Enter valid value for MRP . ");
        }
        else if(QTYController.text.toString().length<0)
        {
          GlobalWidget.GetToast(context, "Enter valid value for Quantity . ");
        }else
        {
        }*/

        Map<String, dynamic> map() => {
          'ImageStatus': ImageStatus,
          'schemeStatus':schemeStatus,
          'remark': RemarkComtroller.text.toString(),
        };
        Navigator.pop(context, map());
      },
      child: Text(
        'Ok',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }
}